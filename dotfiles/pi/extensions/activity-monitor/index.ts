/**
 * activity-monitor — Shows current agent activity and elapsed time
 *
 * Displays a persistent widget showing what the agent is currently doing
 * and how long it's been since the current action started.
 * Helps detect when the agent is going in the wrong direction.
 *
 * States shown:
 *   ● Thinking… (12.3s)             — LLM is generating a response
 *   › cat src/main.ts (45.2s)       — A tool is running (with context)
 *   ✓ cat src/main.ts (1.2s)        — A tool just completed (briefly)
 *   (hidden when idle)               — Nothing shown while waiting for input
 */

import type { ExtensionAPI, ExtensionContext, Theme } from "@mariozechner/pi-coding-agent";

// ─── Types ─────────────────────────────────────────────────────────────

type ActivityState =
  | { status: "idle" }
  | { status: "thinking"; since: number }
  | { status: "running_tool"; toolName: string; description: string; since: number }
  | { status: "tool_result"; toolName: string; description: string; since: number };

// ─── Helpers ───────────────────────────────────────────────────────────

/** Try to extract a short, meaningful description of what a tool is doing. */
function describeToolCall(toolName: string, input: Record<string, unknown>): string {
  switch (toolName) {
    case "bash": {
      const cmd = typeof input.command === "string" ? input.command.trim() : "";
      return summarizeCommand(cmd);
    }
    case "read": {
      const path = typeof input.path === "string" ? input.path : "?";
      return `Reading ${shortPath(path)}`;
    }
    case "write": {
      const path = typeof input.path === "string" ? input.path : "?";
      return `Writing ${shortPath(path)}`;
    }
    case "edit": {
      const path = typeof input.path === "string" ? input.path : "?";
      const edits = Array.isArray(input.edits) ? input.edits.length : 0;
      if (edits > 1) return `Editing ${shortPath(path)} (${edits} blocks)`;
      return `Editing ${shortPath(path)}`;
    }
    case "grep": {
      const pattern = typeof input.pattern === "string" ? input.pattern : "?";
      return `Grep ${truncateMid(pattern, 30)}`;
    }
    case "find": {
      const path = typeof input.path === "string" ? input.path : "?";
      const pattern = typeof input.pattern === "string" ? input.pattern : "";
      if (pattern) return `Find ${truncateMid(pattern, 20)} in ${shortPath(path)}`;
      return `Listing files in ${shortPath(path)}`;
    }
    case "ls": {
      const path = typeof input.path === "string" ? input.path : "?";
      return `Listing ${shortPath(path)}`;
    }
    default:
      return toolName;
  }
}

/** Summarize a shell command into a one-liner. */
function summarizeCommand(cmd: string): string {
  if (!cmd) return "bash";
  const firstLine = cmd.split("\n")[0] ?? cmd;
  const truncated = firstLine.length > 55 ? firstLine.substring(0, 52) + "…" : firstLine;
  return truncated;
}

/** Shorten a file path for display (show filename, keep dir context if small). */
function shortPath(p: string): string {
  if (p.length <= 40) return p;
  const parts = p.split("/");
  if (parts.length <= 2) return p.substring(0, 37) + "…";
  // Show last two parts
  return "…/" + parts.slice(-2).join("/");
}

/** Truncate a string in the middle if it's too long. */
function truncateMid(s: string, maxLen: number): string {
  if (s.length <= maxLen) return s;
  const half = Math.floor((maxLen - 1) / 2);
  return s.substring(0, half) + "…" + s.substring(s.length - half);
}

function formatElapsed(ms: number): string {
  const totalSec = ms / 1000;
  if (totalSec < 60) {
    return `${totalSec.toFixed(1)}s`;
  }
  if (totalSec < 3600) {
    const min = Math.floor(totalSec / 60);
    const sec = totalSec % 60;
    return `${min}m ${sec.toFixed(0)}s`;
  }
  const h = Math.floor(totalSec / 3600);
  const m = Math.floor((totalSec % 3600) / 60);
  return `${h}h ${m}m`;
}

