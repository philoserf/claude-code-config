import type { AgentEntry, RenderContext } from "../types.js";
import { dim, green, magenta, yellow } from "./colors.js";

export function renderAgentsLine(ctx: RenderContext): string | null {
	const { agents } = ctx.transcript;

	const runningAgents = agents.filter((a) => a.status === "running");
	const recentCompleted = agents
		.filter((a) => a.status === "completed")
		.slice(-2);

	const toShow = [...runningAgents, ...recentCompleted].slice(-3);

	if (toShow.length === 0) {
		return null;
	}

	const lines: string[] = [];

	for (const agent of toShow) {
		lines.push(formatAgent(agent));
	}

	return lines.join("\n");
}

function formatAgent(agent: AgentEntry): string {
	const statusIcon = agent.status === "running" ? yellow("◐") : green("✓");
	const type = magenta(agent.type);
	const model = agent.model ? dim(`[${agent.model}]`) : "";
	const desc = agent.description
		? dim(`: ${truncateDesc(agent.description)}`)
		: "";
	const elapsed = formatElapsed(agent);

	return `${statusIcon} ${type}${model ? ` ${model}` : ""}${desc} ${dim(`(${elapsed})`)}`;
}

function truncateDesc(desc: string, maxLen: number = 40): string {
	if (desc.length <= maxLen) return desc;
	return `${desc.slice(0, maxLen - 3)}...`;
}

function formatElapsed(agent: AgentEntry): string {
	const now = Date.now();
	const start = agent.startTime.getTime();
	const end = agent.endTime?.getTime() ?? now;
	const ms = end - start;

	if (ms < 1000) return "<1s";
	if (ms < 60000) return `${Math.round(ms / 1000)}s`;

	const mins = Math.floor(ms / 60000);
	const secs = Math.round((ms % 60000) / 1000);
	return `${mins}m ${secs}s`;
}
