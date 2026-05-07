/**
 * nvim-bridge — Pi ↔ Neovim integration
 *
 * Connects Pi to a running Neovim instance, allowing Pi to pull context
 * (buffers, selection, cursor) on demand via explicit tools.
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { createRequire } from "node:module";

// ── Load neovim (must happen before console is patched) ─────────────
// The neovim package monkey-patches console on import. We save the
// original console methods, load the package via require, then restore.
const _console = {
  log: console.log.bind(console),
  error: console.error.bind(console),
  warn: console.warn.bind(console),
  info: console.info.bind(console),
  debug: console.debug.bind(console),
};

// Use createRequire with __filename so jiti resolves from this extension's node_modules.
const localRequire = createRequire(__filename);
const neovimModule = localRequire("neovim");
const attach = neovimModule.attach as (opts: { socket: string }) => any;

// Restore original console.
console.log = _console.log;
console.error = _console.error;
console.warn = _console.warn;
console.info = _console.info;
console.debug = _console.debug;

// ─── Types ───────────────────────────────────────────────────────────

interface BufferInfo {
  bufnr: number;
  name: string;
  modified: boolean;
  current: boolean;
  loaded: boolean;
}

interface ConnectionState {
  socketPath: string | null;
  connected: boolean;
  cwd: string | null;
  currentBufferName: string | null;
}

// ─── State ───────────────────────────────────────────────────────────

let nvim: any = null; // NeovimClient (dynamic import to work around console patching)
let state: ConnectionState = {
  socketPath: null,
  connected: false,
  cwd: null,
  currentBufferName: null,
};
let toolsRegistered = false;

// ── UI awareness ──────────────────────────────────────────────────────
let currentCtx: ExtensionContext | null = null;
let pollInterval: ReturnType<typeof setInterval> | null = null;
let transportCloseHandler: (() => void) | null = null;

// ─── Helpers ─────────────────────────────────────────────────────────

function updateStatus(ctx: ExtensionContext) {
  if (!ctx.hasUI) return;
  const theme = ctx.ui.theme;

  if (!state.connected || !nvim) {
    ctx.ui.setStatus(
      "nvim-bridge",
      theme.fg("dim", "○") + " " + theme.fg("dim", "nvim: disconnected"),
    );
    ctx.ui.setWidget("nvim-bridge", undefined);
    return;
  }

  // Fire-and-forget async refresh of full buffer metadata for the widget.
  updateStatusWidget(ctx).catch(() => {});
}

async function updateStatusWidget(ctx: ExtensionContext) {
  if (!ctx.hasUI || !state.connected || !nvim) return;
  const theme = ctx.ui.theme;

  try {
    const currentName = state.currentBufferName || "?";

    // Get cursor position (1-indexed line number)
    const cursor = (await nvim.call("getpos", ["."])) as [number, number, number, number];
    const cursorLine = cursor[1];

    // Base status: "● main.ts:42"
    let statusText = theme.fg("success", "●") + " " + theme.fg("dim", `${currentName}:${cursorLine}`);

    // Check for active visual mode / selection
    const currentMode = (await nvim.eval("mode()")) as string;
    const inVisual =
      currentMode === "v" ||
      currentMode === "V" ||
      currentMode === "\x16";

    if (inVisual) {
      const startPos = (await nvim.eval("getpos(\"v\")")) as [number, number, number, number];
      const endPos = (await nvim.eval("getpos(\".\")")) as [number, number, number, number];

      let startLine = startPos[1];
      let endLine = endPos[1];
      let startCol = startPos[2];
      let endCol = endPos[2];

      // Normalize: 'v' is always the start of the visual area,
      // '.' is the cursor (may be before 'v' for backward selection).
      if (startLine > endLine || (startLine === endLine && startCol > endCol)) {
        [startLine, endLine] = [endLine, startLine];
        [startCol, endCol] = [endCol, startCol];
      }

      if (startLine === endLine) {
        statusText += theme.fg("warning", ` (${startLine}:${startCol}-${endCol})`);
      } else {
        statusText += theme.fg("warning", ` (L${startLine}-${endLine})`);
      }
    }

    ctx.ui.setStatus("nvim-bridge", statusText);
    ctx.ui.setWidget("nvim-bridge", undefined);
  } catch {
    // Best effort — refreshNvimState already handles connection errors.
  }
}

function updateDisconnectedUI() {
  const ctx = currentCtx;
  if (!ctx?.hasUI) return;
  const theme = ctx.ui.theme;
  ctx.ui.setStatus(
    "nvim-bridge",
    theme.fg("dim", "○") + " " + theme.fg("dim", "nvim: disconnected"),
  );
  ctx.ui.setWidget("nvim-bridge", undefined);
}

function ensureConnected() {
  if (!nvim || !state.connected) {
    throw new Error(
      "Not connected to Neovim. Use /watch-neovim to connect to a running instance.",
    );
  }
  return nvim;
}

async function refreshNvimState() {
  if (!nvim || !state.connected) return;
  try {
    state.cwd = (await nvim.call("getcwd")) as string;
    const bufName = (await nvim.call("bufname", ["%"])) as string;
    state.currentBufferName = bufName || path.basename(state.cwd || "") || "<unknown>";
  } catch {
    state.connected = false;
  }
}

// ── Transport monitoring ──────────────────────────────────────────────

function watchTransport(client: any) {
  const transport = client.transport;
  if (!transport?.reader) return;

  transportCloseHandler = () => {
    state.connected = false;
    stopPolling();
    updateDisconnectedUI();
  };

  transport.reader.on("close", transportCloseHandler);
  transport.reader.on("end", transportCloseHandler);
  transport.reader.on("error", transportCloseHandler);
}

function unwatchTransport(client: any) {
  const transport = client?.transport;
  if (!transport?.reader || !transportCloseHandler) return;
  transport.reader.off("close", transportCloseHandler);
  transport.reader.off("end", transportCloseHandler);
  transport.reader.off("error", transportCloseHandler);
  transportCloseHandler = null;
}

// ── UI polling ────────────────────────────────────────────────────────
// Polls Neovim every 2s to catch buffer switches and edits.
// nvim_buf_attach would be more efficient but doesn't fire on BufEnter.

function startPolling() {
  if (pollInterval) return;
  pollInterval = setInterval(async () => {
    if (!state.connected || !nvim) {
      stopPolling();
      return;
    }
    try {
      await refreshNvimState();
      const ctx = currentCtx;
      if (ctx) await updateStatusWidget(ctx);
    } catch {
      // Transport error will be caught by watchTransport close handler.
    }
  }, 2000);
}

function stopPolling() {
  if (pollInterval) {
    clearInterval(pollInterval);
    pollInterval = null;
  }
}

// ─── Discovery ───────────────────────────────────────────────────────

function discoverSockets(): string[] {
  const uid = os.userInfo().uid;
  const runDir = `/run/user/${uid}/`;
  try {
    return fs
      .readdirSync(runDir)
      .filter((f) => /^nvim\.\d+\.\d+$/.test(f))
      .map((f) => path.join(runDir, f));
  } catch {
    return [];
  }
}

/** Probe a Neovim socket: connect briefly, get cwd + buffer name, then disconnect. */
async function probeInstance(
  socketPath: string,
  attachFn: (opts: { socket: string }) => any,
): Promise<{ cwd: string; bufName: string } | null> {
  let client: any = null;
  try {
    client = attachFn({ socket: socketPath });
    await client.generateApi();
    const cwd = (await client.call("getcwd")) as string;
    const bufName = (await client.call("bufname", ["%"])) as string;
    return { cwd, bufName: bufName || "<no name>" };
  } catch {
    return null;
  } finally {
    // Clean up the probe connection without quitting Neovim.
    if (client) {
      try {
        const transport = (client as any).transport;
        // Suppress errors on the reader during cleanup to avoid
        // ERR_STREAM_PREMATURE_CLOSE from the active msgpack async iterator.
        if (transport?.reader) {
          transport.reader.on('error', () => {});
        }
        if (transport?.close) {
          transport.close();
        } else if (transport?.writer) {
          transport.writer.end();
        }
      } catch {
        // Best effort cleanup.
      }
    }
  }
}