function renderWidget(state: ActivityState, theme: Theme): string[] {
  const now = Date.now();
  const lines: string[] = [];

  switch (state.status) {
    case "idle":
      // Nothing to show when idle — widget is cleared
      return [];

    case "thinking": {
      const elapsed = formatElapsed(now - state.since);
      lines.push(
        `${theme.fg("accent", "●")} ${theme.fg("muted", "Thinking…")} ${theme.fg("dim", `(${elapsed})`)}`,
      );
      break;
    }

    case "running_tool": {
      const elapsed = formatElapsed(now - state.since);
      const icon = state.toolName === "bash" ? "›" : "→";
      lines.push(
        `${theme.fg("warning", icon)} ${theme.fg("muted", state.description)} ${theme.fg("dim", `(${elapsed})`)}`,
      );
      break;
    }

    case "tool_result": {
      const elapsed = formatElapsed(now - state.since);
      lines.push(
        `${theme.fg("success", "✓")} ${theme.fg("dim", state.description)} ${theme.fg("dim", `(${elapsed})`)}`,
      );
      break;
    }
  }

  return lines;
}

// ─── Extension ─────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  let state: ActivityState = { status: "idle" };
  let intervalTimer: ReturnType<typeof setInterval> | null = null;
  let resultTimeout: ReturnType<typeof setTimeout> | null = null;
  let clearTimeoutId: ReturnType<typeof setTimeout> | null = null;

  /** Update (or clear) the widget above the editor. */
  function updateWidget(ctx: ExtensionContext) {
    if (!ctx.hasUI) return;
    const lines = renderWidget(state, ctx.ui.theme);
    if (lines.length > 0) {
      ctx.ui.setWidget("activity-monitor", lines);
    } else {
      ctx.ui.setWidget("activity-monitor", undefined);
    }
  }

  /** Start a 500ms interval that refreshes the widget (shows live elapsed). */
  function startInterval(ctx: ExtensionContext) {
    stopInterval();
    intervalTimer = setInterval(() => updateWidget(ctx), 500);
  }

  function stopInterval() {
    if (intervalTimer !== null) {
      clearInterval(intervalTimer);
      intervalTimer = null;
    }
  }

  function clearTimers() {
    stopInterval();
    if (resultTimeout !== null) {
      clearTimeout(resultTimeout);
      resultTimeout = null;
    }
    if (clearTimeoutId !== null) {
      clearTimeout(clearTimeoutId);
      clearTimeoutId = null;
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    state = { status: "idle" };
    updateWidget(ctx);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    clearTimers();
    if (ctx.hasUI) {
      ctx.ui.setWidget("activity-monitor", undefined);
    }
  });

  // ── Agent events ──────────────────────────────────────────────────

  pi.on("agent_start", async (_event, ctx) => {
    clearTimers();
    state = { status: "thinking", since: Date.now() };
    startInterval(ctx);
    updateWidget(ctx);
  });

  pi.on("tool_call", async (event, ctx) => {
    clearTimeout(resultTimeout);
    const description = describeToolCall(event.toolName, event.input as Record<string, unknown>);
    state = { status: "running_tool", toolName: event.toolName, description, since: Date.now() };
    updateWidget(ctx);
    // Ensure interval is running (in case agent_start was missed, e.g. extension loaded mid-session)
    if (!intervalTimer) startInterval(ctx);
  });

  pi.on("tool_result", async (event, ctx) => {
    clearTimeout(resultTimeout);
    const description =
      state.status === "running_tool"
        ? state.description
        : describeToolCall(event.toolName, event.input as Record<string, unknown>);
    state = { status: "tool_result", toolName: event.toolName, description, since: Date.now() };
    updateWidget(ctx);
    // After showing the "✓ tool (elapsed)" briefly, revert to "thinking"
    // since the agent may call more tools or generate more text.
    resultTimeout = setTimeout(() => {
      if (state.status === "tool_result") {
        state = { status: "thinking", since: Date.now() };
        updateWidget(ctx);
      }
    }, 2000);
  });

  pi.on("agent_end", async (_event, ctx) => {
    // Stop the live counter but keep the last state frozen so users see
    // the final elapsed time (e.g. "Thinking… (12.3s)" or "✓ bash (1.2s)").
    stopInterval();
    clearTimeout(resultTimeout);
    clearTimeoutId = setTimeout(() => {
      state = { status: "idle" };
      if (ctx.hasUI) {
        ctx.ui.setWidget("activity-monitor", undefined);
      }
    }, 3000);
    updateWidget(ctx);
  });
}
