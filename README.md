# session2wiki

Two small bash tools for documenting terminal sessions: record a shell
session with clear input/output separation, and optionally push it — or any
other text — into an existing MediaWiki page without overwriting it.

## Tools

### `bin/log-start`

Records an interactive bash session using `script`. Every command and its
output goes into a log file; `nano`/`vim` calls are wrapped to additionally
log a before/after diff of the edited file. At the end of a session:

- Raw log: `NAME.log` (includes ANSI escape codes)
- Cleaned log: `NAME-clean.log` (control characters stripped via `sed`)
- Optional: upload the cleaned log as a new section on a MediaWiki page
  (default: `Logs`) via `docker exec` into the MediaWiki container
  (`maintenance/run.php getText.php` / `edit.php`).

```bash
log-start ufw-setup
# ... run commands ...
exit
```

### `bin/wiki-edit.sh`

Provides the `wiki_edit` bash function, which inserts text at a fixed
**anchor point** in an existing page via the MediaWiki Action API, instead of
replacing the page content (relevant because `Special:Import`/XML import
replaces a page's entire content — this avoids that).

```bash
source bin/wiki-edit.sh
wiki_edit "Logs" "== Marker ==" "\n=== New section ===\nText" "Edit summary"
```

Flow: fetch login token → log in → read current page content via
`action=raw` → insert text after the anchor (Python, aborts cleanly if the
anchor isn't found) → fetch CSRF token → `action=edit`.

## Requirements

- `bash`, `script` (usually part of `util-linux`)
- `curl`, `jq`, `python3`
- For the upload path in `log-start`: `docker` access to the MediaWiki
  container and `sudo` rights for `docker exec`

## Installation

Run the following commands in order. Replace anything in `<angle brackets>`
with your own value.

```bash
# 1. Install dependencies (Debian/Ubuntu; adjust for your distro)
sudo apt update
sudo apt install -y util-linux curl jq python3 git

# 2. Clone the repository
git clone https://github.com/MrMysterium2/session2wiki.git
cd session2wiki

# 3. Make the scripts executable
chmod +x bin/log-start bin/wiki-edit.sh

# 4. Create your local .env file (fill in the <placeholders> below,
#    then save and exit)
cat > .env << 'EOF'
LOG_START_LOGDIR="/home/<your-linux-user>/logs"
LOG_START_WIKI_CONTAINER="<your-mediawiki-container-name>"
LOG_START_WIKI_PAGE="Logs"
LOG_START_WIKI_USER="Admin"
LOG_START_WIKI_URL="https://<your-wiki-domain>"

WIKI_EDIT_URL="https://<your-wiki-domain>"
WIKI_EDIT_BOTUSER="<your-user>@<bot-name>"
WIKI_EDIT_BOTPASS="<your-bot-password>"
EOF

# 5. Open .env and replace the <placeholders> with your real values
nano .env

# 6. Make wiki_edit available in every new shell session
echo "source $(pwd)/bin/wiki-edit.sh" >> ~/.bashrc

# 7. Make log-start callable as a plain command from anywhere
sudo ln -s "$(pwd)/bin/log-start" /usr/local/bin/log-start

# 8. Reload your shell config
source ~/.bashrc
```

After this, `log-start <name>` and `wiki_edit "<page>" "<anchor>" "<text>" "<summary>"`
are available in any new terminal session.

### Quick test

```bash
# Should print a usage hint, not "command not found"
log-start

# Should run without a "command not found" error
type wiki_edit
```

## Notes

- Use a dedicated MediaWiki [BotPassword](https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:Bot_passwords)
  account for `wiki-edit.sh` with only the rights it needs, rather than your
  main admin account.
- Session logs can contain sensitive output (command history, config dumps,
  etc.) — review before uploading, and treat the log directory accordingly.

## License

MIT, see [LICENSE](LICENSE).
