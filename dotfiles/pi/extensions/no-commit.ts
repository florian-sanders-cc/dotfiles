/**
 * No-Commit Gate Extension
 *
 * Prevents the agent from creating git or jj commits by:
 *  1. Blocking `git commit`, `jj commit`/`ci`/`describe`/`squash`/`git push`
 *     at the bash tool-call level — the command never executes.
 *  2. Injecting a system-prompt instruction so the model doesn't waste
 *     turns trying to commit.
 *
 * Commands:
 *   /allow-commit    Disable the gate for this session
 *   /block-commit    Re-enable the gate for this session
 *
 * Flags:
 *   --allow-commit   Start with the gate disabled
 *
 * Footer shows "🔒 no-commit" when active, nothing when disabled.
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

// ─── Constants ─────────────────────────────────────────────────────────

const SYSTEM_INSTRUCTION = `[NO-COMMIT GATE]
You are prohibited from running any git commit, jj commit, jj ci, jj describe, jj squash, or jj git push commands. Do not attempt to create commits, amend commits, squash changes, or push to remotes. If the user asks you to commit, explain that commits are blocked by the no-commit gate and suggest using stashes, working copies, or other non-commit approaches.`;

const GIT_FLAG_TAKES_VALUE = new Set(["-c", "-C"]);
const JJ_FLAG_TAKES_VALUE = new Set(["-R", "--at-operation", "--at-op"]);
const JJ_COMMIT_SUBCOMMANDS = new Set(["commit", "ci", "describe", "squash"]);

// ─── Detection ─────────────────────────────────────────────────────────

/**
 * Normalize a bash command string for analysis.
 * Strips leading $, sudo, and environment variable prefixes.
 */
function normalize(cmd: string): string {
  let s = cmd.trim();
  s = s.replace(/^\$\s*/, "");
  s = s.replace(/^sudo\s+/, "");
  s = s.replace(/^(?:[A-Za-z_]\w*=\S+\s+)+/, "");
  return s;
}

/**
 * Split a command string into individual shell statements.
 * Handles &&, ||, ;, |, and newline separators.
 */
function splitStatements(cmd: string): string[] {
  return cmd.split(/\s*(?:&&|\|\||;|\||(?<!\\)\n)\s*/);
}

/**
 * Given a list of tokens and a start index, find the index of the
 * subcommand (the first non-flag token), skipping known flags that
 * consume a value argument.
 */
function findSubcommandIndex(tokens: string[], start: number, flagSet: Set<string>): number {
  let i = start;
  while (i < tokens.length) {
    const t = tokens[i];
    if (!t.startsWith("-")) return i;
    // Skip flag + its value for flags that take an argument
    if (flagSet.has(t) && i + 1 < tokens.length) {
      i += 2;
    } else {
      i += 1;
    }
  }
  return i;
}

/**
 * Returns true if the given bash command is a git/jj commit operation
 * that should be blocked.
 */
function isCommitCommand(command: string): boolean {
  const trimmed = command.trim();
  if (!trimmed) return false;

  // Quick bailout — must reference git or jj
  if (!/\b(?:git|jj)\b/.test(trimmed)) return false;

  const normalized = normalize(trimmed);
  const statements = splitStatements(normalized);

  for (const stmt of statements) {
    const s = stmt.trim();
    if (!s || s.startsWith("#")) continue;

    const tokens = s.split(/\s+/);
    if (tokens.length < 2) continue;

    // Strip leading subshell/group wrappers from the first token
    const first = tokens[0].replace(/^[({\[!]+/, "");
    if (!first) continue;

    // ── git commit ──────────────────────────────────────────
    if (first === "git") {
      const subIdx = findSubcommandIndex(tokens, 1, GIT_FLAG_TAKES_VALUE);
      if (subIdx < tokens.length && tokens[subIdx] === "commit") return true;
    }

    // ── jj commit / ci / describe / squash / git push ──────
    if (first === "jj") {
      const subIdx = findSubcommandIndex(tokens, 1, JJ_FLAG_TAKES_VALUE);
      if (subIdx < tokens.length) {
        const sub = tokens[subIdx];
        if (JJ_COMMIT_SUBCOMMANDS.has(sub)) return true;
        if (sub === "git" && subIdx + 1 < tokens.length && tokens[subIdx + 1] === "push") return true;
      }
    }
  }

  return false;
}

// ─── Extension ─────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  let active = true;

  // ── Flag ────────────────────────────────────────────────

  pi.registerFlag("allow-commit", {
    description: "Disable the no-commit gate (allow git/jj commits)",
    type: "boolean",
    default: false,
  });

  // ── Helpers ─────────────────────────────────────────────

  function enable(ctx: ExtensionContext) {
    active = true;
    if (ctx.hasUI) {
      ctx.ui.setStatus("no-commit", ctx.ui.theme.fg("warning", "🔒 no-commit"));
    }
  }

  function disable(ctx: ExtensionContext) {
    active = false;
    if (ctx.hasUI) {
      ctx.ui.setStatus("no-commit", undefined);
    }
  }

  // ── Commands ────────────────────────────────────────────

  pi.registerCommand("allow-commit", {
    description: "Disable the no-commit gate",
    handler: async (_args, ctx) => {
      disable(ctx);
      ctx.ui.notify("🔓 No-commit gate disabled — git/jj commits are now allowed.", "success");
    },
  });

  pi.registerCommand("block-commit", {
    description: "Re-enable the no-commit gate",
    handler: async (_args, ctx) => {
      enable(ctx);
      ctx.ui.notify("🔒 No-commit gate enabled — git/jj commits are now blocked.", "info");
    },
  });

  // ── Lifecycle ───────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    active = !pi.getFlag("allow-commit");
    if (active && ctx.hasUI) {
      ctx.ui.setStatus("no-commit", ctx.ui.theme.fg("warning", "🔒 no-commit"));
    }
  });

  // ── Agent events ────────────────────────────────────────

  /**
   * Inject a system-prompt instruction so the model knows not to commit.
   * This prevents wasted turns where it tries and gets blocked.
   */
  pi.on("before_agent_start", async (_event, _ctx) => {
    if (!active) return;

    return {
      message: {
        customType: "no-commit-context",
        content: SYSTEM_INSTRUCTION,
        display: false,
      },
    };
  });

  /**
   * Intercept bash tool calls and block commit commands.
   * This is the safety net — even if the model ignores the prompt
   * instruction, the command never executes.
   */
  pi.on("tool_call", async (event, ctx) => {
    if (!active) return;
    if (event.toolName !== "bash") return;

    const input = event.input as { command?: string; timeout?: number };
    if (!input.command) return;

    if (isCommitCommand(input.command)) {
      const preview =
        input.command.length > 80
          ? `${input.command.substring(0, 80)}…`
          : input.command;
      ctx.ui.notify(`🔒 Blocked commit: ${preview}`, "warning");
      return { block: true, reason: "Commits are blocked by the no-commit gate. Use /allow-commit to enable commits, or suggest a non-commit approach (stash, working copy, etc.)." };
    }
  });

  /**
   * Clean up the injected system-prompt message when the gate is disabled,
   * so the model is no longer instructed to avoid commits.
   */
  pi.on("context", async (event) => {
    if (active) return;

    return {
      messages: event.messages.filter((m) => {
        const msg = m as { customType?: string };
        return msg.customType !== "no-commit-context";
      }),
    };
  });
}
