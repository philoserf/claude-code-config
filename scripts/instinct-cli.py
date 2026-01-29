#!/usr/bin/env -S uv run
# /// script
# dependencies = []
# ///
"""
Instinct CLI - Manage instincts for Continuous Learning

Commands:
  status   - Show all instincts and their status
  import   - Import instincts from file or URL
  export   - Export instincts to file
  evolve   - Cluster instincts into skills/commands/agents
"""

import argparse
import sys
import re
import urllib.request
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────

LEARNING_DIR = Path.home() / ".claude" / "learning"
INSTINCTS_DIR = LEARNING_DIR / "instincts"
PERSONAL_DIR = INSTINCTS_DIR / "personal"
INHERITED_DIR = INSTINCTS_DIR / "inherited"
EVOLVED_DIR = LEARNING_DIR / "evolved"
OBSERVATIONS_FILE = LEARNING_DIR / "observations.jsonl"

# Ensure directories exist
for d in [
    PERSONAL_DIR,
    INHERITED_DIR,
    EVOLVED_DIR / "skills",
    EVOLVED_DIR / "commands",
    EVOLVED_DIR / "agents",
]:
    d.mkdir(parents=True, exist_ok=True)


# ─────────────────────────────────────────────
# Instinct Parser
# ─────────────────────────────────────────────


def _parse_yaml_value(value: str) -> str:
    """Parse a YAML value, handling quoted strings with colons."""
    value = value.strip()

    # Handle quoted strings (single or double)
    if len(value) >= 2:
        if (value.startswith('"') and value.endswith('"')) or (
            value.startswith("'") and value.endswith("'")
        ):
            # Remove quotes and handle escape sequences
            inner = value[1:-1]
            # Handle common escape sequences
            inner = inner.replace('\\"', '"').replace("\\'", "'")
            inner = inner.replace("\\n", "\n").replace("\\t", "\t")
            return inner

    # Unquoted value - strip any trailing quotes if present
    return value.strip('"').strip("'")


def _validate_confidence(value: float, instinct_id: str = None) -> float:
    """Validate and clamp confidence to 0.0-1.0 range."""
    if value < 0.0:
        if instinct_id:
            print(
                f"Warning: confidence {value} for '{instinct_id}' is below 0, clamping to 0.0",
                file=sys.stderr,
            )
        return 0.0
    if value > 1.0:
        if instinct_id:
            print(
                f"Warning: confidence {value} for '{instinct_id}' is above 1, clamping to 1.0",
                file=sys.stderr,
            )
        return 1.0
    return value


