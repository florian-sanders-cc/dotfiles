---
name: web-search
description: Search the web and read web pages, returning standardized JSON. Use when the user asks to search the web, look something up online, find current or recent information, check docs/news, or fetch and read the contents of a URL.
allowed-tools: Bash(node:*) Bash(playwright-cli:*)
---

# Web search & page reading

Two commands. Each prints JSON to stdout. Do not drive the browser by hand — call these.

## Use the current year

The current date is given in the surrounding environment context (the line that
reads `Current date:`). When searching for **recent information, current events,
new releases, or "the latest"**, you MUST read that date and include the current
**year** in the query — not the previous year, and not a bare term.

- Example: it is 2026 and the user asks for "latest AI news" → search
  `AI news 2026`, *not* `AI news 2025` and *not* just `AI news`.
- Update the search query mid-session too: don't copy a year from earlier — re-check
  the `Current date:` line.
- Don't force the date into evergreen queries (e.g. `tokio async runtime` 2026),
  but when the user cares about *recent* / *current* / *new* / *latest*, add the year.

## Quick start

```bash
# search the web -> ranked JSON results
node ~/.agents/skills/web-search/bin/websearch.mts "rust async runtime comparison"

# read a page -> cleaned, readable text as JSON
node ~/.agents/skills/web-search/bin/webfetch.mts https://tokio.rs
```

Typical loop: `websearch` a query, pick a `url` from the results, `webfetch` that url.

## `websearch "<query>" [--num N] [--browser] [--site domain]`

Returns a ranked array:

```json
[
  { "rank": 1, "title": "…", "url": "https://…", "snippet": "…" }
]
```

- `--num N` — max results (default 8).
- `--site domain` — restrict results to a single domain (e.g. `--site github.com`).
  Any protocol/path on the value is stripped; only the host is kept. Works on both the
  fetch (DuckDuckGo) and browser (Bing) paths.
- Uses a plain `fetch` to DuckDuckGo's no-JS endpoint (fast, no browser). If that is
  blocked or returns nothing, it automatically falls back to a headless browser
  driving **Bing** (DuckDuckGo CAPTCHAs headless browsers; Bing does not).
- `--browser` — force the browser/Bing path directly.

## `webfetch <url> [--max N] [--browser] [--html]`

Returns:

```json
{ "url": "https://…", "title": "…", "text": "readable page text…" }
```

- Uses a plain `fetch` + HTML-to-text strip for static pages. If the page looks like
  an empty JS/SPA shell (little text, a `root`/`app`/`__next` mount), it automatically
  escalates to a headless browser and returns the rendered `innerText`.
- `--max N` — cap `text` length (default 15000 chars; `0` = no cap).
- `--browser` — force the rendered-browser path (use for known SPAs).
- `--html` — return raw HTML in `text` instead of stripped text.

## How it works (so you can trust the output)

- **fetch-first, browser-fallback.** The common path never launches a browser, so it
  is cheap and fast. The browser is `playwright-cli`'s hardened `-s=web` session,
  opened lazily and kept warm across calls — no setup needed.
- **Standardized JSON only.** You get titles/urls/snippets or `{url,title,text}`,
  never raw HTML to wade through. Pipe to `jq` if you want a single field.
- **Injection-safe.** Queries and URLs are embedded into the browser snippet as JSON
  literals, never string-spliced, so odd input can't execute code.

## Limitations

- Search is DuckDuckGo (fetch) / Bing (browser fallback) backed.
- `webfetch` text extraction is best-effort readable text, not full Readability —
  good for reading/summarizing, not for pixel-exact structure. Use `--html` if you
  need the markup.
- **Won't work under the `pi-write` sandbox** — its network allowlist only permits LLM
  providers, so search engines and arbitrary pages are unreachable. Run under
  `pi-plan` (all domains allowed) or unsandboxed.
- To clean up the background browser: `playwright-cli -s=web close`.
