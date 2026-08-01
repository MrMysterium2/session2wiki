# Contributing

Thanks for considering a contribution. This is a small, focused set of bash
tools, so the process is intentionally lightweight.

## Reporting bugs / suggesting features

Open an [issue](../../issues) with:
- What you expected to happen vs. what actually happened
- Your OS/distro and the output of `bash --version`
- Steps to reproduce (commands run, relevant `.env` keys — **never** paste
  actual credentials)

## Submitting changes

1. Fork the repository and create a branch off `main`
2. Make your changes; keep `bin/log-start` and `bin/wiki-edit.sh` POSIX-ish
   bash without unnecessary external dependencies
3. Test manually against a real (or disposable test) MediaWiki instance —
   there is currently no automated test suite
4. Update `README.md` if behavior, configuration, or setup steps change
5. Open a pull request describing what changed and why

## Code style

- `set -u` at minimum; avoid `set -e` in anything meant to be sourced into an
  interactive shell (it will kill the user's session on the first error)
- Prefer explicit variable names over cryptic ones, even in a small script
- No secrets, real hostnames, or personal paths in example code — use the
  same placeholder style as the existing `.env.example`
