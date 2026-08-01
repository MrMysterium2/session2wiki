# Security Policy

## Reporting a vulnerability

If you find a security issue (e.g. a way credentials could leak, an
injection vector in the anchor-insertion logic, etc.), please **do not**
open a public issue. Instead, report it privately via GitHub's
[private vulnerability reporting](../../security/advisories/new) feature,
or contact the repository owner directly.

Please include:
- A description of the issue and its potential impact
- Steps to reproduce, if possible
- Affected version/commit

## Scope notes

- This project is not affiliated with or endorsed by the MediaWiki project.
- Credentials belong exclusively in `.env` (git-ignored) and are read via
  environment variables — never hardcode credentials in the scripts
  themselves or in a pull request.
- `wiki-edit.sh` uses a MediaWiki BotPassword, not a full account login —
  if you're deploying this, scope that bot account's rights to the minimum
  needed (edit rights on the relevant page(s) only).

## Supported versions

This is a small, actively maintained single-branch project. Only the latest
version on `main` is supported.