def parse_instinct_file(content: str) -> list[dict]:
    """Parse YAML-like instinct file format.

    Handles:
    - Quoted values containing colons (e.g., trigger: "when: this happens")
    - Multi-line values using | or > indicators
    - Escape sequences in quoted strings
    """
    instincts = []
    current = {}
    in_frontmatter = False
    in_multiline = False
    multiline_key = None
    multiline_lines = []
    content_lines = []

    for line in content.split("\n"):
        if line.strip() == "---":
            # Handle any pending multiline value
            if in_multiline and multiline_key:
                current[multiline_key] = "\n".join(multiline_lines).strip()
                in_multiline = False
                multiline_key = None
                multiline_lines = []

            if in_frontmatter:
                # End of frontmatter
                in_frontmatter = False
                if current:
                    current["content"] = "\n".join(content_lines).strip()
                    # Validate confidence if present
                    if "confidence" in current:
                        current["confidence"] = _validate_confidence(
                            current["confidence"], current.get("id")
                        )
                    instincts.append(current)
                    current = {}
                    content_lines = []
            else:
                # Start of frontmatter
                in_frontmatter = True
                if current:
                    current["content"] = "\n".join(content_lines).strip()
                    if "confidence" in current:
                        current["confidence"] = _validate_confidence(
                            current["confidence"], current.get("id")
                        )
                    instincts.append(current)
                current = {}
                content_lines = []
        elif in_frontmatter:
            # Handle multiline continuation
            if in_multiline:
                # Check if line is indented (continuation) or new key
                if line.startswith("  ") or line.startswith("\t") or not line.strip():
                    multiline_lines.append(line.strip())
                    continue
                else:
                    # End of multiline, save it
                    current[multiline_key] = "\n".join(multiline_lines).strip()
                    in_multiline = False
                    multiline_key = None
                    multiline_lines = []

            # Parse YAML-like frontmatter
            if ":" in line:
                # Find the first colon that's not inside quotes
                in_quotes = False
                quote_char = None
                colon_pos = -1

                for i, char in enumerate(line):
                    if char in ('"', "'") and (i == 0 or line[i - 1] != "\\"):
                        if not in_quotes:
                            in_quotes = True
                            quote_char = char
                        elif char == quote_char:
                            in_quotes = False
                    elif char == ":" and not in_quotes:
                        colon_pos = i
                        break

                if colon_pos == -1:
                    # No unquoted colon found, treat whole line as content
                    continue

                key = line[:colon_pos].strip()
                value = line[colon_pos + 1 :].strip()

                # Check for multiline indicators
                if value in ("|", ">", "|+", ">+", "|-", ">-"):
                    in_multiline = True
                    multiline_key = key
                    multiline_lines = []
                    continue

                # Parse the value
                parsed_value = _parse_yaml_value(value)

                if key == "confidence":
                    try:
                        current[key] = float(parsed_value)
                    except ValueError:
                        print(
                            f"Warning: Invalid confidence value '{parsed_value}', using 0.5",
                            file=sys.stderr,
                        )
                        current[key] = 0.5
                else:
                    current[key] = parsed_value
        else:
            content_lines.append(line)

    # Handle any pending multiline value at end
    if in_multiline and multiline_key:
        current[multiline_key] = "\n".join(multiline_lines).strip()

    # Don't forget the last instinct
    if current:
        current["content"] = "\n".join(content_lines).strip()
        if "confidence" in current:
            current["confidence"] = _validate_confidence(
                current["confidence"], current.get("id")
            )
        instincts.append(current)

    return [i for i in instincts if i.get("id")]


def load_all_instincts() -> list[dict]:
     """Load all instincts from personal and inherited directories."""
     instincts = []
 
     for directory in [PERSONAL_DIR, INHERITED_DIR]:
         if not directory.exists():
             continue
         for file in directory.glob("*.md"):
             try:
                 content = file.read_text()
                 parsed = parse_instinct_file(content)
                 for inst in parsed:
                     inst["_source_file"] = str(file)
                     inst["_source_type"] = directory.name
                 instincts.extend(parsed)
             except Exception as e:
                 print(f"Warning: Failed to parse {file}: {e}", file=sys.stderr)
 
     return instincts


# ─────────────────────────────────────────────
# Status Command
# ─────────────────────────────────────────────


