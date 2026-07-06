#!/usr/bin/env node
// mermaid-check.mjs — validate (and optionally render) a Mermaid diagram.
//
// Usage:
//   node mermaid-check.mjs <diagram.mmd>
//   node mermaid-check.mjs <diagram.mmd> --render <out.svg|out.png>
//
// Authoritative path: `mmdc` (the @mermaid-js/mermaid-cli binary) is provided
// on PATH by the pi Nix wrapper (modules/packages/pi-coding-agent.nix prefixes
// `mermaid-cli` onto PATH; mermaid-cli reuses the Nix-managed chromium via
// PUPPETEER_EXECUTABLE_PATH, so no browser download). mmdc renders the diagram
// to an SVG/PNG and exits non-zero with the grammar error on stderr when the
// syntax is invalid — that exit code is our authoritative validity signal.
//
// Fallback path: if mmdc is not on PATH, fall back to a zero-dependency
// heuristic lint that emits line-precise diagnostics for the common
// first-render breakers. Less powerful (can't certify advanced features) but
// keeps the skill useful in any sandbox.
//
// Exit codes: 0 = valid / ok, 1 = invalid / error, 2 = usage / IO error.

import { spawnSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// ---------- arg parsing ----------
const argv = process.argv.slice(2);
let diagramFile = null;
let renderOut = null;
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === "--render") {
    renderOut = argv[++i];
    if (!renderOut) usage("--render requires a path argument");
  } else if (a === "--help" || a === "-h") {
    usage();
  } else if (a.startsWith("--")) {
    usage(`unknown option: ${a}`);
  } else {
    if (diagramFile) usage("only one diagram file allowed");
    diagramFile = a;
  }
}
if (!diagramFile) usage("missing <diagram.mmd> argument");
if (!existsSync(diagramFile)) {
  console.error(`error: file not found: ${diagramFile}`);
  process.exit(2);
}
const diagramText = readFileSync(diagramFile, "utf8");

function usage(msg) {
  if (msg) console.error("error: " + msg);
  console.error("usage: mermaid-check.mjs <diagram.mmd> [--render out.svg|out.png]");
  process.exit(2);
}

// ---------- mmdc path ----------
function runMmdc(input, output) {
  // -q suppresses non-error output; we only need exit code + stderr.
  const res = spawnSync("mmdc", ["-i", input, "-o", output, "-q"], {
    encoding: "utf8",
    // inherit nothing that would block the nix chromium; PUPPETEER_EXECUTABLE_PATH
    // is already set by the mermaid-cli wrapper on PATH.
    env: process.env,
  });
  return { ok: res.status === 0, status: res.status, stdout: res.stdout || "", stderr: res.stderr || "" };
}

