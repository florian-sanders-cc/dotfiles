/**
 * todo-widget — Always-visible todo list widget for pi
 *
 * Shows the last 8 todos above the editor as a persistent widget.
 * The LLM manages the list via the `todo` tool (add, toggle, clear).
 * State is stored in tool result details for session persistence and
 * correct branching behavior.
 */

import { StringEnum } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { Type } from "typebox";

// ─── Types ─────────────────────────────────────────────────────────────

interface Todo {
	id: number;
	text: string;
	done: boolean;
}

interface TodoDetails {
	action: "list" | "add" | "toggle" | "clear";
	todos: Todo[];
	nextId: number;
	error?: string;
}

const TodoParams = Type.Object({
	action: StringEnum(["list", "add", "toggle", "clear"] as const),
	text: Type.Optional(Type.String({ description: "Todo text (for add)" })),
	id: Type.Optional(Type.Number({ description: "Todo ID (for toggle)" })),
});

const MAX_VISIBLE = 8;

// ─── Widget rendering ──────────────────────────────────────────────────

function renderWidget(todos: Todo[], theme: Theme): string[] {
	if (todos.length === 0) return [];

	const display = todos.length > MAX_VISIBLE ? todos.slice(-MAX_VISIBLE) : todos;
	const done = todos.filter((t) => t.done).length;
	const total = todos.length;

	const lines: string[] = [];
	const header = theme.fg("accent", theme.bold(` Todos (${done}/${total}) `));
	lines.push(header);

	for (const todo of display) {
		const check = todo.done
			? theme.fg("success", "✓")
			: theme.fg("dim", "○");
		const text = todo.done
			? theme.fg("dim", todo.text)
			: todo.text;
		lines.push(` ${check} ${text}`);
	}

	if (todos.length > MAX_VISIBLE) {
		lines.push(theme.fg("dim", ` ... ${todos.length - MAX_VISIBLE} more above`));
	}

	return lines;
}

