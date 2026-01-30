#!/usr/bin/env bun
/**
 * Continuous Learning - Session Evaluator
 *
 * Cross-platform (Windows, macOS, Linux)
 *
 * Runs on Stop hook to extract reusable patterns from Claude Code sessions
 *
 * Why Stop hook instead of UserPromptSubmit:
 * - Stop runs once at session end (lightweight)
 * - UserPromptSubmit runs every message (heavy, adds latency)
 */

const fs = require("node:fs");
const {
  getLearnedSkillsDir,
  ensureDir,
  countInFile,
  log,
} = require("./lib/utils");

async function main() {
  // Default configuration
  const minSessionLength = 10;
  const learnedSkillsPath = getLearnedSkillsDir();

  // Ensure learned skills directory exists
  ensureDir(learnedSkillsPath);

  // Get transcript path from environment (set by Claude Code)
  const transcriptPath = process.env.CLAUDE_TRANSCRIPT_PATH;

  if (!transcriptPath || !fs.existsSync(transcriptPath)) {
    process.exit(0);
  }

  // Count user messages in session
  const messageCount = countInFile(transcriptPath, /"type":"user"/g);

  // Skip short sessions
  if (messageCount < minSessionLength) {
    log(
      `[ContinuousLearning] Session too short (${messageCount} messages), skipping`,
    );
    process.exit(0);
  }

  // Signal to Claude that session should be evaluated for extractable patterns
  log(
    `[ContinuousLearning] Session has ${messageCount} messages - evaluate for extractable patterns`,
  );
  log(`[ContinuousLearning] Save learned skills to: ${learnedSkillsPath}`);

  process.exit(0);
}

main().catch((err) => {
  console.error("[ContinuousLearning] Error:", err.message);
  process.exit(0);
});
