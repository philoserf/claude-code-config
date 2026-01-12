/**
 * Autocompact buffer percentage.
 *
 * NOTE: This value (22.5% = 45k/200k) is empirically derived from community
 * observations of Claude Code's autocompact behavior. It is NOT officially
 * documented by Anthropic and may change in future Claude Code versions.
 * If users report mismatches, this value may need adjustment.
 */
export const AUTOCOMPACT_BUFFER_PERCENT = 0.225;
