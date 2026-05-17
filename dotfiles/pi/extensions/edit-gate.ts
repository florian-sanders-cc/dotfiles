/**
 * Edit Gate Extension
 *
 * Gates edit/write tools behind a lock. When locked, the agent can only
 * use read-only tools — it must explore, plan, and ask you to /go before
 * making any file changes.
 *
 * Usage:
 *   pi --plan          Start with editing locked (use /go to unlock)
 *   pi                 Normal mode (/go and /lock still available manually)
 *   pi -p "..."        Print mode — lock is ignored, edits flow through
 *
 * Commands:
 *   /go       Unlock editing (enable edit/write)
 *   /lock     Lock editing (disable edit/write)
 *   /toggle   Toggle the lock on/off
 *
 * Footer shows "🔒 edit-lock" when locked, nothing when unlocked.
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const GATED_TOOLS = ["edit", "write"];

export default function (pi: ExtensionAPI) {
  let locked = false;

  pi.registerFlag("plan", {
    description: "Start with editing locked (use /go to unlock)",
    type: "boolean",
    default: false,
  });

  function readOnlyToolNames(): string[] {
    return pi
      .getAllTools()
      .map((t) => t.name)
      .filter((n) => !GATED_TOOLS.includes(n));
  }

  function lock(ctx: ExtensionContext) {
    locked = true;
    pi.setActiveTools(readOnlyToolNames());
    ctx.ui.setStatus(
      "edit-gate",
      ctx.ui.theme.fg("warning", "🔒 edit-lock"),
    );
  }

  function unlock(ctx: ExtensionContext) {
    locked = false;
    pi.setActiveTools(pi.getAllTools().map((t) => t.name));
    ctx.ui.setStatus("edit-gate", undefined);
  }

  // ── Commands ──────────────────────────────────────────────

  pi.registerCommand("go", {
    description: "Unlock editing (enable edit/write)",
    handler: async (_args, ctx) => {
      unlock(ctx);
      ctx.ui.notify(
        "🔓 Editing unlocked — edit and write are now available.",
        "success",
      );
    },
  });

  pi.registerCommand("lock", {
    description: "Lock editing (disable edit/write)",
    handler: async (_args, ctx) => {
      lock(ctx);
      ctx.ui.notify(
        "🔒 Editing locked — edit and write are now disabled.",
        "info",
      );
    },
  });

  pi.registerCommand("toggle", {
    description: "Toggle editing lock on/off",
    handler: async (_args, ctx) => {
      if (locked) {
        unlock(ctx);
        ctx.ui.notify("🔓 Editing unlocked.", "success");
      } else {
        lock(ctx);
        ctx.ui.notify("🔒 Editing locked.", "info");
      }
    },
  });

  // ── Lifecycle ─────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    // Only auto-lock when --plan is set and we have a UI (not -p / json mode)
    if (pi.getFlag("plan") && ctx.hasUI) {
      lock(ctx);
    }
  });

  // Remind the model it's locked at the start of each agent turn
  pi.on("before_agent_start", async (_event, _ctx) => {
    if (!locked) return;

    return {
      message: {
        customType: "edit-gate-context",
        content: `[EDITING LOCKED]
You do not have access to edit or write tools right now.
Use read-only tools (read, bash, grep, find, ls) to explore the codebase,
understand the problem, and formulate a plan.

When you're ready to make changes, tell the user what you plan to do
and ask them to run /go to unlock editing.`,
        display: false,
      },
    };
  });

  // Clean up injected messages when unlocked
  pi.on("context", async (event) => {
    if (locked) return;

    return {
      messages: event.messages.filter((m) => {
        const msg = m as { customType?: string };
        return msg.customType !== "edit-gate-context";
      }),
    };
  });
}