function diagramType(text) {
  const firstLine = text.split(/\r?\n/).map(l => l.trim()).find(Boolean) || "";
  return firstLine.replace(/{.*$/, "").trim() || "unknown";
}

// ---------- heuristic fallback ----------
function heuristicLint(text) {
  const errors = [];
  const lines = text.split(/\r?\n/);
  let subgraphDepth = 0;
  let braceBalance = 0, parenBalance = 0, bracketBalance = 0;

  lines.forEach((line, i) => {
    const trimmed = line.trim();
    const lineno = i + 1;
    if (!trimmed || trimmed.startsWith("%%")) return;

    if (/[\u201c\u201d\u2018\u2019]/.test(line)) {
      errors.push(`${lineno}: smart/curly quotes detected — use straight quotes.`);
    }
    if (/[\u2014\u2013]/.test(line)) {
      errors.push(`${lineno}: unicode dash detected — use a regular hyphen.`);
    }

    if (/^\s*subgraph\b/.test(line)) subgraphDepth++;
    if (/^\s*end\s*$/.test(line)) {
      if (subgraphDepth > 0) subgraphDepth--;
      else errors.push(`${lineno}: stray 'end' with no matching subgraph/block.`);
    }

    for (const ch of line) {
      if (ch === "{") braceBalance++;
      else if (ch === "}") braceBalance--;
      else if (ch === "(") parenBalance++;
      else if (ch === ")") parenBalance--;
      else if (ch === "[") bracketBalance++;
      else if (ch === "]") bracketBalance--;
    }

    if (/\b[A-Za-z_][A-Za-z0-9_]*\[\s*\]/.test(line))
      errors.push(`${lineno}: empty '[]' shape — add a label or drop the brackets.`);
    if (/\b[A-Za-z_][A-Za-z0-9_]*\(\s*\)/.test(line))
      errors.push(`${lineno}: empty '()' shape — add a label or drop the parentheses.`);
    if (/\b[A-Za-z_][A-Za-z0-9_]*\{\s*\}/.test(line))
      errors.push(`${lineno}: empty '{}' shape — add a label or drop the braces.`);

    if (/^\s*classDef\s+\S+\s+[^:]*$/.test(line) && !/:\s*./.test(line))
      errors.push(`${lineno}: classDef missing ':' — use 'classDef name fill:#f00,...'`);

    const pipeCount = (line.match(/\|/g) || []).length;
    if (pipeCount % 2 !== 0)
      errors.push(`${lineno}: unbalanced '|' — edge label pipes must come in pairs.`);

    if (/^\s*end\b/.test(line) && !/^\s*end\s*$/.test(line))
      errors.push(`${lineno}: reserved word 'end' used as identifier (line: ${JSON.stringify(line.trim())}) — rename it.`);
    if (/^\s*subgraph\b/.test(line) &&
        !/^\s*subgraph\b\s*([A-Za-z_]\w*)?\s*(\[[^\]]*\])?\s*$/.test(line))
      errors.push(`${lineno}: reserved word 'subgraph' misused (line: ${JSON.stringify(line.trim())}) — see references/RULES.md.`);
  });

  if (subgraphDepth > 0) errors.push(`file: missing ${subgraphDepth} 'end' line(s) for opened subgraph(s).`);
  if (subgraphDepth < 0) errors.push(`file: ${-subgraphDepth} stray 'end' line(s).`);
  if (braceBalance !== 0) errors.push(`file: unbalanced '{' '}' (${braceBalance > 0 ? "+" : ""}${braceBalance}).`);
  if (parenBalance !== 0) errors.push(`file: unbalanced '(' ')' (${parenBalance > 0 ? "+" : ""}${parenBalance}).`);
  if (bracketBalance !== 0) errors.push(`file: unbalanced '[' ']' (${bracketBalance > 0 ? "+" : ""}${bracketBalance}).`);
  return errors;
}

// ---------- main ----------
function main() {
  let tmp = null;
  try {
    tmp = mkdtempSync(join(tmpdir(), "mermaid-check-"));
  } catch (e) {
    // tmpdir may be unwritable in some sandboxes; fall back to heuristic.
    console.error(`note: cannot create temp dir (${e.message}) — using heuristic fallback.`);
    return runHeuristic();
  }

  const tmpSvg = join(tmp, "out.svg");
  const out = renderOut || tmpSvg;
  const mmdc = runMmdc(diagramFile, out);

  // regardless of mmdc outcome, clean up the temp dir
  try { rmSync(tmp, { recursive: true, force: true }); } catch (e) {}

  if (mmdc.ok) {
    if (renderOut) {
      if (existsSync(renderOut)) {
        console.error(`render: wrote ${renderOut}`);
      } else {
        console.error(`warn: mmdc exited 0 but ${renderOut} was not produced — render may have silently failed.`);
      }
    }
    console.log(`ok (mmdc) type=${diagramType(diagramText)}`);
    process.exit(0);
  }

  // mmdc failed. Distinguish "grammar error" (authoritative) from "mmdc not
  // invocable / chromium missing" (fall back). When mmdc exists and runs but
  // the diagram is invalid, it prints a parse error to stderr.
  const err = (mmdc.stderr || "").trim();
  if (err) {
    // looks like a real mermaid parse error — report it authoritatively.
    console.error("INVALID (mmdc grammar):");
    console.error(err);
    process.exit(1);
  }
  // no stderr but non-zero exit: probably mmdc not on PATH or chromium missing.
  console.error(`note: mmdc run failed (exit ${mmdc.status}) with no error output — mmdc may be missing from PATH. Using heuristic fallback.`);
  runHeuristic();
}

function runHeuristic() {
  const errs = heuristicLint(diagramText);
  if (errs.length === 0) {
    console.log("ok (heuristic) — no common breakers found. (Not a full grammar check; install mermaid-cli / mmdc on PATH for authoritative validation.)");
    process.exit(0);
  }
  console.error("ISSUES (heuristic lint):");
  for (const e of errs) console.error("  " + e);
  console.error("\nHeuristic lint is not exhaustive. Fix the above and re-run; for full grammar validation ensure mmdc is on PATH (mermaid-cli).");
  process.exit(1);
}

main();