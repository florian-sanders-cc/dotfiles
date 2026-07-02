/**
 * session-rename — /rename a session from the WHOLE conversation
 *
 * pi's session picker shows `session.name ?? session.firstMessage`, so by default
 * a session is labelled by its opening message — which rarely reflects what the
 * conversation actually became. This command reads the entire conversation so far,
 * asks a small/fast model for a short title, and sets it via pi.setSessionName().
 *
 * Usage: /rename
 *
 * Config (env overrides, mirroring bin/refactor.sh's PI_REFACTOR_MODEL):
 *   PI_RENAME_PROVIDER  (default "opencode-go")
 *   PI_RENAME_MODEL     (default "deepseek-flash" — confirm the exact id via ctrl+p)
 */

import { complete } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// ─── Config ────────────────────────────────────────────────────────────
const TITLE_PROVIDER = process.env.PI_RENAME_PROVIDER ?? "opencode-go";
const TITLE_MODEL = process.env.PI_RENAME_MODEL ?? "deepseek-v4-flash";
const MAX_TITLE_LEN = 60;
const MAX_CONVO_CHARS = 40_000; // cap huge histories before sending

// ─── Conversation extraction (adapted from examples/extensions/summarize.ts) ──

type ContentBlock = { type?: string; text?: string };

type SessionEntry = {
  type: string;
  message?: { role?: string; content?: unknown };
};

/** Pull the plain-text parts out of a message's content. */
function extractTextParts(content: unknown): string[] {
  if (typeof content === "string") return [content];
  if (!Array.isArray(content)) return [];

  const parts: string[] = [];
  for (const part of content) {
    if (!part || typeof part !== "object") continue;
    const block = part as ContentBlock;
    if (block.type === "text" && typeof block.text === "string") {
      parts.push(block.text);
    }
  }
  return parts;
}

/** Flatten user/assistant text messages into a single labelled transcript. */
function buildConversationText(entries: SessionEntry[]): string {
  const sections: string[] = [];

  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message?.role) continue;

    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") continue;

    const text = extractTextParts(entry.message.content).join("\n").trim();
    if (text.length > 0) {
      sections.push(`${role === "user" ? "User" : "Assistant"}: ${text}`);
    }
  }

  return sections.join("\n\n");
}

/** Keep the tail of a long transcript — the latest direction matters most. */
function capToTail(text: string, maxChars: number): string {
  if (text.length <= maxChars) return text;
  return text.slice(text.length - maxChars);
}

function buildTitlePrompt(conversationText: string): string {
  return [
    "Write a short, descriptive title for this conversation so I can find it later in a session list.",
    "Rules:",
    "- A single line, at most 8 words.",
    "- Describe the whole conversation, not just the first message.",
    "- Plain text only: no quotes, no surrounding punctuation, no trailing period, no markdown.",
    "- Output ONLY the title.",
    "",
    "<conversation>",
    conversationText,
    "</conversation>",
  ].join("\n");
}

/** First line, stripped of wrapping quotes/backticks, trimmed and clamped. */
function sanitizeTitle(raw: string): string {
  let title = (raw.split("\n").find((l) => l.trim().length > 0) ?? "").trim();
  title = title.replace(/^["'`]+|["'`]+$/g, "").trim();
  if (title.length > MAX_TITLE_LEN) title = title.slice(0, MAX_TITLE_LEN).trim();
  return title;
}

// ─── Extension ─────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerCommand("rename", {
    description: "Rename this session from the whole conversation",
    handler: async (_args, ctx) => {
      const notify = (msg: string, level: "info" | "warning" | "error") => {
        if (ctx.hasUI) ctx.ui.notify(msg, level);
      };

      const branch = ctx.sessionManager.getBranch() as SessionEntry[];
      const conversationText = capToTail(buildConversationText(branch), MAX_CONVO_CHARS);

      if (!conversationText.trim()) {
        notify("No conversation to name yet", "warning");
        return;
      }

      // Resolve against the runtime registry (includes custom providers like
      // opencode-go) rather than the static builtin catalog.
      const model = ctx.modelRegistry.find(TITLE_PROVIDER, TITLE_MODEL);
      if (!model) {
        notify(
          `Model ${TITLE_PROVIDER}/${TITLE_MODEL} not found — set PI_RENAME_MODEL`,
          "warning",
        );
        return;
      }

      const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
      if (!auth.ok) {
        notify(auth.error, "warning");
        return;
      }
      if (!auth.apiKey) {
        notify(`No API key for ${TITLE_PROVIDER}/${TITLE_MODEL}`, "warning");
        return;
      }

      notify("Generating session name…", "info");

      let response;
      try {
        response = await complete(
          model,
          {
            messages: [
              {
                role: "user" as const,
                content: [{ type: "text" as const, text: buildTitlePrompt(conversationText) }],
                timestamp: Date.now(),
              },
            ],
          },
          { apiKey: auth.apiKey, headers: auth.headers, reasoningEffort: "low" },
        );
      } catch (err) {
        notify(`Rename failed: ${err instanceof Error ? err.message : String(err)}`, "error");
        return;
      }

      const rawTitle = response.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("");

      const title = sanitizeTitle(rawTitle);
      if (!title) {
        notify("Model returned an empty title", "warning");
        return;
      }

      pi.setSessionName(title);
      notify(`Session renamed: ${title}`, "info");
    },
  });
}
