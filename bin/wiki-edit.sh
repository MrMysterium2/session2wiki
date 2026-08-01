#!/bin/bash
#
# wiki-edit.sh – provides the `wiki_edit` bash function for safely inserting
# text at a fixed anchor point in an existing MediaWiki page via the
# MediaWiki Action API, instead of overwriting the page.
#
# Usage (source it first):
#   source bin/wiki-edit.sh
#   wiki_edit "<page title>" "<anchor text>" "<text to insert>" "<edit summary>"
#
# Configuration via environment variables (see .env.example):
#   WIKI_EDIT_URL, WIKI_EDIT_BOTUSER, WIKI_EDIT_BOTPASS
#
# Credentials should always be provided via .env — never hardcoded here.
# Use a dedicated MediaWiki BotPassword (Special:BotPasswords) with the
# minimum required rights, not your main admin account.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${WIKI_EDIT_ENV:-$SCRIPT_DIR/../.env}"
[ -f "$ENV_FILE" ] && source "$ENV_FILE"

WIKI="${WIKI_EDIT_URL:?Error: WIKI_EDIT_URL not set – see .env.example}"
API="$WIKI/api.php"
BOTUSER="${WIKI_EDIT_BOTUSER:?Error: WIKI_EDIT_BOTUSER not set}"
BOTPASS="${WIKI_EDIT_BOTPASS:?Error: WIKI_EDIT_BOTPASS not set}"

wiki_edit() {
  local PAGE="$1" ANCHOR="$2" ADDITION="$3" SUMMARY="$4"
  local COOKIES
  COOKIES=$(mktemp)

  local LOGINTOKEN
  LOGINTOKEN=$(curl -sk -c "$COOKIES" -b "$COOKIES" \
    "$API?action=query&meta=tokens&type=login&format=json" | jq -r '.query.tokens.logintoken')

  curl -sk -c "$COOKIES" -b "$COOKIES" \
    --data-urlencode "lgname=$BOTUSER" --data-urlencode "lgpassword=$BOTPASS" \
    --data-urlencode "lgtoken=$LOGINTOKEN" "$API?action=login&format=json" > /dev/null

  local CURRENT
  CURRENT=$(curl -sk -b "$COOKIES" "$WIKI/index.php?title=$PAGE&action=raw")

  local NEW
  NEW=$(WE_ANCHOR="$ANCHOR" WE_ADDITION="$ADDITION" WE_CURRENT="$CURRENT" python3 <<'PYEOF'
import sys, os
anchor = os.environ["WE_ANCHOR"]
addition = os.environ["WE_ADDITION"]
text = os.environ["WE_CURRENT"]
if anchor not in text:
    print("ANCHOR NOT FOUND – aborting, nothing changed", file=sys.stderr)
    sys.exit(1)
idx = text.index(anchor) + len(anchor)
sys.stdout.write(text[:idx] + addition + text[idx:])
PYEOF
)

  if [ -z "$NEW" ]; then
    echo "❌ $PAGE: aborted, anchor not found or page empty"
    rm -f "$COOKIES"
    return 1
  fi

  local CSRF
  CSRF=$(curl -sk -b "$COOKIES" "$API?action=query&meta=tokens&format=json" | jq -r '.query.tokens.csrftoken')

  local RESULT
  RESULT=$(curl -sk -b "$COOKIES" \
    --data-urlencode "title=$PAGE" \
    --data-urlencode "text=$NEW" \
    --data-urlencode "summary=$SUMMARY" \
    --data-urlencode "token=$CSRF" \
    --data-urlencode "format=json" \
    "$API?action=edit")

  echo "$RESULT" | jq .
  echo "✅ $PAGE processed"
  rm -f "$COOKIES"
}
