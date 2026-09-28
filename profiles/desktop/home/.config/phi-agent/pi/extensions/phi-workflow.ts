/**
 * phi-workflow — first-party pi extension for the phiOS agent (D-PI-06:
 * shipped from this repository, not installed from an external package
 * registry, so the declared-software rule is satisfied by its presence
 * here). Loaded by the general, academic and coding pi profiles through a
 * symlink into each profile's own extensions/ directory; never loaded by
 * inline, which runs with --no-extensions.
 *
 * Registers three tools that the phi-shell agent panel
 * (Components/AgentPanel/) renders with dedicated cards, reading their
 * `details` payload:
 *
 *   - plan       a short, visible checklist for multi-step work
 *   - subagent   delegates one task to an isolated, non-interactive child
 *                pi process and streams its progress back
 *   - ask_user   asks the person a question through pi's own UI dialogs
 *
 * Every other tool falls back to generic rendering; nothing here is
 * required for pi to function without the panel.
 */

import { spawn } from "node:child_process";
import type { AgentMessage } from "@earendil-works/pi-agent-core";
import type { AssistantMessage, TextContent } from "@earendil-works/pi-ai";
import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, JsonAgentSessionEvent } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// ---------------------------------------------------------------------------
// plan
// ---------------------------------------------------------------------------

type PlanStepStatus = "pending" | "in_progress" | "done" | "skipped";

interface PlanStep {
	title: string;
	status: PlanStepStatus;
}

interface PlanDetails {
	steps: PlanStep[];
	note?: string;
}

const PLAN_WIDGET_KEY = "phi-plan";

// One character per status, used both in the model-facing checklist and the
// TUI/RPC widget so the two stay visually identical.
const PLAN_STATUS_MARK: Record<PlanStepStatus, string> = {
	pending: " ",
	in_progress: ">",
	done: "x",
	skipped: "-",
};

function formatPlanLines(plan: PlanDetails): string[] {
	const lines = plan.steps.map((step) => `[${PLAN_STATUS_MARK[step.status]}] ${step.title}`);
	if (plan.note) lines.push(`note: ${plan.note}`);
	return lines;
}

const PlanStepSchema = Type.Object({
	title: Type.String({ description: "Short step title (a few words)" }),
	status: StringEnum(["pending", "in_progress", "done", "skipped"] as const),
});

const PlanParams = Type.Object({
	steps: Type.Array(PlanStepSchema, {
		description: "The complete ordered list of steps. This replaces any previous plan, it does not append.",
	}),
	note: Type.Optional(Type.String({ description: "Optional short note shown alongside the plan" })),
});

// ---------------------------------------------------------------------------
// subagent
// ---------------------------------------------------------------------------

const SUBAGENT_TIMEOUT_MS = 10 * 60 * 1000;
const SUBAGENT_KILL_GRACE_MS = 5000;
const SUBAGENT_UPDATE_INTERVAL_MS = 500;
const SUBAGENT_EVENTS_KEPT = 50;
const SUBAGENT_TEXT_PREVIEW_CHARS = 2000;

// Tools a child never gets even when explicitly requested: recursion into
// this same extension's own tools.
const SUBAGENT_DENIED_TOOLS = new Set(["subagent", "plan", "ask_user"]);
// Ceiling applied when the parent has no bash: a subagent spawned from a
// non-coding profile stays read-only even if the parent also has write/edit.
const SUBAGENT_READ_ONLY_TOOLS = new Set(["read", "grep", "find", "ls"]);

const SUBAGENT_SYSTEM_PROMPT =
	"You are a focused subagent invoked by another pi agent. Complete the given task and answer with the result only — no preamble, no meta-commentary about being a subagent.";

type SubagentStatus = "running" | "done" | "error" | "timeout";

interface SubagentEvent {
	kind: "tool" | "text" | "thinking";
	name?: string;
	summary: string;
}

interface SubagentUsage {
	input: number;
	output: number;
	cost: number;
}

interface SubagentDetails {
	status: SubagentStatus;
	label: string | undefined;
	events: SubagentEvent[];
	text: string;
	usage: SubagentUsage;
	model: string | undefined;
	turns: number;
	elapsedMs: number;
}