def cmd_status(args):
    """Show status of all instincts."""
    instincts = load_all_instincts()

    if not instincts:
        print("No instincts found.")
        print("\nInstinct directories:")
        print(f"  Personal:  {PERSONAL_DIR}")
        print(f"  Inherited: {INHERITED_DIR}")
        return

    # Group by domain
    by_domain = defaultdict(list)
    for inst in instincts:
        domain = inst.get("domain", "general")
        by_domain[domain].append(inst)

    # Print header
    print(f"\n{'='*60}")
    print(f"  INSTINCT STATUS - {len(instincts)} total")
    print(f"{'='*60}\n")

    # Summary by source
    personal = [i for i in instincts if i.get("_source_type") == "personal"]
    inherited = [i for i in instincts if i.get("_source_type") == "inherited"]
    print(f"  Personal:  {len(personal)}")
    print(f"  Inherited: {len(inherited)}")
    print()

    # Print by domain
    for domain in sorted(by_domain.keys()):
        domain_instincts = by_domain[domain]
        print(f"## {domain.upper()} ({len(domain_instincts)})")
        print()

        for inst in sorted(domain_instincts, key=lambda x: -x.get("confidence", 0.5)):
            conf = inst.get("confidence", 0.5)
            conf_bar = "█" * int(conf * 10) + "░" * (10 - int(conf * 10))
            trigger = inst.get("trigger", "unknown trigger")
            inst.get("source", "unknown")

            print(f"  {conf_bar} {int(conf*100):3d}%  {inst.get('id', 'unnamed')}")
            print(f"            trigger: {trigger}")

            # Extract action from content
            content = inst.get("content", "")
            action_match = re.search(
                r"## Action\s*\n\s*(.+?)(?:\n\n|\n##|$)", content, re.DOTALL
            )
            if action_match:
                action = action_match.group(1).strip().split("\n")[0]
                print(
                    f"            action: {action[:60]}{'...' if len(action) > 60 else ''}"
                )

            print()

    # Observations stats
    if OBSERVATIONS_FILE.exists():
        obs_count = sum(1 for _ in open(OBSERVATIONS_FILE))
        print("─────────────────────────────────────────────────────────")
        print(f"  Observations: {obs_count} events logged")
        print(f"  File: {OBSERVATIONS_FILE}")

    print(f"\n{'='*60}\n")


# ─────────────────────────────────────────────
# Import Command
# ─────────────────────────────────────────────


def cmd_import(args):
    """Import instincts from file or URL."""
    source = args.source

    # Fetch content
    if source.startswith("http://") or source.startswith("https://"):
        print(f"Fetching from URL: {source}")
        try:
            with urllib.request.urlopen(source) as response:
                content = response.read().decode("utf-8")
        except Exception as e:
            print(f"Error fetching URL: {e}", file=sys.stderr)
            return 1
    else:
        path = Path(source).expanduser()
        if not path.exists():
            print(f"File not found: {path}", file=sys.stderr)
            return 1
        content = path.read_text()

    # Parse instincts
    new_instincts = parse_instinct_file(content)
    if not new_instincts:
        print("No valid instincts found in source.")
        return 1

    print(f"\nFound {len(new_instincts)} instincts to import.\n")

    # Load existing
    existing = load_all_instincts()
    existing_ids = {i.get("id") for i in existing}

    # Categorize
    to_add = []
    duplicates = []
    to_update = []

    for inst in new_instincts:
        inst_id = inst.get("id")
        if inst_id in existing_ids:
            # Check if we should update
            existing_inst = next((e for e in existing if e.get("id") == inst_id), None)
            if existing_inst:
                if inst.get("confidence", 0) > existing_inst.get("confidence", 0):
                    to_update.append(inst)
                else:
                    duplicates.append(inst)
        else:
            to_add.append(inst)

    # Filter by minimum confidence
    min_conf = args.min_confidence or 0.0
    to_add = [i for i in to_add if i.get("confidence", 0.5) >= min_conf]
    to_update = [i for i in to_update if i.get("confidence", 0.5) >= min_conf]

    # Display summary
    if to_add:
        print(f"NEW ({len(to_add)}):")
        for inst in to_add:
            print(
                f"  + {inst.get('id')} (confidence: {inst.get('confidence', 0.5):.2f})"
            )

    if to_update:
        print(f"\nUPDATE ({len(to_update)}):")
        for inst in to_update:
            print(
                f"  ~ {inst.get('id')} (confidence: {inst.get('confidence', 0.5):.2f})"
            )

    if duplicates:
        print(
            f"\nSKIP ({len(duplicates)} - already exists with equal/higher confidence):"
        )
        for inst in duplicates[:5]:
            print(f"  - {inst.get('id')}")
        if len(duplicates) > 5:
            print(f"  ... and {len(duplicates) - 5} more")

    if args.dry_run:
        print("\n[DRY RUN] No changes made.")
        return 0

    if not to_add and not to_update:
        print("\nNothing to import.")
        return 0

    # Confirm
    if not args.force:
        response = input(f"\nImport {len(to_add)} new, update {len(to_update)}? [y/N] ")
        if response.lower() != "y":
            print("Cancelled.")
            return 0

    # Write to inherited directory
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    source_name = Path(source).stem if not source.startswith("http") else "web-import"
    output_file = INHERITED_DIR / f"{source_name}-{timestamp}.yaml"

    all_to_write = to_add + to_update
    output_content = (
        f"# Imported from {source}\n# Date: {datetime.now().isoformat()}\n\n"
    )

    for inst in all_to_write:
        output_content += "---\n"
        output_content += f"id: {inst.get('id')}\n"
        output_content += f"trigger: \"{inst.get('trigger', 'unknown')}\"\n"
        output_content += f"confidence: {inst.get('confidence', 0.5)}\n"
        output_content += f"domain: {inst.get('domain', 'general')}\n"
        output_content += "source: inherited\n"
        output_content += f'imported_from: "{source}"\n'
        if inst.get("source_repo"):
            output_content += f"source_repo: {inst.get('source_repo')}\n"
        output_content += "---\n\n"
        output_content += inst.get("content", "") + "\n\n"

    output_file.write_text(output_content)

    print("\n✅ Import complete!")
    print(f"   Added: {len(to_add)}")
    print(f"   Updated: {len(to_update)}")
    print(f"   Saved to: {output_file}")

    return 0