// ─── Connection ──────────────────────────────────────────────────────

async function connect(socketPath: string, attachFn: (opts: { socket: string }) => any) {
  // Disconnect any existing connection first.
  disconnect();

  try {
    nvim = attachFn({ socket: socketPath });
    await nvim.generateApi();

    state.socketPath = socketPath;
    state.connected = true;
    await refreshNvimState();
    watchTransport(nvim);
    startPolling();
    return true;
  } catch {
    nvim = null;
    state.connected = false;
    state.socketPath = null;
    return false;
  }
}

function disconnect() {
  stopPolling();
  if (nvim) {
    unwatchTransport(nvim);
    try {
      const transport = nvim.transport;
      // Suppress errors on the reader during cleanup to avoid
      // ERR_STREAM_PREMATURE_CLOSE from the active msgpack async iterator.
      if (transport?.reader) {
        transport.reader.on('error', () => {});
      }
      if (transport?.close) {
        transport.close();
      } else if (transport?.writer) {
        transport.writer.end();
      }
    } catch {
      // Best effort.
    }
    nvim = null;
  }
  state.connected = false;
  state.socketPath = null;
  state.cwd = null;
  state.currentBufferName = null;
  // Clear widget if ctx is still available.
  if (currentCtx?.hasUI) {
    currentCtx.ui.setWidget("nvim-bridge", undefined);
  }
}