const SubagentParams = Type.Object({
	task: Type.String({ description: "The task to delegate to a focused, isolated-context child agent" }),
	label: Type.Optional(Type.String({ description: "Short label shown while the child runs" })),
	tools: Type.Optional(
		Type.Array(Type.String(), {
			description:
				"Tool names to grant the child. Narrowed to the intersection with this session's own active tools; omit to inherit them all.",
		}),
	),
});

// The child's tool allowlist: requested tools (or the parent's own, when
// none were requested) intersected with what the parent actually has
// active, with this extension's own tools always stripped, and narrowed to
// the read-only set when the parent has no bash tool.
function resolveChildTools(pi: ExtensionAPI, requested: string[] | undefined): string[] {
	const parentActive = pi.getActiveTools();
	const parentSet = new Set(parentActive);
	const base = requested && requested.length > 0 ? requested : parentActive;
	let tools = base.filter((name) => parentSet.has(name) && !SUBAGENT_DENIED_TOOLS.has(name));
	if (!parentSet.has("bash")) {
		tools = tools.filter((name) => SUBAGENT_READ_ONLY_TOOLS.has(name));
	}
	return [...new Set(tools)];
}

// The first string-valued argument of a tool call, for a compact progress
// summary (e.g. a file path or a command).
function firstStringArg(args: unknown): string {
	if (args && typeof args === "object") {
		for (const value of Object.values(args as Record<string, unknown>)) {
			if (typeof value === "string") return value.length > 80 ? value.slice(0, 80) : value;
		}
	}
	return "";
}

// Same narrowing pattern as the plan-mode example: AgentMessage is a wider
// union than pi-ai's own AssistantMessage, so a type guard is more reliable
// than a bare `.role === "assistant"` check.
function isAssistantMessage(message: AgentMessage): message is AssistantMessage {
	return message.role === "assistant" && Array.isArray(message.content);
}

function extractAssistantText(message: AssistantMessage): string {
	return message.content
		.filter((block): block is TextContent => block.type === "text")
		.map((block) => block.text)
		.join("\n");
}

function lastLines(text: string, count: number): string {
	return text.split("\n").slice(-count).join("\n").trim();
}

// ---------------------------------------------------------------------------
// ask_user
// ---------------------------------------------------------------------------

const OTHER_OPTION = "Other…";

interface AskUserDetails {
	question: string;
	answer: string | null;
	cancelled: boolean;
}

const AskUserParams = Type.Object({
	question: Type.String({ description: "The question to ask the user" }),
	options: Type.Optional(Type.Array(Type.String(), { description: "Choices to present; omit for free-form input" })),
	allowOther: Type.Optional(
		Type.Boolean({ description: "Add an 'Other…' choice that opens free-form input", default: false }),
	),
});