# ─────────────────────────────────────────────
# Export Command
# ─────────────────────────────────────────────


def cmd_export(args):
    """Export instincts to file."""
    instincts = load_all_instincts()

    if not instincts:
        print("No instincts to export.")
        return 1

    # Filter by domain if specified
    if args.domain:
        instincts = [i for i in instincts if i.get("domain") == args.domain]

    # Filter by minimum confidence
    if args.min_confidence:
        instincts = [
            i for i in instincts if i.get("confidence", 0.5) >= args.min_confidence
        ]

    if not instincts:
        print("No instincts match the criteria.")
        return 1

    # Generate output
    output = f"# Instincts export\n# Date: {datetime.now().isoformat()}\n# Total: {len(instincts)}\n\n"

    for inst in instincts:
        output += "---\n"
        for key in ["id", "trigger", "confidence", "domain", "source", "source_repo"]:
            if inst.get(key):
                value = inst[key]
                if key == "trigger":
                    output += f'{key}: "{value}"\n'
                else:
                    output += f"{key}: {value}\n"
        output += "---\n\n"
        output += inst.get("content", "") + "\n\n"

    # Write to file or stdout
    if args.output:
        Path(args.output).write_text(output)
        print(f"Exported {len(instincts)} instincts to {args.output}")
    else:
        print(output)

    return 0


# ─────────────────────────────────────────────
# Evolve Command
# ─────────────────────────────────────────────


def _generate_skill(name, description, instincts_list):
     """Generate a skill file from clustered instincts."""
     content = f"""---
name: {name}
description: {description}
evolved_from: {[i.get('id') for i in instincts_list]}
---

# {name.replace('-', ' ').title()}

Auto-generated skill from clustered instincts.

## Pattern

This skill captures related patterns across your work.

## Instincts

"""
     for inst in instincts_list:
         content += f"- **{inst.get('id')}** ({inst.get('confidence', 0.5):.0%})\n"
         action = inst.get('content', '').split('\n')[0]
         if action:
             content += f"  {action[:80]}\n"
     
     return content


def _generate_command(name, description, instincts_list):
     """Generate a command file from clustered instincts."""
     content = f"""---
name: {name}
description: {description}
command: /{name}
evolved_from: {[i.get('id') for i in instincts_list]}
---

# {name.replace('-', ' ').title()}

Auto-generated command from clustered instincts.

## Steps

"""
     for idx, inst in enumerate(instincts_list, 1):
         content += f"{idx}. {inst.get('trigger', 'Unknown')}\n"
     
     return content


