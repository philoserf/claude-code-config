import { AUTOCOMPACT_BUFFER_PERCENT } from "./constants.js";
import type { StdinData } from "./types.js";

export async function readStdin(): Promise<StdinData | null> {
  if (process.stdin.isTTY) {
    return null;
  }

  const chunks: string[] = [];

  try {
    process.stdin.setEncoding("utf8");
    for await (const chunk of process.stdin) {
      chunks.push(chunk as string);
    }
    const raw = chunks.join("");
    if (!raw.trim()) {
      return null;
    }
    return JSON.parse(raw) as StdinData;
  } catch {
    return null;
  }
}

function getTotalTokens(stdin: StdinData): number {
  const usage = stdin.context_window?.current_usage;
  return (
    (usage?.input_tokens ?? 0) +
    (usage?.cache_creation_input_tokens ?? 0) +
    (usage?.cache_read_input_tokens ?? 0)
  );
}

export function getContextPercent(stdin: StdinData): number {
  const size = stdin.context_window?.context_window_size;

  if (!size || size <= 0) {
    return 0;
  }

  const totalTokens = getTotalTokens(stdin);
  return Math.min(100, Math.round((totalTokens / size) * 100));
}

export function getBufferedPercent(stdin: StdinData): number {
  const size = stdin.context_window?.context_window_size;

  if (!size || size <= 0) {
    return 0;
  }

  const totalTokens = getTotalTokens(stdin);
  const buffer = size * AUTOCOMPACT_BUFFER_PERCENT;
  return Math.min(100, Math.round(((totalTokens + buffer) / size) * 100));
}

export function getModelName(stdin: StdinData): string {
  return stdin.model?.display_name ?? stdin.model?.id ?? "Unknown";
}
