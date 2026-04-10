#!/bin/bash
# Hook: Notification — fires when Claude needs user attention / input.

DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT=$(cat 2>/dev/null || echo "{}")

# Skip when running inside cmux — it handles Notification forwarding itself.
[ -n "$CMUX_SURFACE_ID" ] && exit 0

MESSAGE=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('message', 'Waiting for your input'))
except Exception:
    print('Waiting for your input')
" <<< "$INPUT" 2>/dev/null || echo "Waiting for your input")

"$DIR/notify.sh" "Claude Code — Action Required" "$MESSAGE" "Ping"