// ─── Tools ───────────────────────────────────────────────────────────

function registerTools(pi: ExtensionAPI) {
  // ── nvim_list_buffers ──────────────────────────────────────────

  pi.registerTool({
    name: "nvim_list_buffers",
    label: "Nvim List Buffers",
    description:
      "List all open buffers in the connected Neovim instance. Returns buffer number, name, modified flag, and whether it is the current buffer.",
    parameters: Type.Object({}),
    async execute() {
      const client = ensureConnected();
      const bufinfo = (await client.call("getbufinfo")) as any[];

      const currentBufName = (await client.call("bufname", ["%"])) as string;
      const results: BufferInfo[] = [];

      for (const info of bufinfo) {
        results.push({
          bufnr: info.bufnr as number,
          name: (info.name as string) || "[No Name]",
          modified: !!(info.changed as number),
          current: info.name === currentBufName,
          loaded: !!(info.loaded as number),
        });
      }

      if (results.length === 0) {
        return {
          content: [{ type: "text", text: "No buffers open." }],
          details: { buffers: [] },
        };
      }

      const text = results
        .map(
          (b) =>
            `${b.current ? "▶" : " "} ${String(b.bufnr).padStart(3)} ${b.modified ? "[+]" : "[ ]"} ${b.name}`,
        )
        .join("\n");

      return {
        content: [{ type: "text", text }],
        details: { buffers: results },
      };
    },
  });

  // ── nvim_get_current_buffer ────────────────────────────────────

  pi.registerTool({
    name: "nvim_get_current_buffer",
    label: "Nvim Get Current Buffer",
    description:
      "Get the contents of the currently focused buffer in Neovim. Returns up to 300 lines (truncated if longer). Lines are numbered.",
    parameters: Type.Object({}),
    async execute() {
      const client = ensureConnected();
      const buf = await client.buffer;
      const name: string = await buf.name;
      const lines: string[] = await buf.lines;

      const MAX_LINES = 300;
      const truncated = lines.length > MAX_LINES;
      const displayLines = truncated ? lines.slice(0, MAX_LINES) : lines;

      let text = `Buffer: ${name || "[No Name]"} (${lines.length} lines)\n`;
      if (truncated) {
        text += `[Showing first ${MAX_LINES} of ${lines.length} lines]\n`;
      }
      text += displayLines.map((l, i) => `${i + 1}\t${l}`).join("\n");
      if (truncated) {
        text += `\n[Truncated: ${lines.length - MAX_LINES} more lines not shown]`;
      }

      return {
        content: [{ type: "text", text }],
        details: { bufferName: name, totalLines: lines.length, truncated },
      };
    },
  });

  // ── nvim_get_selection ─────────────────────────────────────────

  pi.registerTool({
    name: "nvim_get_selection",
    label: "Nvim Get Selection",
    description:
      "Get the text of the current visual selection in Neovim. Returns an empty message if nothing is selected.",
    parameters: Type.Object({}),
    async execute() {
      const client = ensureConnected();

      try {
        // Check whether we are currently in visual/select mode.
        // The '< and '> marks are only updated when visual mode is
        // exited; if the user is still in visual mode they still
        // point to the *previous* selection.  When in visual mode
        // we use the live marks 'v' (start) and '.' (cursor=end).
        const currentMode = (await client.eval("mode()")) as string;
        const inVisualMode =
          currentMode === "v" ||
          currentMode === "V" ||
          currentMode === "\x16" ||
          currentMode === "s" ||
          currentMode === "S" ||
          currentMode === "\x13";

        let startPos: [number, number, number, number];
        let endPos: [number, number, number, number];

        if (inVisualMode) {
          startPos = (await client.eval("getpos(\"v\")")) as [
            number,
            number,
            number,
            number,
          ];
          endPos = (await client.eval("getpos(\".\")")) as [
            number,
            number,
            number,
            number,
          ];

          // Normalize: 'v' is always the start of the visual area,
          // '.' is the cursor (may be before 'v' for backward selection).
          if (
            startPos[1] > endPos[1] ||
            (startPos[1] === endPos[1] && startPos[2] > endPos[2])
          ) {
            [startPos, endPos] = [endPos, startPos];
          }
        } else {
          startPos = (await client.eval("getpos(\"'<\")")) as [
            number,
            number,
            number,
            number,
          ];
          endPos = (await client.eval("getpos(\"'>\")")) as [
            number,
            number,
            number,
            number,
          ];
        }

        const startLine = startPos[1] - 1; // 0-indexed
        const endLine = endPos[1] - 1;

        if (
          startLine < 0 ||
          endLine < 0 ||
          (startLine === endLine && startPos[2] === endPos[2])
        ) {
          return {
            content: [{ type: "text", text: "(No selection)" }],
            details: { hasSelection: false },
          };
        }

        const buf = await client.buffer;
        const lines: string[] = await buf.getLines({
          start: startLine,
          end: endLine + 1,
          strictIndexing: true,
        });

        if (lines.length === 0) {
          return {
            content: [{ type: "text", text: "(Empty selection)" }],
            details: { hasSelection: true, lineCount: 0 },
          };
        }

        // Trim partial first/last lines based on column marks.
        const startCol = startPos[2] - 1;
        const endCol = endPos[2] - 1;

        if (startLine === endLine) {
          lines[0] = lines[0].substring(startCol, endCol + 1);
        } else {
          if (startCol > 0) lines[0] = lines[0].substring(startCol);
          const lastIdx = lines.length - 1;
          if (endCol < (lines[lastIdx]?.length ?? 0)) {
            lines[lastIdx] = lines[lastIdx].substring(0, endCol + 1);
          }
        }

        return {
          content: [{ type: "text", text: lines.join("\n") }],
          details: { hasSelection: true, lineCount: lines.length },
        };
      } catch {
        return {
          content: [{ type: "text", text: "(No selection)" }],
          details: { hasSelection: false },
        };
      }
    },
  });

  // ── nvim_get_cursor_context ────────────────────────────────────

  pi.registerTool({
    name: "nvim_get_cursor_context",
    label: "Nvim Get Cursor Context",
    description:
      "Get the current cursor line plus surrounding context (5 lines above, 5 below) from the focused Neovim buffer.",
    parameters: Type.Object({}),
    async execute() {
      const client = ensureConnected();
      const win = await client.window;
      const cursor: [number, number] = await win.cursor;
      const buf = await win.buffer;
      const name: string = await buf.name;
      const totalLines: number = await buf.length;

      const cursorLine = cursor[0] - 1; // 0-indexed
      const contextStart = Math.max(0, cursorLine - 5);
      const contextEnd = Math.min(totalLines, cursorLine + 6); // exclusive

      const lines: string[] = await buf.getLines({
        start: contextStart,
        end: contextEnd,
        strictIndexing: true,
      });

      let text = `Buffer: ${name || "[No Name]"}\n`;
      text += `Cursor: line ${cursor[0]}, column ${cursor[1]}\n`;
      text += `---\n`;
      for (let i = 0; i < lines.length; i++) {
        const lineNum = contextStart + i + 1;
        const marker = lineNum === cursor[0] ? ">" : " ";
        text += `${marker} ${String(lineNum).padStart(4, " ")}\t${lines[i]}\n`;
      }

      return {
        content: [{ type: "text", text }],
        details: {
          cursorLine: cursor[0],
          cursorCol: cursor[1],
          bufferName: name,
          totalLines,
        },
      };
    },
  });

  // ── nvim_read_file ─────────────────────────────────────────────

  pi.registerTool({
    name: "nvim_read_file",
    label: "Nvim Read File",
    description:
      "Read a specific file. If the file is open in Neovim, reads the buffer contents (up to 500 lines). Otherwise reads from the filesystem. Path can be absolute or relative to the Neovim current working directory.",
    parameters: Type.Object({
      path: Type.String({
        description:
          "File path to read. Absolute or relative to the Neovim cwd.",
      }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      // Normalize @ prefix (some models include it)
      let requestedPath = params.path;
      if (requestedPath.startsWith("@")) {
        requestedPath = requestedPath.slice(1);
      }

      // Resolve path relative to nvim cwd or pi cwd.
      let resolvedPath: string;
      if (path.isAbsolute(requestedPath)) {
        resolvedPath = requestedPath;
      } else if (state.cwd) {
        resolvedPath = path.resolve(state.cwd, requestedPath);
      } else {
        resolvedPath = path.resolve(ctx.cwd, requestedPath);
      }

      // Try to read from Neovim buffers.
      if (nvim && state.connected) {
        try {
          const allBuffers: any[] = await nvim.buffers;
          for (const buf of allBuffers) {
            const name: string = await buf.name;
            if (!name) continue;
            if (name === resolvedPath || path.resolve(name) === resolvedPath) {
              const lines: string[] = await buf.lines;
              const MAX_LINES = 500;
              const truncated = lines.length > MAX_LINES;
              const displayLines = truncated ? lines.slice(0, MAX_LINES) : lines;

              let text = `File: ${name} (from Neovim buffer, ${lines.length} lines)\n`;
              if (truncated)
                text += `[Showing first ${MAX_LINES} of ${lines.length} lines]\n`;
              text += displayLines.map((l, i) => `${i + 1}\t${l}`).join("\n");
              if (truncated)
                text += `\n[Truncated: ${lines.length - MAX_LINES} more lines not shown]`;

              return {
                content: [{ type: "text", text }],
                details: { source: "nvim", totalLines: lines.length, truncated },
              };
            }
          }
        } catch {
          // Fall through to filesystem read.
        }
      }

      // Filesystem fallback.
      try {
        const content = fs.readFileSync(resolvedPath, "utf-8");
        const lines = content.split("\n");
        const MAX_LINES = 2000;
        const MAX_BYTES = 50 * 1024;

        let display = content;
        let truncated = false;

        if (content.length > MAX_BYTES) {
          display = content.substring(0, MAX_BYTES);
          truncated = true;
        }
        if (display.split("\n").length > MAX_LINES) {
          display = display
            .split("\n")
            .slice(0, MAX_LINES)
            .join("\n");
          truncated = true;
        }

        let text = `File: ${resolvedPath} (from filesystem, ${lines.length} lines)\n`;
        text += display;
        if (truncated) text += `\n[Output truncated]`;

        return {
          content: [{ type: "text", text }],
          details: { source: "filesystem", totalLines: lines.length, truncated },
        };
      } catch (err: any) {
        throw new Error(`Cannot read ${resolvedPath}: ${err.message}`);
      }
    },
  });
}

// ─── Extension Factory ──────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // ── Commands ────────────────────────────────────────────────────

  pi.registerCommand("watch-neovim", {
    description: "Connect to a running Neovim instance",
    handler: async (_args, ctx) => {
      currentCtx = ctx;
      if (!ctx.hasUI) {
        ctx.ui.notify("/watch-neovim requires interactive mode", "error");
        return;
      }

      const sockets = discoverSockets();
      if (sockets.length === 0) {
        ctx.ui.notify(
          `No Neovim instances found. Expected sockets in /run/user/${os.userInfo().uid}/`,
          "error",
        );
        updateStatus(ctx);
        return;
      }

      ctx.ui.setStatus("nvim-bridge", "Scanning Neovim instances...");

      // Probe each socket for cwd + buffer name.
      const choices: Array<{ socket: string; label: string }> = [];
      for (const socketPath of sockets) {
        const info = await probeInstance(socketPath, attach);
        const pid = path.basename(socketPath).split(".")[1];
        if (info) {
          choices.push({
            socket: socketPath,
            label: `[${pid}] ${info.cwd} — ${info.bufName}`,
          });
        } else {
          choices.push({
            socket: socketPath,
            label: `[${pid}] (unresponsive)`,
          });
        }
      }

      if (choices.length === 0) {
        ctx.ui.notify("No responsive Neovim instances found.", "error");
        updateStatus(ctx);
        return;
      }

      const selected = await ctx.ui.select(
        "Select Neovim instance:",
        choices.map((c) => c.label),
      );

      if (!selected) {
        updateStatus(ctx);
        return;
      }

      const chosen = choices.find((c) => c.label === selected);
      if (!chosen) {
        updateStatus(ctx);
        return;
      }

      ctx.ui.setStatus("nvim-bridge", "Connecting...");
      const ok = await connect(chosen.socket, attach);

      if (ok) {
        // Register tools on first successful connection.
        if (!toolsRegistered) {
          registerTools(pi);
          toolsRegistered = true;
        }

        // Persist socket path.
        pi.appendEntry("nvim-bridge", { socketPath: chosen.socket });

        updateStatus(ctx);
        ctx.ui.notify(`Connected: ${state.currentBufferName}`, "success");
      } else {
        ctx.ui.notify("Failed to connect to Neovim instance.", "error");
        updateStatus(ctx);
      }
    },
  });

  pi.registerCommand("unwatch-neovim", {
    description: "Disconnect from Neovim",
    handler: async (_args, ctx) => {
      if (state.connected) {
        disconnect();
        // Clear persisted connection.
        pi.appendEntry("nvim-bridge-detach", {});
        ctx.ui.notify("Disconnected from Neovim.", "info");
      } else {
        ctx.ui.notify("Not connected to any Neovim instance.", "info");
      }
      updateStatus(ctx);
    },
  });

  // ── Lifecycle ───────────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    currentCtx = ctx;
    // Restore persisted connection.
    const entries = ctx.sessionManager.getEntries();
    let persistedSocket: string | null = null;
    let detached = false;

    for (const entry of entries) {
      if (entry.type === "custom") {
        if (entry.customType === "nvim-bridge-detach") {
          detached = true;
          persistedSocket = null;
        } else if (entry.customType === "nvim-bridge") {
          const data = entry.data as { socketPath?: string } | undefined;
          if (data?.socketPath) {
            persistedSocket = data.socketPath;
            detached = false;
          }
        }
      }
    }

    if (persistedSocket && !detached) {
      const ok = await connect(persistedSocket, attach);
      if (ok && !toolsRegistered) {
        registerTools(pi);
        toolsRegistered = true;
      }
      if (ok && ctx.hasUI) {
        ctx.ui.notify(
          `Reconnected to Neovim: ${state.currentBufferName}`,
          "info",
        );
      }
    }

    updateStatus(ctx);
  });

  pi.on("turn_end", async (_event, ctx) => {
    await refreshNvimState();
    updateStatus(ctx);
  });

  pi.on("session_shutdown", async () => {
    stopPolling();
    currentCtx = null;
    disconnect();
  });
}
