import { spawn } from "child_process";
import { copyToClipboard, type ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * Copy the last assistant response to the clipboard via Wayland wl-copy.
 * Falls back to pi's built-in copyToClipboard (X11/OSC52) if wl-copy is unavailable.
 *
 * We bypass copyToClipboard on Wayland because the native @mariozechner/clipboard
 * addon uses X11 exclusively and succeeds silently without actually populating the
 * Wayland system clipboard. Using wl-copy directly ensures the text lands where
 * Wayland apps (and your terminal) can see it.
 */
function copyViaWlCopy(text: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const proc = spawn("wl-copy", [], { stdio: ["pipe", "ignore", "ignore"] });
    proc.on("error", (err: Error) => reject(err));
    proc.stdin.on("error", (err: Error) => reject(err));
    proc.stdin.write(text);
    proc.stdin.end();
    proc.on("close", (code: number | null) => {
      if (code === 0) resolve();
      else reject(new Error(`wl-copy exited with code ${code}`));
    });
  });
}

export default function (pi: ExtensionAPI) {
  pi.registerShortcut("alt+y", {
    description: "Copy last agent response",
    handler: async (ctx) => {
      // Replicate AgentSession.getLastAssistantText() logic:
      // walk the current branch from leaf to root and find the last
      // assistant message that has text content, concatenating all text blocks.
      const branch = ctx.sessionManager.getBranch();
      let lastText: string | undefined;

      for (let i = branch.length - 1; i >= 0; i--) {
        const entry = branch[i];
        if (entry.type !== "message") continue;

        const msg = entry.message;
        if (msg.role !== "assistant") continue;
        if (msg.stopReason === "aborted" && msg.content.length === 0) continue;

        // Concatenate all text blocks (matching built-in getLastAssistantText)
        const parts: string[] = [];
        for (const block of msg.content) {
          if (block.type === "text") {
            parts.push(block.text);
          }
        }
        if (parts.length > 0) {
          lastText = parts.join("\n").trim();
          break;
        }
      }

      if (!lastText) {
        ctx.ui.notify("No response to copy yet.", "warning");
        return;
      }

      // Try wl-copy first (Wayland), fall back to pi's copyToClipboard
      try {
        await copyViaWlCopy(lastText);
      } catch {
        try {
          await copyToClipboard(lastText);
        } catch (err) {
          ctx.ui.notify(
            `Failed to copy: ${err instanceof Error ? err.message : String(err)}`,
            "error",
          );
          return;
        }
      }
      ctx.ui.notify("Copied last response", "info");
    },
  });
}
