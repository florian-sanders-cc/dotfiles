#!/usr/bin/env -S node --enable-source-maps
// codediff-ann — CodeDiff review-annotation manager.
//
// Reads/writes `<cwd>/.nvim/codediff-annotations.json`, the same store used by
// the `git.codediff-annotate` Neovim module. Lets agents and shells list,
// add, delete, and resolve review comments without a running Neovim.
//
// Schema:
//   { "<key>": [ { line, end_line?, text, resolved? }, ... ], ... }
//   key forms:
//     work:<cwd-relative-path>     real working-tree file
//     rev:<commit>:<git-root-rel>  git revision virtual buffer
//
// Usage: codediff-ann <command> [flags]
// Global: --cwd <dir>  operate on <dir> (default: process.cwd())
//
// No external dependencies; Node 22+ type-stripping runs .ts directly.

import { readdirSync, readFileSync, writeFileSync, mkdirSync, existsSync, renameSync, statSync } from "node:fs";
import { basename, dirname, join, resolve, relative, isAbsolute, sep } from "node:path";

// ───────────────────────────────────────────────
// types
// ───────────────────────────────────────────────

interface Ann {
  line: number;
  end_line?: number;
  text: string;
  resolved?: boolean;
}
type Store = Record<string, Ann[]>;

// ───────────────────────────────────────────────
// args
// ───────────────────────────────────────────────

function parseArgs(argv: string[]): { cmd: string; flags: Record<string, string | boolean>; positional: string[] } {
  const flags: Record<string, string | boolean> = {};
  const positional: string[] = [];
  let cmd = "";
  let i = 0;
  while (i < argv.length) {
    const a = argv[i];
    if (a === "--cwd") {
      flags.cwd = argv[++i] ?? "";
    } else if (a.startsWith("--cwd=")) {
      flags.cwd = a.slice(6);
    } else if (a.startsWith("--")) {
      const name = a.replace(/^--/, "");
      // support --flag=value or --flag value or boolean --flag
      if (name.includes("=")) {
        const [k, v] = name.split("=", 2);
        flags[k] = v;
      } else {
        const next = argv[i + 1];
        if (next !== undefined && !next.startsWith("--")) {
          flags[name] = next;
          i++;
        } else {
          flags[name] = true;
        }
      }
    } else {
      if (!cmd) cmd = a;
      else positional.push(a);
    }
    i++;
  }
  return { cmd, flags, positional };
}

// ───────────────────────────────────────────────
// store io
// ───────────────────────────────────────────────

function cwdFor(flags: Record<string, string | boolean>): string {
  const c = flags.cwd as string | undefined;
  if (c && c !== true) return resolve(c);
  return process.cwd();
}

function storePath(flags: Record<string, string | boolean>): string {
  return join(cwdFor(flags), ".nvim", "codediff-annotations.json");
}

function load(flags: Record<string, string | boolean>): Store {
  let path = storePath(flags);
  if (!existsSync(path)) return {};
  let raw: string;
  try {
    raw = readFileSync(path, "utf8");
  } catch {
    return {};
  }
  if (!raw.trim()) return {};
  try {
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) return parsed as Store;
    return {};
  } catch (e) {
    process.stderr.write(`codediff-ann: invalid JSON in ${path}: ${(e as Error).message}\n`);
    process.exit(2);
  }
}

function save(flags: Record<string, string | boolean>, data: Store): void {
  // Prune empty arrays and keys before writing.
  const clean: Store = {};
  for (const [k, v] of Object.entries(data)) {
    if (Array.isArray(v) && v.length > 0) clean[k] = v;
  }
  const path = storePath(flags);
  mkdirSync(dirname(path), { recursive: true });
  // atomic write: temp file + rename
  const tmp = path + ".tmp";
  writeFileSync(tmp, JSON.stringify(clean, null, 2) + "\n", "utf8");
  renameSync(tmp, path);
}

// ───────────────────────────────────────────────
// path -> key resolution
// ───────────────────────────────────────────────

// Build a work: key for an absolute file path relative to cwd. Returns null
// if the file is outside cwd.
function workKey(abs: string, cwd: string): string | null {
  if (!isAbsolute(abs)) abs = resolve(cwd, abs);
  let rel = relative(cwd, abs);
  if (!rel || rel.startsWith(`..${sep}`) || rel === "..") return null;
  return "work:" + rel.split(sep).join("/");
}

