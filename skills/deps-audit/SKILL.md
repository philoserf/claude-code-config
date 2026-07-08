---
argument-hint: "[package or scope]"
allowed-tools:
  - Read
  - Bash
  - Glob
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
- **Licenses** — identify dependency licenses using the ecosystem's license tool; determine the project's own license from its `LICENSE`/`LICENSE.md` file, or the manifest's `license` field (`package.json`, `pyproject.toml`, etc.) if no LICENSE file exists; flag licenses that conflict with the project's own — strong copyleft (GPL, AGPL) in a permissive or proprietary project is the main concern, whereas the same license in a matching copyleft project is fine; treat weak copyleft (LGPL, MPL, EPL) as conditional (usually OK for an unmodified, dynamically linked dependency); always flag unknown/unlicensed dependencies

| Ecosystem | License Tool        |
| --------- | ------------------- |
| Node.js   | `license-checker`   |
| Python    | `pip-licenses`      |
| Go        | `go-licenses`       |
| Rust      | `cargo-license`     |
| Ruby      | `license_finder`    |
| PHP       | `composer licenses` |

If no manifest is found, report that no ecosystem was detected; if multiple are found, run each and merge into one report.

**Multiple manifests, same ecosystem** (npm/yarn workspaces, Go multi-module repos, monorepo packages): glob for nested manifests (e.g. `**/package.json`, `**/go.mod`, excluding `node_modules`/`vendor`) and aggregate results per workspace/module rather than auditing only the repo root.

## 3. Output format

Produce a structured report with:

- **Summary** — ecosystem, total deps, issue counts by severity
- **Vulnerabilities table** — package, severity, CVE, fix version
- **Outdated table** — package, current version, latest version, bump type
- **License issues** — package, license, concern
- **Prioritized remediation steps** — ordered by severity then effort

Example:

> **Summary** — Node.js, 142 deps, 2 critical, 5 high, 1 license issue
>
> | Package  | Severity | CVE            | Fix Version |
> | -------- | -------- | -------------- | ----------- |
> | lodash   | critical | CVE-2021-23337 | 4.17.21     |
> | minimist | high     | CVE-2020-7598  | 1.2.6       |
>
> | Package | Current | Latest | Bump  |
> | ------- | ------- | ------ | ----- |
> | express | 4.17.1  | 4.19.2 | minor |
>
> **License issues** — `left-pad@GPL-3.0` conflicts with project's MIT license

## Do not use when

- Auditing code quality rather than dependencies — use `code-audit`