export default function phiWorkflow(pi: ExtensionAPI) {
	// -------------------------------------------------------------------------
	// plan
	// -------------------------------------------------------------------------

	let currentPlan: PlanDetails = { steps: [] };

	function syncPlanWidget(ctx: ExtensionContext) {
		if (!ctx.hasUI) return;
		const lines = formatPlanLines(currentPlan);
		ctx.ui.setWidget(PLAN_WIDGET_KEY, lines.length > 0 ? lines : undefined);
	}

	// Rebuild the in-memory plan from the active branch's tool results, the
	// same pattern the todo.ts example uses, so a resumed session or a
	// /tree navigation shows the plan that belongs to that branch.
	function reconstructPlan(ctx: ExtensionContext) {
		currentPlan = { steps: [] };
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message") continue;
			const msg = entry.message;
			if (msg.role !== "toolResult" || msg.toolName !== "plan") continue;
			const details = msg.details as PlanDetails | undefined;
			if (details) currentPlan = details;
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		reconstructPlan(ctx);
		syncPlanWidget(ctx);
	});
	pi.on("session_tree", async (_event, ctx) => {
		reconstructPlan(ctx);
		syncPlanWidget(ctx);
	});

	pi.registerTool({
		name: "plan",
		label: "Plan",
		description:
			"Track a short, visible plan for multi-step work. Call it once at the start with every step you intend to " +
			"take, then call it again — passing the complete updated list — whenever a step's status changes. This " +
			"replaces the whole plan, it does not append. Keep titles short.",
		parameters: PlanParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			currentPlan = { steps: params.steps, note: params.note };
			syncPlanWidget(ctx);
			const lines = formatPlanLines(currentPlan);
			return {
				content: [{ type: "text", text: lines.length > 0 ? lines.join("\n") : "(empty plan)" }],
				details: { steps: currentPlan.steps, note: currentPlan.note },
			};
		},
	});

	// -------------------------------------------------------------------------
	// subagent
	// -------------------------------------------------------------------------

	pi.registerTool({
		name: "subagent",
		label: "Subagent",
		description:
			"Delegate one task to a focused child agent with its own isolated context window. Use it for a " +
			"self-contained sub-task whose result you need but whose exploration would otherwise fill this " +
			"session's context. Streams progress and returns the child's final answer.",
		parameters: SubagentParams,

		async execute(_toolCallId, params, signal, onUpdate, ctx) {
			const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;
			const tools = resolveChildTools(pi, params.tools);

			const args = ["--mode", "json", "-p", "--no-session", "--no-extensions"];
			// The chat profiles run without the working folder's context files
			// (AGENTS.md); only the coding profile, the one with bash, loads
			// them, so a child only does when its parent can.
			if (!pi.getActiveTools().includes("bash")) args.push("--no-context-files");
			if (model) args.push("--model", model);
			// An empty allowlist is not a documented --tools value; --no-tools is
			// the declared way to start a child with nothing active.
			if (tools.length > 0) args.push("--tools", tools.join(","));
			else args.push("--no-tools");
			args.push("--append-system-prompt", SUBAGENT_SYSTEM_PROMPT);
			args.push("--", params.task);

			const startedAt = Date.now();
			const events: SubagentEvent[] = [];
			const usage: SubagentUsage = { input: 0, output: 0, cost: 0 };
			let text = "";
			let childModel = model;
			let childStopReason: string | undefined;
			let childErrorMessage: string | undefined;
			let turns = 0;
			let stderr = "";
			let timedOut = false;
			let aborted = false;
			let lastEmit = 0;

			const emitProgress = () => {
				if (!onUpdate) return;
				const now = Date.now();
				if (now - lastEmit < SUBAGENT_UPDATE_INTERVAL_MS) return;
				lastEmit = now;
				const preview = text.slice(-SUBAGENT_TEXT_PREVIEW_CHARS);
				const details: SubagentDetails = {
					status: "running",
					label: params.label,
					events: events.slice(-SUBAGENT_EVENTS_KEPT),
					text: preview,
					usage: { ...usage },
					model: childModel,
					turns,
					elapsedMs: now - startedAt,
				};
				onUpdate({
					content: [{ type: "text", text: preview || "(running…)" }],
					details,
				});
			};

			const processLine = (line: string) => {
				let event: JsonAgentSessionEvent;
				try {
					event = JSON.parse(line);
				} catch {
					return;
				}
				switch (event.type) {
					case "message_start":
						if (event.message && isAssistantMessage(event.message)) text = "";
						break;
					case "message_update":
						if (event.assistantMessageEvent?.type === "text_delta") {
							text += event.assistantMessageEvent.delta;
						}
						break;
					case "message_end":
						if (event.message && isAssistantMessage(event.message)) {
							text = extractAssistantText(event.message) || text;
							if (event.message.model) childModel = event.message.model;
							childStopReason = event.message.stopReason;
							childErrorMessage = event.message.errorMessage;
							const msgUsage = event.message.usage;
							if (msgUsage) {
								usage.input += msgUsage.input ?? 0;
								usage.output += msgUsage.output ?? 0;
								usage.cost += msgUsage.cost?.total ?? 0;
							}
						}
						break;
					case "turn_end":
						turns += 1;
						break;
					case "tool_execution_start":
						events.push({ kind: "tool", name: event.toolName, summary: firstStringArg(event.args) });
						break;
					default:
						break;
				}
				emitProgress();
			};

			// Strict JSONL framing per docs/json.md: split only on "\n" and strip
			// a trailing "\r"; never use Node's readline, which also breaks on
			// Unicode line/paragraph separators that are valid inside JSON strings.
			let buffer = "";
			const feed = (chunk: Buffer) => {
				buffer += chunk.toString("utf8");
				const lines = buffer.split("\n");
				buffer = lines.pop() ?? "";
				for (const raw of lines) {
					const line = raw.endsWith("\r") ? raw.slice(0, -1) : raw;
					if (line) processLine(line);
				}
			};

			const exitCode = await new Promise<number>((resolve) => {
				const proc = spawn("pi", args, {
					stdio: ["ignore", "pipe", "pipe"],
					cwd: process.cwd(),
					// env intentionally omitted: Node inherits process.env by
					// default, which already carries the containment's PI_* vars.
				});

				// proc.killed only means the signal was delivered, not that the
				// process has exited — so the SIGKILL check below must use its
				// own "has it actually exited yet" flag, not proc.killed.
				let exited = false;
				let graceTimer: ReturnType<typeof setTimeout> | undefined;
				const killWithGrace = () => {
					proc.kill("SIGTERM");
					graceTimer = setTimeout(() => {
						if (!exited) proc.kill("SIGKILL");
					}, SUBAGENT_KILL_GRACE_MS);
				};

				const timer = setTimeout(() => {
					timedOut = true;
					killWithGrace();
				}, SUBAGENT_TIMEOUT_MS);

				const onAbort = () => {
					aborted = true;
					killWithGrace();
				};
				if (signal) {
					if (signal.aborted) onAbort();
					else signal.addEventListener("abort", onAbort, { once: true });
				}

				proc.stdout.on("data", feed);
				proc.stderr.on("data", (chunk: Buffer) => {
					stderr += chunk.toString("utf8");
				});
				proc.on("close", (code) => {
					exited = true;
					clearTimeout(timer);
					if (graceTimer) clearTimeout(graceTimer);
					signal?.removeEventListener("abort", onAbort);
					if (buffer.trim()) processLine(buffer.endsWith("\r") ? buffer.slice(0, -1) : buffer);
					resolve(code ?? 1);
				});
				proc.on("error", (err) => {
					exited = true;
					clearTimeout(timer);
					if (graceTimer) clearTimeout(graceTimer);
					signal?.removeEventListener("abort", onAbort);
					stderr += String(err);
					resolve(1);
				});
			});

			let status: SubagentStatus;
			if (timedOut) {
				status = "timeout";
				if (!text) text = `timed out after ${Math.round(SUBAGENT_TIMEOUT_MS / 60000)} minutes`;
			} else if (aborted) {
				status = "error";
				text = "aborted";
			} else if (childStopReason === "error" || childStopReason === "aborted") {
				// pi itself can exit 0 while the last assistant turn failed (a
				// broker/provider error, for instance) — the transcript's own
				// stopReason is the authoritative signal, not the exit code.
				status = "error";
				text = childErrorMessage || text || "(child agent reported an error)";
			} else if (exitCode !== 0) {
				status = "error";
				if (!text) text = lastLines(stderr, 20) || `pi exited with code ${exitCode}`;
			} else {
				status = "done";
				if (!text) text = "(no output)";
			}

			const details: SubagentDetails = {
				status,
				label: params.label,
				events: events.slice(-SUBAGENT_EVENTS_KEPT),
				text,
				usage,
				model: childModel,
				turns,
				elapsedMs: Date.now() - startedAt,
			};
			return {
				content: [{ type: "text", text }],
				details,
			};
		},
	});

	// -------------------------------------------------------------------------
	// ask_user
	// -------------------------------------------------------------------------

	pi.registerTool({
		name: "ask_user",
		label: "Ask user",
		description:
			"Ask the user a question and wait for their answer. Use when you need input only they can give before " +
			"continuing. Prefer a short options list over free-form text when the answer is really a choice.",
		parameters: AskUserParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			if (!ctx.hasUI) {
				return {
					content: [{ type: "text", text: "(the user cannot be asked in this mode)" }],
					details: { question: params.question, answer: null, cancelled: true } as AskUserDetails,
				};
			}

			let answer: string | undefined;
			let cancelled = false;

			if (params.options && params.options.length > 0) {
				const displayOptions = params.allowOther ? [...params.options, OTHER_OPTION] : params.options;
				const choice = await ctx.ui.select(params.question, displayOptions);
				if (choice === undefined) {
					cancelled = true;
				} else if (choice === OTHER_OPTION) {
					const typed = await ctx.ui.input(params.question);
					if (typed === undefined) cancelled = true;
					else answer = typed;
				} else {
					answer = choice;
				}
			} else {
				const typed = await ctx.ui.input(params.question);
				if (typed === undefined) cancelled = true;
				else answer = typed;
			}

			const resultText = !cancelled && answer !== undefined ? answer : "(no answer)";
			return {
				content: [{ type: "text", text: resultText }],
				details: { question: params.question, answer: answer ?? null, cancelled } as AskUserDetails,
			};
		},
	});
}