// Accept an explicit key verbatim if it starts with "work:" or "rev:".
function normalizeKeyFlags(flags: Record<string, string | boolean>, cwd: string): string | null {
  const k = flags.key as string | undefined;
  if (k && k !== true) {
    if (k.startsWith("work:") || k.startsWith("rev:")) return k;
    // treat as a cwd-relative path -> work:<path>
    return "work:" + k.replace(/^\.?\//, "");
  }
  const f = flags.file as string | undefined;
  if (f && f !== true) {
    return workKey(f, cwd);
  }
  return null;
}

// ───────────────────────────────────────────────
// helpers
// ───────────────────────────────────────────────

function findAnnAtLine(anns: Ann[], line: number): number[] {
  const idxs: number[] = [];
  anns.forEach((a, i) => {
    const s = a.line;
    const e = a.end_line ?? a.line;
    if (line >= s && line <= e) idxs.push(i);
  });
  return idxs;
}

function sortAnns(anns: Ann[]): Ann[] {
  return anns
    .slice()
    .sort((a, b) => (a.line || 0) - (b.line || 0) || (a.end_line ?? a.line) - (b.end_line ?? b.line));
}

function num(x: string | boolean | undefined, name: string): number {
  if (x === undefined || x === true || x === "") {
    process.stderr.write(`codediff-ann: missing --${name}\n`);
    printHelp();
    process.exit(2);
  }
  const n = Number(x);
  if (!Number.isFinite(n) || !Number.isInteger(n) || n < 1) {
    process.stderr.write(`codediff-ann: --${name} must be a positive integer, got ${String(x)}\n`);
    process.exit(2);
  }
  return n;
}

function str(x: string | boolean | undefined, name: string): string {
  if (x === undefined || x === true || x === "") {
    process.stderr.write(`codediff-ann: missing --${name}\n`);
    printHelp();
    process.exit(2);
  }
  return String(x);
}

// ───────────────────────────────────────────────
// output formatters
// ───────────────────────────────────────────────

function fmtText(s: string | undefined | null, w: number): string {
  s = String(s ?? "").replace(/\n/g, " ⏎ ");
  return s.length > w ? s.slice(0, w - 1) + "…" : s;
}

function pad(s: string, w: number): string {
  s = String(s);
  return s.length >= w ? s : s + " ".repeat(w - s.length);
}

function truncateKey(k: string, w: number): string {
  if (k.length <= w) return k;
  // keep the tail (path) visible
  return "…" + k.slice(-(w - 1));
}

// ───────────────────────────────────────────────
// commands
// ───────────────────────────────────────────────

interface CmdCtx {
  flags: Record<string, string | boolean>;
  cwd: string;
}

function cmdList(ctx: CmdCtx): void {
  const { flags, cwd } = ctx;
  const data = load(flags);
  const keys = Object.keys(data).sort();
  if (keys.length === 0) {
    if (flags.json) process.stdout.write("[]\n");
    else process.stdout.write("(no annotations)\n");
    return;
  }

  const filterKey = normalizeKeyFlags(flags, cwd);
  const resolvedOnly = flags.resolved === true;
  const unresolvedOnly = flags.unresolved === true;

  let rows: { key: string; i: number; ann: Ann }[] = [];
  for (const k of keys) {
    if (filterKey && k !== filterKey) continue;
    data[k].forEach((ann, i) => {
      const r = ann.resolved === true;
      if (resolvedOnly && !r) return;
      if (unresolvedOnly && r) return;
      rows.push({ key: k, i: i + 1, ann });
    });
  }

  if (flags.json) {
    process.stdout.write(JSON.stringify(rows.map(r => ({
      key: r.key,
      index: r.i,
      line: r.ann.line,
      end_line: r.ann.end_line ?? r.ann.line,
      text: r.ann.text,
      resolved: r.ann.resolved === true,
    })), null, 2) + "\n");
    return;
  }

  // tabular
  const cols = {
    key: 38,
    idx: 4,
    line: 7,
    span: 5,
    state: 4,
    text: 52,
  };
  const header = [
    pad("KEY", cols.key),
    pad("#", cols.idx),
    pad("LINE", cols.line),
    pad("SPAN", cols.span),
    pad("ST", cols.state),
    "TEXT",
  ].join("  ");
  process.stdout.write(header + "\n");
  process.stdout.write("-".repeat(header.length) + "\n");
  for (const r of rows) {
    const span = (r.ann.end_line ?? r.ann.line) - r.ann.line + 1;
    process.stdout.write([
      pad(truncateKey(r.key, cols.key), cols.key),
      pad(String(r.i), cols.idx),
      pad(String(r.ann.line), cols.line),
      pad(String(span), cols.span),
      pad(r.ann.resolved ? "✓" : " ", cols.state),
      fmtText(r.ann.text ?? "", cols.text),
    ].join("  ") + "\n");
  }
  process.stdout.write(`\n${rows.length} annotation(s) in ${filterKey ? 1 : keys.length} key(s)\n`);
}

function cmdKeys(ctx: CmdCtx): void {
  const { flags } = ctx;
  const data = load(flags);
  const keys = Object.keys(data).sort();
  if (keys.length === 0) {
    if (flags.json) process.stdout.write("[]\n");
    else process.stdout.write("(no keys)\n");
    return;
  }
  const rows = keys.map(k => {
    const anns = data[k];
    const total = anns.length;
    const done = anns.filter(a => a.resolved === true).length;
    return { key: k, total, resolved: done, unresolved: total - done };
  });
  if (flags.json) {
    process.stdout.write(JSON.stringify(rows, null, 2) + "\n");
    return;
  }
  for (const r of rows) {
    process.stdout.write(`${pad(truncateKey(r.key, 60), 60)}  ${r.resolved}/${r.total} resolved\n`);
  }
  process.stdout.write(`\n${keys.length} key(s)\n`);
}

function cmdAdd(ctx: CmdCtx): void {
  const { flags, cwd } = ctx;
  const key = normalizeKeyFlags(flags, cwd);
  if (!key) {
    process.stderr.write("codediff-ann: add needs --key <key|relpath> or --file <abspath>\n");
    process.exit(2);
  }
  const line = num(flags.line, "line");
  const endLine = flags["end-line"] !== undefined && flags["end-line"] !== true
    ? num(flags["end-line"], "end-line")
    : undefined;
  const text = str(flags.text, "text");
  const resolved = flags.resolved === true;

  const data = load(flags);
  const anns = (data[key] ||= []);
  anns.push({ line, ...(endLine ? { end_line: endLine } : {}), text, ...(resolved ? { resolved: true } : {}) });
  data[key] = sortAnns(anns);
  save(flags, data);
  process.stdout.write(`added #${anns.length} on ${key} L${line}${endLine ? `-${endLine}` : ""}\n`);
}

function cmdDelete(ctx: CmdCtx): void {
  const { flags, cwd } = ctx;
  const key = normalizeKeyFlags(flags, cwd);
  if (!key) {
    process.stderr.write("codediff-ann: delete needs --key <key|relpath> or --file <abspath>\n");
    process.exit(2);
  }
  const data = load(flags);
  const anns = data[key];
  if (!anns || anns.length === 0) {
    process.stderr.write(`codediff-ann: no annotations for ${key}\n`);
    process.exit(1);
  }
  let idxs: number[];
  if (flags.index !== undefined && flags.index !== true) {
    const i = num(flags.index, "index") - 1;
    if (i < 0 || i >= anns.length) {
      process.stderr.write(`codediff-ann: index ${i + 1} out of range (1-${anns.length})\n`);
      process.exit(2);
    }
    idxs = [i];
  } else if (flags.line !== undefined && flags.line !== true) {
    const ln = num(flags.line, "line");
    idxs = findAnnAtLine(anns, ln);
    if (idxs.length === 0) {
      process.stderr.write(`codediff-ann: no annotation at L${ln} on ${key}\n`);
      process.exit(1);
    }
  } else {
    process.stderr.write("codediff-ann: delete needs --index N or --line N\n");
    process.exit(2);
  }
  // remove highest first to keep indices stable
  idxs.sort((a, b) => b - a);
  for (const i of idxs) {
    const removed = anns.splice(i, 1)[0];
    process.stdout.write(`deleted #${i + 1} (L${removed.line}${removed.end_line ? `-${removed.end_line}` : ""}) from ${key}\n`);
  }
  if (anns.length === 0) delete data[key];
  else data[key] = anns;
  save(flags, data);
}

function cmdResolve(ctx: CmdCtx, value: boolean): void {
  const { flags, cwd } = ctx;
  const key = normalizeKeyFlags(flags, cwd);
  if (!key) {
    process.stderr.write(`codediff-ann: ${value ? "resolve" : "unresolve"} needs --key <key|relpath> or --file <abspath>\n`);
    process.exit(2);
  }
  const data = load(flags);
  const anns = data[key];
  if (!anns || anns.length === 0) {
    process.stderr.write(`codediff-ann: no annotations for ${key}\n`);
    process.exit(1);
  }
  let idxs: number[];
  if (flags.index !== undefined && flags.index !== true) {
    const i = num(flags.index, "index") - 1;
    if (i < 0 || i >= anns.length) {
      process.stderr.write(`codediff-ann: index ${i + 1} out of range (1-${anns.length})\n`);
      process.exit(2);
    }
    idxs = [i];
  } else if (flags.line !== undefined && flags.line !== true) {
    const ln = num(flags.line, "line");
    idxs = findAnnAtLine(anns, ln);
    if (idxs.length === 0) {
      process.stderr.write(`codediff-ann: no annotation at L${ln} on ${key}\n`);
      process.exit(1);
    }
  } else if (flags.all === true) {
    idxs = anns.map((_, i) => i);
  } else {
    process.stderr.write(`codediff-ann: ${value ? "resolve" : "unresolve"} needs --index N, --line N, or --all\n`);
    process.exit(2);
  }
  let changed = 0;
  for (const i of idxs) {
    if ((anns[i].resolved === true) !== value) {
      if (value) anns[i].resolved = true;
      else delete anns[i].resolved;
      changed++;
    }
  }
  data[key] = anns;
  save(flags, data);
  process.stdout.write(`${value ? "resolved" : "unresolved"} ${changed}/${idxs.length} on ${key}\n`);
}

function cmdPath(ctx: CmdCtx): void {
  process.stdout.write(storePath(ctx.flags) + "\n");
}

function cmdSweep(ctx: CmdCtx): void {
  // Remove pruned/disappeared keys: keep entries whose referenced working
  // file still exists on disk (for work: keys). rev: keys are left intact
  // (cannot verify a past revision cheaply).
  const { flags, cwd } = ctx;
  const data = load(flags);
  let pruned = 0;
  for (const k of Object.keys(data)) {
    if (k.startsWith("work:")) {
      const rel = k.slice("work:".length);
      const abs = resolve(cwd, rel);
      if (!existsSync(abs)) {
        delete data[k];
        pruned++;
      }
    }
  }
  if (pruned > 0) save(flags, data);
  process.stdout.write(`swept ${pruned} stale work: key(s)\n`);
}

// ───────────────────────────────────────────────
// help
// ───────────────────────────────────────────────

const HELP = `codediff-ann — manage CodeDiff review annotations

Usage: codediff-ann <command> [flags]

Global flags:
  --cwd <dir>          operate on <dir> (default: current directory)
  --json               machine-readable output (list/keys)

Commands:
  list                 list annotations
    --key <k|relpath>  filter by key (accepts bare relative path)
    --file <abspath>   filter by file (converted to work:<rel>)
    --resolved         only resolved
    --unresolved       only unresolved
  keys                 list keys with resolved/total counts
  add                  add an annotation
    --key <k|relpath>  required (or --file)
    --line N           required, 1-indexed start line
    --end-line M       optional, inclusive end line
    --text T           required
    --resolved         mark resolved immediately
  delete               delete annotation(s)
    --key <k|relpath>  required (or --file)
    --index N          delete the Nth annotation for the key (1-indexed)
    --line N           delete all annotations covering line N
  resolve              mark resolved
    --key <k|relpath>  required (or --file)
    --index N | --line N | --all
  unresolve            mark unresolved (same flags as resolve)
  sweep                 prune work: keys whose file no longer exists (rev: untouched)
  path                 print the store path for this cwd
  help                 this message

Key formats:
  work:<cwd-relative-path>        real working-tree file
  rev:<commit>:<git-root-rel>    git revision virtual buffer

The --key flag accepts a bare relative path (e.g. "src/main.ts") and
auto-promotes it to "work:<path>".
`;

function printHelp(): void {
  process.stdout.write(HELP);
}

// ───────────────────────────────────────────────
// main
// ───────────────────────────────────────────────

function main(): void {
  const argv = process.argv.slice(2);
  const { cmd, flags } = parseArgs(argv);
  const cwd = cwdFor(flags);
  const ctx: CmdCtx = { flags, cwd };

  switch (cmd) {
    case "list":
    case "ls":
      cmdList(ctx);
      break;
    case "keys":
      cmdKeys(ctx);
      break;
    case "add":
      cmdAdd(ctx);
      break;
    case "delete":
    case "del":
    case "rm":
      cmdDelete(ctx);
      break;
    case "resolve":
      cmdResolve(ctx, true);
      break;
    case "unresolve":
      cmdResolve(ctx, false);
      break;
    case "sweep":
      cmdSweep(ctx);
      break;
    case "path":
      cmdPath(ctx);
      break;
    case "help":
    case "--help":
    case "-h":
    case "":
      printHelp();
      break;
    default:
      process.stderr.write(`codediff-ann: unknown command "${cmd}"\n\n`);
      printHelp();
      process.exit(2);
  }
}

main();