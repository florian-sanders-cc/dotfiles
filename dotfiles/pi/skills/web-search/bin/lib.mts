// Shared helpers for the web-search skill.
//
// Design: fetch-first, playwright-cli as fallback. Dynamic values (queries, URLs)
// are handed to the browser fallback via `env`, never string-interpolated into the
// `run-code` snippet — the snippet stays a static string, so no query can break out
// of it (injection-safe).

import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";

export interface Args {
  positional: string[];
  num: number;
  max: number;
  browser: boolean;
  html: boolean;
  site: string;
}

/** Minimal flag parser: positionals + --num/--max (with value) and --browser/--html. */
export function parseArgs(argv: string[]): Args {
  const positional: string[] = [];
  let num = 8;
  let max = 15000;
  let browser = false;
  let html = false;
  let site = "";
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--num") num = parseInt(argv[++i] ?? "", 10);
    else if (a.startsWith("--num=")) num = parseInt(a.slice(6), 10);
    else if (a === "--max") max = parseInt(argv[++i] ?? "", 10);
    else if (a.startsWith("--max=")) max = parseInt(a.slice(6), 10);
    else if (a === "--browser") browser = true;
    else if (a === "--html") html = true;
    else if (a === "--site") site = argv[++i] ?? "";
    else if (a.startsWith("--site=")) site = a.slice(7);
    else positional.push(a);
  }
  if (!Number.isFinite(num)) num = 8;
  if (!Number.isFinite(max)) max = 15000;
  // strip any protocol/path — keep only the bare host for `site:` syntax
  site = site.replace(/^https?:\/\//i, "").replace(/\/.*$/, "").trim();
  return { positional, num, max, browser, html, site };
}

const USER_AGENT =
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36";

/** Headers that make a plain fetch look like a real browser (DDG/most sites need this). */
export function browserHeaders(): Record<string, string> {
  return {
    "User-Agent": USER_AGENT,
    "Accept-Language": "en-US,en;q=0.9",
    Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  };
}

// playwright-cli writes accessibility snapshots to `.playwright-cli/` in its CWD.
// Spawn it from a temp dir so it never litters the user's project (and so it works
// under sandboxes where the project CWD is read-only). tmpdir() honours $TMPDIR,
// which the pi sandbox points at a writable location.
const PW_CWD = tmpdir();

function execRunCode(js: string): string {
  return execFileSync("playwright-cli", ["-s=web", "--raw", "run-code", js], {
    encoding: "utf8",
    cwd: PW_CWD,
    maxBuffer: 32 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"],
  });
}

/**
 * Embed a value as a safe JS string literal for interpolation into a run-code
 * snippet. `JSON.stringify` guarantees a fully-escaped literal, so a hostile query
 * or URL cannot break out of the string (injection-safe). run-code runs in a sandbox
 * without Node's `process`, so passing via env is not an option — this is the way.
 */
export function jsLiteral(value: string): string {
  return JSON.stringify(value);
}

/**
 * Run a Playwright snippet through the sandbox-hardened `playwright-cli`.
 * `js` is a complete `async page => {...}` string (build it with jsLiteral() for any
 * dynamic values). Uses a dedicated `-s=web` session so the user's interactive
 * browser is never touched — the session is opened lazily on first use and kept warm
 * by the playwright-cli daemon for later calls. Returns parsed JSON, or the raw
 * trimmed string if the output was not JSON.
 */
export function runPlaywright(js: string): unknown {
  let out: string;
  try {
    out = execRunCode(js);
  } catch (e: any) {
    const blob = `${e?.stdout ?? ""}${e?.stderr ?? ""}${e?.message ?? ""}`;
    if (/not open/i.test(blob)) {
      // Session has no browser yet — open it once, then retry.
      execFileSync("playwright-cli", ["-s=web", "--raw", "open"], {
        cwd: PW_CWD,
        stdio: "ignore",
      });
      out = execRunCode(js);
    } else {
      throw new Error(blob.trim() || "playwright-cli run-code failed");
    }
  }
  const trimmed = out.trim();
  try {
    return JSON.parse(trimmed);
  } catch {
    return trimmed;
  }
}

const NAMED_ENTITIES: Record<string, string> = {
  amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ",
  mdash: "—", ndash: "–", hellip: "…", laquo: "«", raquo: "»",
};

export function decodeEntities(s: string): string {
  return s
    .replace(/&#(\d+);/g, (_, d) => safeCodePoint(parseInt(d, 10)))
    .replace(/&#x([0-9a-fA-F]+);/g, (_, h) => safeCodePoint(parseInt(h, 16)))
    .replace(/&([a-zA-Z][a-zA-Z0-9]*);/g, (m, name) => NAMED_ENTITIES[name] ?? m);
}

function safeCodePoint(n: number): string {
  try {
    return String.fromCodePoint(n);
  } catch {
    return "";
  }
}

/**
 * Strip HTML to readable plain text. There is no DOM in plain Node, so this is a
 * best-effort regex pass: drop non-content elements, turn block-closers into
 * newlines, remove remaining tags, decode entities, collapse whitespace.
 */
export function stripHtml(html: string): string {
  let s = html;
  s = s.replace(/<!--[\s\S]*?-->/g, " ");
  s = s.replace(/<(script|style|noscript|svg|head|template|iframe)\b[\s\S]*?<\/\1>/gi, " ");
  s = s.replace(/<br\s*\/?>/gi, "\n");
  s = s.replace(/<\/(p|div|section|article|li|h[1-6]|tr|ul|ol|table|blockquote)>/gi, "\n");
  s = s.replace(/<[^>]+>/g, " ");
  s = decodeEntities(s);
  s = s.replace(/[ \t\f\v\r]+/g, " ");
  s = s.replace(/ *\n */g, "\n");
  s = s.replace(/\n{3,}/g, "\n\n");
  return s.trim();
}

/** Collapse inline whitespace and strip tags from a small HTML fragment (titles/snippets). */
export function textOf(fragment: string): string {
  return decodeEntities(fragment.replace(/<[^>]+>/g, "")).replace(/\s+/g, " ").trim();
}