// ─── Extension ─────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// In-memory state (reconstructed from session on load)
	let todos: Todo[] = [];
	let nextId = 1;

	/** Refresh the persistent widget above the editor. */
	function updateWidget(ctx: ExtensionContext) {
		if (!ctx.hasUI) return;
		const lines = renderWidget(todos, ctx.ui.theme);
		ctx.ui.setWidget("todo-widget", lines.length > 0 ? lines : undefined);
	}

	/** Reconstruct state by replaying tool result entries on the current branch. */
	function reconstructState(ctx: ExtensionContext) {
		todos = [];
		nextId = 1;

		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message") continue;
			const msg = entry.message;
			if (msg.role !== "toolResult" || msg.toolName !== "todo") continue;

			const details = msg.details as TodoDetails | undefined;
			if (details) {
				todos = details.todos;
				nextId = details.nextId;
			}
		}
	}

	// ── Lifecycle ───────────────────────────────────────────────────

	pi.on("session_start", async (_event, ctx) => {
		reconstructState(ctx);
		updateWidget(ctx);
	});

	pi.on("session_tree", async (_event, ctx) => {
		reconstructState(ctx);
		updateWidget(ctx);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		if (ctx.hasUI) {
			ctx.ui.setWidget("todo-widget", undefined);
		}
	});

	// ── Nudge the LLM to use the todo tool ─────────────────────────

	pi.on("before_agent_start", async (event) => {
		return {
			systemPrompt:
				event.systemPrompt +
				"\n\nTrack your progress with the `todo` tool. Before starting work, plan by breaking\n" +
				"the task into small, concrete steps — ideally one step per tool call or decision.\n" +
				"Add each step as a todo, then toggle them off as you go. Avoid coarse items like\n" +
				"'Implement feature X'; instead split into granular actions: 'Find the relevant file',\n" +
				"'Read the config', 'Add the function signature', 'Update callers'. Use `todo clear`\n" +
				"when all steps are done.",
		};
	});

	// ── Tool: todo ──────────────────────────────────────────────────

	pi.registerTool({
		name: "todo",
		label: "Todo",
		description:
			"Manage a todo list. Actions: list (view all), add (with text), toggle (by id), clear (remove all)",
		promptSnippet: "Break work into granular steps (~1 action per step). Add each as a todo before doing it, toggle when complete.",
		promptGuidelines: [
			"Break tasks into small, concrete steps. Each item should be ~1 tool call or decision. Add each step as a todo before starting, toggle it when done. Clear the list when finished.",
		],
		parameters: TodoParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			switch (params.action) {
				case "list": {
					const result = {
						content: [
							{
								type: "text" as const,
								text: todos.length
									? todos
											.map((t) => `[${t.done ? "x" : " "}] #${t.id}: ${t.text}`)
											.join("\n")
									: "No todos",
							},
						],
						details: { action: "list" as const, todos: [...todos], nextId },
					};
					updateWidget(ctx);
					return result;
				}

				case "add": {
					if (!params.text) {
						return {
							content: [{ type: "text" as const, text: "Error: text required for add" }],
							details: {
								action: "add" as const,
								todos: [...todos],
								nextId,
								error: "text required",
							} as TodoDetails,
						};
					}
					const newTodo: Todo = { id: nextId++, text: params.text, done: false };
					todos.push(newTodo);
					const result = {
						content: [
							{ type: "text" as const, text: `Added #${newTodo.id}: ${newTodo.text}` },
						],
						details: { action: "add" as const, todos: [...todos], nextId },
					};
					updateWidget(ctx);
					return result;
				}

				case "toggle": {
					if (params.id === undefined) {
						return {
							content: [{ type: "text" as const, text: "Error: id required for toggle" }],
							details: {
								action: "toggle" as const,
								todos: [...todos],
								nextId,
								error: "id required",
							} as TodoDetails,
						};
					}
					const todo = todos.find((t) => t.id === params.id);
					if (!todo) {
						return {
							content: [
								{ type: "text" as const, text: `Todo #${params.id} not found` },
							],
							details: {
								action: "toggle" as const,
								todos: [...todos],
								nextId,
								error: `#${params.id} not found`,
							} as TodoDetails,
						};
					}
					todo.done = !todo.done;
					const result = {
						content: [
							{
								type: "text" as const,
								text: `#${todo.id} ${todo.done ? "completed" : "uncompleted"}`,
							},
						],
						details: { action: "toggle" as const, todos: [...todos], nextId },
					};
					updateWidget(ctx);
					return result;
				}

				case "clear": {
					const count = todos.length;
					todos = [];
					nextId = 1;
					const result = {
						content: [
							{ type: "text" as const, text: `Cleared ${count} todos` },
						],
						details: {
							action: "clear" as const,
							todos: [],
							nextId: 1,
						} as TodoDetails,
					};
					updateWidget(ctx);
					return result;
				}

				default:
					return {
						content: [
							{ type: "text" as const, text: `Unknown action: ${params.action}` },
						],
						details: {
							action: "list" as const,
							todos: [...todos],
							nextId,
							error: `unknown action: ${params.action}`,
						} as TodoDetails,
					};
			}
		},

		renderCall(args, theme, _context) {
			let text =
				theme.fg("toolTitle", theme.bold("todo ")) +
				theme.fg("muted", args.action);
			if (args.text) text += ` ${theme.fg("dim", `"${args.text}"`)}`;
			if (args.id !== undefined)
				text += ` ${theme.fg("accent", `#${args.id}`)}`;
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded }, theme, _context) {
			const details = result.details as TodoDetails | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(
					text?.type === "text" ? text.text : "",
					0,
					0,
				);
			}

			if (details.error) {
				return new Text(
					theme.fg("error", `Error: ${details.error}`),
					0,
					0,
				);
			}

			const todoList = details.todos;

			switch (details.action) {
				case "list": {
					if (todoList.length === 0) {
						return new Text(theme.fg("dim", "No todos"), 0, 0);
					}
					let listText = theme.fg(
						"muted",
						`${todoList.length} todo(s):`,
					);
					const display = expanded
						? todoList
						: todoList.slice(0, 5);
					for (const t of display) {
						const check = t.done
							? theme.fg("success", "✓")
							: theme.fg("dim", "○");
						const itemText = t.done
							? theme.fg("dim", t.text)
							: theme.fg("muted", t.text);
						listText += `\n${check} ${theme.fg("accent", `#${t.id}`)} ${itemText}`;
					}
					if (!expanded && todoList.length > 5) {
						listText += `\n${theme.fg("dim", `... ${todoList.length - 5} more`)}`;
					}
					return new Text(listText, 0, 0);
				}

				case "add": {
					const added = todoList[todoList.length - 1];
					return new Text(
						theme.fg("success", "✓ Added ") +
							theme.fg("accent", `#${added.id}`) +
							" " +
							theme.fg("muted", added.text),
						0,
						0,
					);
				}

				case "toggle": {
					const text = result.content[0];
					const msg = text?.type === "text" ? text.text : "";
					return new Text(
						theme.fg("success", "✓ ") +
							theme.fg("muted", msg),
						0,
						0,
					);
				}

				case "clear":
					return new Text(
						theme.fg("success", "✓ ") +
							theme.fg("muted", "Cleared all todos"),
						0,
						0,
					);
			}
		},
	});

	// ── Command: /td ────────────────────────────────────────────────

	pi.registerCommand("td", {
		description: "Refresh the todo widget",
		handler: async (_args, ctx) => {
			if (todos.length === 0) {
				ctx.ui.notify(
					"No active todos. Ask the agent to add some!",
					"info",
				);
				return;
			}
			updateWidget(ctx);
		},
	});
}
