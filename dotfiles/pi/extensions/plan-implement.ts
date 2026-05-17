import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("implement", {
    description: "Start a fresh session to implement the plan from /plan",
    handler: async (args, ctx) => {
      const planPath = join(ctx.cwd, ".pi", "plan.md");

      let plan: string;
      try {
        plan = await readFile(planPath, "utf8");
      } catch {
        ctx.ui.notify(
          "No plan found at .pi/plan.md — use /plan first to create one.",
          "error"
        );
        return;
      }

      if (!plan.trim()) {
        ctx.ui.notify("Plan file is empty. Run /plan first.", "error");
        return;
      }

      const userMessage = args?.trim()
        ? `Implement the following plan. Additional instructions: ${args.trim()}\n\n---\n\n${plan}`
        : `Implement the following plan step by step. Ask me if anything is unclear before proceeding.\n\n---\n\n${plan}`;

      const result = await ctx.newSession({
        setup: async (sm) => {
          sm.appendMessage({
            role: "user",
            content: [{ type: "text", text: userMessage }],
            timestamp: Date.now(),
          });
        },
      });

      if (result.cancelled) {
        ctx.ui.notify("Session switch was cancelled.", "warn");
      }
    },
  });
}