def _generate_agent(name, description, instincts_list):
     """Generate an agent file from clustered instincts."""
     content = f"""---
name: {name}
description: {description}
model: haiku
evolved_from: {[i.get('id') for i in instincts_list]}
---

# {name.replace('-', ' ').title()}

Auto-generated agent from clustered instincts.

## Process

This agent handles a complex process by applying multiple learned instincts.

## Instincts Applied

"""
     for inst in instincts_list:
         content += f"- {inst.get('id')} ({inst.get('confidence', 0.5):.0%})\n"
     
     return content


def cmd_evolve(args):
     """Analyze instincts and suggest evolutions to skills/commands/agents."""
     instincts = load_all_instincts()
 
     if len(instincts) < 3:
         print("Need at least 3 instincts to analyze patterns.")
         print(f"Currently have: {len(instincts)}")
         return 1
 
     print(f"\n{'='*60}")
     print(f"  EVOLVE ANALYSIS - {len(instincts)} instincts")
     print(f"{'='*60}\n")
 
     # Group by domain
     by_domain = defaultdict(list)
     for inst in instincts:
         domain = inst.get("domain", "general")
         by_domain[domain].append(inst)
 
     # High-confidence instincts by domain (candidates for skills)
     high_conf = [i for i in instincts if i.get("confidence", 0) >= 0.8]
     print(f"High confidence instincts (>=80%): {len(high_conf)}")
 
     # Find clusters (instincts with similar triggers)
     trigger_clusters = defaultdict(list)
     for inst in instincts:
         trigger = inst.get("trigger", "")
         # Normalize trigger
         trigger_key = trigger.lower()
         for keyword in [
             "when",
             "creating",
             "writing",
             "adding",
             "implementing",
             "testing",
         ]:
             trigger_key = trigger_key.replace(keyword, "").strip()
         trigger_clusters[trigger_key].append(inst)
 
     # Find clusters with 3+ instincts (good skill candidates)
     skill_candidates = []
     for trigger, cluster in trigger_clusters.items():
         if len(cluster) >= 2:
             avg_conf = sum(i.get("confidence", 0.5) for i in cluster) / len(cluster)
             skill_candidates.append(
                 {
                     "trigger": trigger,
                     "instincts": cluster,
                     "avg_confidence": avg_conf,
                     "domains": list(set(i.get("domain", "general") for i in cluster)),
                 }
             )
 
     # Sort by cluster size and confidence
     skill_candidates.sort(key=lambda x: (-len(x["instincts"]), -x["avg_confidence"]))
 
     print(f"\nPotential skill clusters found: {len(skill_candidates)}")
 
     generated_count = 0
 
     if skill_candidates:
         print("\n## SKILL CANDIDATES\n")
         for i, cand in enumerate(skill_candidates[:5], 1):
             print(f"{i}. Cluster: \"{cand['trigger']}\"")
             print(f"   Instincts: {len(cand['instincts'])}")
             print(f"   Avg confidence: {cand['avg_confidence']:.0%}")
             print(f"   Domains: {', '.join(cand['domains'])}")
             print("   Instincts:")
             for inst in cand["instincts"][:3]:
                 print(f"     - {inst.get('id')}")
             print()
             
             if args.generate:
                 skill_name = cand['trigger'].replace(" ", "-")[:30]
                 skill_desc = f"Skill for {cand['trigger']} patterns"
                 skill_content = _generate_skill(skill_name, skill_desc, cand["instincts"])
                 skill_file = EVOLVED_DIR / "skills" / f"{skill_name}.md"
                 skill_file.write_text(skill_content)
                 generated_count += 1
                 print(f"   ✓ Generated: {skill_file.name}\n")
 
     # Command candidates (workflow instincts with high confidence)
     workflow_instincts = [
         i
         for i in instincts
         if i.get("domain") == "workflow" and i.get("confidence", 0) >= 0.7
     ]
     if workflow_instincts:
         print(f"\n## COMMAND CANDIDATES ({len(workflow_instincts)})\n")
         for inst in workflow_instincts[:5]:
             trigger = inst.get("trigger", "unknown")
             # Suggest command name
             cmd_name = (
                 trigger.replace("when ", "")
                 .replace("implementing ", "")
                 .replace("a ", "")
             )
             cmd_name = cmd_name.replace(" ", "-")[:20]
             print(f"  /{cmd_name}")
             print(f"    From: {inst.get('id')}")
             print(f"    Confidence: {inst.get('confidence', 0.5):.0%}")
             print()
             
             if args.generate:
                 cmd_desc = inst.get('content', 'Generated command').split('\n')[0]
                 cmd_content = _generate_command(cmd_name, cmd_desc, [inst])
                 cmd_file = EVOLVED_DIR / "commands" / f"{cmd_name}.md"
                 cmd_file.write_text(cmd_content)
                 generated_count += 1
 
     # Agent candidates (complex multi-step patterns)
     agent_candidates = [
         c
         for c in skill_candidates
         if len(c["instincts"]) >= 3 and c["avg_confidence"] >= 0.75
     ]
     if agent_candidates:
         print(f"\n## AGENT CANDIDATES ({len(agent_candidates)})\n")
         for cand in agent_candidates[:3]:
             agent_name = cand["trigger"].replace(" ", "-")[:20] + "-agent"
             print(f"  {agent_name}")
             print(f"    Covers {len(cand['instincts'])} instincts")
             print(f"    Avg confidence: {cand['avg_confidence']:.0%}")
             print()
             
             if args.generate:
                 agent_desc = f"Agent for {cand['trigger']} patterns"
                 agent_content = _generate_agent(agent_name, agent_desc, cand["instincts"])
                 agent_file = EVOLVED_DIR / "agents" / f"{agent_name}.md"
                 agent_file.write_text(agent_content)
                 generated_count += 1
 
     if args.generate:
         print(f"\n✅ Generated {generated_count} evolved structures:")
         print(f"  Skills: {len(list((EVOLVED_DIR / 'skills').glob('*.md')))}")
         print(f"  Commands: {len(list((EVOLVED_DIR / 'commands').glob('*.md')))}")
         print(f"  Agents: {len(list((EVOLVED_DIR / 'agents').glob('*.md')))}")
     else:
         print(f"\n💡 Run with `--generate` to create these structures")
 
     print(f"\n{'='*60}\n")
     return 0


# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────


def main():
    parser = argparse.ArgumentParser(
        description="Instinct CLI for Continuous Learning v2"
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Status
    subparsers.add_parser("status", help="Show instinct status")

    # Import
    import_parser = subparsers.add_parser("import", help="Import instincts")
    import_parser.add_argument("source", help="File path or URL")
    import_parser.add_argument(
        "--dry-run", action="store_true", help="Preview without importing"
    )
    import_parser.add_argument("--force", action="store_true", help="Skip confirmation")
    import_parser.add_argument(
        "--min-confidence", type=float, help="Minimum confidence threshold"
    )

    # Export
    export_parser = subparsers.add_parser("export", help="Export instincts")
    export_parser.add_argument("--output", "-o", help="Output file")
    export_parser.add_argument("--domain", help="Filter by domain")
    export_parser.add_argument(
        "--min-confidence", type=float, help="Minimum confidence"
    )

    # Evolve
    evolve_parser = subparsers.add_parser("evolve", help="Analyze and evolve instincts")
    evolve_parser.add_argument(
        "--generate", action="store_true", help="Generate evolved structures"
    )

    args = parser.parse_args()

    if args.command == "status":
        return cmd_status(args)
    elif args.command == "import":
        return cmd_import(args)
    elif args.command == "export":
        return cmd_export(args)
    elif args.command == "evolve":
        return cmd_evolve(args)
    else:
        parser.print_help()
        return 1


if __name__ == "__main__":
    sys.exit(main() or 0)
