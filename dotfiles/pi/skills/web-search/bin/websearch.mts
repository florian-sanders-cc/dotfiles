#!/usr/bin/env node
// websearch "<query>" [--num N] [--browser]
//
// Searches DuckDuckGo's no-JS HTML endpoint with a plain fetch and prints a ranked
// JSON array of { rank, title, url, snippet }. Falls back to a real browser (via
// playwright-cli) only when the fetch is blocked or returns nothing.

import { browserHeaders, jsLiteral, parseArgs, runPlaywright, textOf } from "./lib.mts";

interface Result {
  rank: number;
  title: string;
  url: string;
  snippet: string;
}

const ENDPOINT = "https://html.duckduckgo.com/html/?q=";

/** DDG wraps result links as /l/?uddg=<real-url>; unwrap to the real destination. */
function decodeUddg(href: string): string {
  try {
    const u = new URL(href, "https://duckduckgo.com");
    const uddg = u.searchParams.get("uddg");
    if (uddg) return uddg;
    if (/^https?:\/\//i.test(href)) return href;
    return u.toString();
  } catch {
    return href;
  }
}

function parseHtml(html: string, num: number): Result[] {
  const anchorRe =
    /<a\b[^>]*class="[^"]*\bresult__a\b[^"]*"[^>]*href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/gi;
  const snippetRe =
    /<a\b[^>]*class="[^"]*\bresult__snippet\b[^"]*"[^>]*>([\s\S]*?)<\/a>/gi;

  const snippets: string[] = [];
  let sm: RegExpExecArray | null;
  while ((sm = snippetRe.exec(html))) snippets.push(textOf(sm[1]));

  const results: Result[] = [];
  let am: RegExpExecArray | null;
  let idx = 0;
  while ((am = anchorRe.exec(html)) && results.length < num) {
    const url = decodeUddg(am[1]);
    const title = textOf(am[2]);
    if (url && title && /^https?:\/\//i.test(url)) {
      results.push({ rank: results.length + 1, title, url, snippet: snippets[idx] ?? "" });
    }
    idx++;
  }
  return results;
}

// Browser fallback uses Bing, not DuckDuckGo: headless Chromium trips DDG's bot
// CAPTCHA, whereas Bing renders normally. The query is embedded as a JSON literal
// (injection-safe); the evaluate() callback reads only the live DOM. run-code has no
// `process`, so the value must be interpolated, not passed via env.
function browserSnippet(query: string): string {
  return `async page => {
  const q = ${jsLiteral(query)};
  await page.goto('https://www.bing.com/search?q=' + encodeURIComponent(q), { waitUntil: 'domcontentloaded' });
  return await page.evaluate(() => {
    // Bing wraps result links as /ck/a?...&u=a1<base64url(realUrl)>; unwrap them.
    const real = (href) => {
      try {
        const u = new URL(href, location.href);
        const uu = u.searchParams.get('u');
        if (uu && uu.startsWith('a1')) return atob(uu.slice(2).replace(/-/g, '+').replace(/_/g, '/'));
        return href;
      } catch { return href; }
    };
    const out = [];
    document.querySelectorAll('li.b_algo').forEach((li) => {
      const a = li.querySelector('h2 a');
      if (!a) return;
      const p = li.querySelector('.b_caption p, .b_algoSlug, p');
      out.push({ title: (a.textContent || '').trim(), url: real(a.getAttribute('href') || ''), snippet: p ? (p.textContent || '').trim() : '' });
    });
    return out;
  });
}`;
}

function viaBrowser(query: string, num: number): Result[] {
  const raw = runPlaywright(browserSnippet(query));
  const arr = Array.isArray(raw) ? raw : [];
  return arr
    .filter((r) => r && typeof r.url === "string" && /^https?:\/\//i.test(r.url))
    .slice(0, num)
    .map((r, i) => ({
      rank: i + 1,
      title: String(r.title ?? ""),
      url: String(r.url),
      snippet: String(r.snippet ?? ""),
    }));
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  let query = args.positional.join(" ").trim();
  if (!query) {
    console.error('usage: websearch "<query>" [--num N] [--browser] [--site domain]');
    process.exit(2);
  }
  if (args.site) query += ` site:${args.site}`; // DDG and Bing both support site: filtering

  let results: Result[] = [];

  if (!args.browser) {
    try {
      const res = await fetch(ENDPOINT + encodeURIComponent(query), {
        headers: browserHeaders(),
        redirect: "follow",
      });
      if (res.ok) {
        const html = await res.text();
        if (!/\b(anomaly|unusual traffic|are you a robot)\b/i.test(html)) {
          results = parseHtml(html, args.num);
        }
      }
    } catch {
      // fall through to the browser fallback
    }
  }

  if (results.length === 0) {
    results = viaBrowser(query, args.num);
  }

  console.log(JSON.stringify(results, null, 2));
}

main().catch((e) => {
  console.error(String(e?.message ?? e));
  process.exit(1);
});
