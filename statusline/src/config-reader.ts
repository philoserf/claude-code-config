import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

export interface ConfigCounts {
  claudeMdCount: number;
  rulesCount: number;
  mcpCount: number;
  hooksCount: number;
}

function getMcpServerNames(filePath: string): Set<string> {
  if (!fs.existsSync(filePath)) return new Set();
  try {
    const content = fs.readFileSync(filePath, "utf8");
    const config = JSON.parse(content);
    if (config.mcpServers && typeof config.mcpServers === "object") {
      return new Set(Object.keys(config.mcpServers));
    }
  } catch {
    // Ignore errors
  }
  return new Set();
}

function countMcpServersInFile(filePath: string, excludeFrom?: string): number {
  const servers = getMcpServerNames(filePath);
  if (excludeFrom) {
    const exclude = getMcpServerNames(excludeFrom);
    for (const name of exclude) {
      servers.delete(name);
    }
  }
  return servers.size;
}

function countHooksInFile(filePath: string): number {
  if (!fs.existsSync(filePath)) return 0;
  try {
    const content = fs.readFileSync(filePath, "utf8");
    const config = JSON.parse(content);
    if (config.hooks && typeof config.hooks === "object") {
      return Object.keys(config.hooks).length;
    }
  } catch {
    // Ignore errors
  }
  return 0;
}

function countRulesInDir(rulesDir: string): number {
  if (!fs.existsSync(rulesDir)) return 0;
  let count = 0;
  try {
    const entries = fs.readdirSync(rulesDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(rulesDir, entry.name);
      if (entry.isDirectory()) {
        count += countRulesInDir(fullPath);
      } else if (entry.isFile() && entry.name.endsWith(".md")) {
        count++;
      }
    }
  } catch {
    // Ignore errors
  }
  return count;
}

export async function countConfigs(cwd?: string): Promise<ConfigCounts> {
  let claudeMdCount = 0;
  let rulesCount = 0;
  let mcpCount = 0;
  let hooksCount = 0;

  const homeDir = os.homedir();
  const claudeDir = path.join(homeDir, ".claude");

  // === USER SCOPE ===

  // ~/.claude/CLAUDE.md
  if (fs.existsSync(path.join(claudeDir, "CLAUDE.md"))) {
    claudeMdCount++;
  }

  // ~/.claude/rules/*.md
  rulesCount += countRulesInDir(path.join(claudeDir, "rules"));

  // ~/.claude/settings.json (MCPs and hooks)
  const userSettings = path.join(claudeDir, "settings.json");
  mcpCount += countMcpServersInFile(userSettings);
  hooksCount += countHooksInFile(userSettings);

  // ~/.claude.json (additional user-scope MCPs, dedupe by counting unique)
  const userClaudeJson = path.join(homeDir, ".claude.json");
  mcpCount += countMcpServersInFile(userClaudeJson, userSettings);

  // === PROJECT SCOPE ===

  if (cwd) {
    // {cwd}/CLAUDE.md
    if (fs.existsSync(path.join(cwd, "CLAUDE.md"))) {
      claudeMdCount++;
    }

    // {cwd}/CLAUDE.local.md
    if (fs.existsSync(path.join(cwd, "CLAUDE.local.md"))) {
      claudeMdCount++;
    }

    // {cwd}/.claude/CLAUDE.md (alternative location)
    if (fs.existsSync(path.join(cwd, ".claude", "CLAUDE.md"))) {
      claudeMdCount++;
    }

    // {cwd}/.claude/CLAUDE.local.md
    if (fs.existsSync(path.join(cwd, ".claude", "CLAUDE.local.md"))) {
      claudeMdCount++;
    }

    // {cwd}/.claude/rules/*.md (recursive)
    rulesCount += countRulesInDir(path.join(cwd, ".claude", "rules"));

    // {cwd}/.mcp.json (project MCP config)
    mcpCount += countMcpServersInFile(path.join(cwd, ".mcp.json"));

    // {cwd}/.claude/settings.json (project settings)
    const projectSettings = path.join(cwd, ".claude", "settings.json");
    mcpCount += countMcpServersInFile(projectSettings);
    hooksCount += countHooksInFile(projectSettings);

    // {cwd}/.claude/settings.local.json (local project settings)
    const localSettings = path.join(cwd, ".claude", "settings.local.json");
    mcpCount += countMcpServersInFile(localSettings);
    hooksCount += countHooksInFile(localSettings);
  }

  return { claudeMdCount, rulesCount, mcpCount, hooksCount };
}
