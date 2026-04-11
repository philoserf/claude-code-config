---
argument-hint: "[package or scope]"
allowed-tools: Read, Bash, Glob
description: Audits project dependencies for vulnerabilities, outdated packages, and license issues. Use when checking dependency health, running security audits, or reviewing package versions. Covers native audit tools, version freshness, and license compliance.
---

Audit this project's dependencies. If $ARGUMENTS are provided, scope the audit accordingly (e.g., a specific package, dimension, or ecosystem).

## 1. Detect ecosystem

Identify which package managers are present and their lock files.

| Manifest                          | Ecosystem | Audit Tool       | Outdated Tool       |
| --------------------------------- | --------- | ---------------- | ------------------- |
| package.json                      | Node.js   | `npm audit`      | `npm outdated`      |
| pyproject.toml / requirements.txt | Python    | `pip-audit`      | `pip list -o`       |
| go.mod                            | Go        | `govulncheck`    | `go list -m -u`     |
| Cargo.toml                        | Rust      | `cargo audit`    | `cargo outdated`    |
| Gemfile                           | Ruby      | `bundle-audit`   | `bundle outdated`   |
| composer.json                     | PHP       | `composer audit` | `composer outdated` |

## 2. Three-dimension audit

Run each check using the ecosystem's native tooling:

- **Vulnerabilities** — run the native audit tool (see table above); classify findings by severity (critical / high / medium / low). If a tool isn't installed, note it in the report and skip that dimension rather than failing.
- **Outdated** — check for outdated dependencies; flag major version bumps separately from minor/patch; note packages more than 6 months behind latest
- **Licenses** — identify dependency licenses; flag copyleft (GPL, AGPL) and unknown licenses against the project's own license

## 3. Output format

Produce a structured report with:

- **Summary** — ecosystem, total deps, issue counts by severity
- **Vulnerabilities table** — package, severity, CVE, fix version
- **Outdated table** — package, current version, latest version, bump type
- **License issues** — package, license, concern
- **Prioritized remediation steps** — ordered by severity then effort

## Do not use when

- Auditing code quality rather than dependencies — use `code-audit`
- Prioritizing work across the full debt surface — use `tech-debt`
