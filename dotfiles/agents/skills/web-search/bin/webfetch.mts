#!/usr/bin/env node
// webfetch <url> [--max N] [--browser] [--html]
//
// Fetches a URL and prints { url, title, text } with the page reduced to readable
// text. Uses a plain fetch + HTML strip for static pages; escalates to a real
// browser (via playwright-cli) when the page looks like an empty JS/SPA shell or
// when --browser is forced. --html returns the raw HTML instead of stripped text.

import { browserHeaders, jsLiteral, parseArgs, runPlaywright, stripHtml } from "./lib.mts";

interface Fetched {
  url: string;
  title: string;
  text: string;
}

function titleFromHtml(html: string): string {
  const m = /<title[^>]*>([\s\S]*?)<\/title>/i.exec(html);
  return m ? m[1].replace(/\s+/g, " ").trim() : "";
}

/** Heuristic: little text + a known SPA mount point => needs a real browser. */
function looksLikeSpaShell(html: string, text: string): boolean {
  if (text.length >= 500) return false;
  if (/<(div|main)\b[^>]+id=["'](root|app|__next|__nuxt)["']/i.test(html)) return true;
  return text.length < 200;
}

// Browser snippet: the URL is embedded as a JSON literal (injection-safe). run-code
// has no `process`, so the value must be interpolated, not passed via env.
function browserSnippet(url: string): string {
  return `async page => {
  await page.goto(${jsLiteral(url)}, { waitUntil: 'domcontentloaded' });
  try { await page.waitForLoadState('networkidle', { timeout: 3000 }); } catch {}
  return await page.evaluate(() => {
    document.querySelectorAll('script,style,noscript,svg,nav,header,footer,aside,[aria-hidden="true"]').forEach((e) => e.remove());
    const root = document.querySelector('article') || document.querySelector('main') || document.body;
    const text = (root ? root.innerText : '').replace(/\\n{3,}/g, '\\n\\n').trim();
    return { url: location.href, title: document.title || '', text };
  });
}`;
}

function viaBrowser(url: string): Fetched {
  const raw = runPlaywright(browserSnippet(url)) as
    | { url?: string; title?: string; text?: string }
    | undefined;
  return {
    url: String(raw?.url ?? url),
    title: String(raw?.title ?? ""),
    text: String(raw?.text ?? ""),
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const url = args.positional[0];
  if (!url) {
    console.error("usage: webfetch <url> [--max N] [--browser] [--html]");
    process.exit(2);
  }

  let result: Fetched | null = null;

  if (!args.browser) {
    try {
      const res = await fetch(url, { headers: browserHeaders(), redirect: "follow" });
      const finalUrl = res.url || url;
      const ct = res.headers.get("content-type") || "";
      const body = await res.text();

      if (!/html|xml/i.test(ct) && !/^\s*</.test(body)) {
        // plain text / json / other — return as-is
        result = { url: finalUrl, title: "", text: body.trim() };
      } else if (args.html) {
        result = { url: finalUrl, title: titleFromHtml(body), text: body };
      } else {
        const text = stripHtml(body);
        if (!looksLikeSpaShell(body, text)) {
          result = { url: finalUrl, title: titleFromHtml(body), text };
        }
      }
    } catch {
      // escalate to the browser fallback
    }
  }

  if (!result) {
    result = viaBrowser(url);
  }

  if (!args.html && args.max > 0 && result.text.length > args.max) {
    result.text = result.text.slice(0, args.max) + "\n…[truncated]";
  }

  console.log(JSON.stringify(result, null, 2));
}

main().catch((e) => {
  console.error(String(e?.message ?? e));
  process.exit(1);
});
