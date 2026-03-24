---
argument-hint: "[package or scope]"
allowed-tools: Read, Bash, Glob
description: Audits project dependencies for vulnerabilities, outdated packages, and license issues. Use when checking dependency health, running security audits, or reviewing package versions. Covers native audit tools, version freshness, and license compliance.
---

Audit this project's dependencies. If $ARGUMENTS are provided, scope the audit accordingly (e.g., a specific package, dimension, or ecosystem).

## 1. Detect ecosystem

Identify which package managers are present (package.json, requirements.txt/pyproject.toml, go.mod, Cargo.toml, Gemfile, composer.json, etc.) and their lock files.

## 2. Three-dimension audit

Run each check using the ecosystem's native tooling:

- **Vulnerabilities** — run the native audit tool (`npm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `bundle-audit`, etc.); classify findings by severity (critical / high / medium / low)
- **Outdated** — check for outdated dependencies; flag major version bumps separately from minor/patch; note packages more than 6 months behind latest
- **Licenses** — identify dependency licenses; flag copyleft (GPL, AGPL) and unknown licenses against the project's own license

## 3. Output format

Produce a structured report with:

- **Summary** — ecosystem, total deps, issue counts by severity
- **Vulnerabilities table** — package, severity, CVE, fix version
- **Outdated table** — package, current version, latest version, bump type
- **License issues** — package, license, concern
- **Prioritized remediation steps** — ordered by severity then effort
