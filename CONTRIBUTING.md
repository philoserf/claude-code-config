# Contributing to claude-code-setup

Thank you for considering contributing! This repository contains a comprehensive Claude Code configuration showcasing best practices for customization and automation.

## Ways to Contribute

1. **Bug Reports**: Found an issue? Open an issue with details
2. **Improvements**: Better hooks, skills, or agents? Submit a PR
3. **Documentation**: Clarifications or examples? Always welcome
4. **New Skills/Agents**: Share your useful customizations

## Development Guidelines

### Before Submitting

- Test your changes thoroughly
- Run validation hooks to ensure correctness
- Update documentation if adding/changing features
- Follow existing naming conventions (see references/naming-conventions.md)

### Skill/Agent Standards

- Use YAML frontmatter with required fields
- Include comprehensive descriptions with trigger phrases
- Follow progressive disclosure (SKILL.md <500 lines, use references/)
- Add allowed-tools restrictions where appropriate
- Document use cases and examples

### Hook Standards

- Include proper shebang
- Handle JSON stdin correctly (where applicable)
- Use correct exit codes (0=allow, 2=block)
- Implement safe degradation (exit 0 on errors)
- Add clear stderr messages for debugging

### Code Quality

- Hooks should pass ShellCheck (for bash) or basic linting
- YAML frontmatter must be valid
- Markdown should follow .markdownlint.yaml rules
- No credentials, secrets, or personal data

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-skill`)
3. Make your changes
4. Commit with clear messages
5. Push to your fork
6. Open a Pull Request with description of changes

## Questions?

Open an issue for discussion or clarification.

## Code of Conduct

Be respectful, constructive, and helpful. We're all learning together.
