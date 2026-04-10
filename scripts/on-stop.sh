#!/bin/bash
# Hook: Stop — fires when Claude finishes a session.
# Reads the transcript to extract a one-line progress summary for the notification.

DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT=$(cat 2>/dev/null || echo "{}")

# --- Extract progress summary from transcript ---
SUMMARY=$(python3 - "$INPUT" <<'PYEOF'
import sys, json, re

raw = sys.argv[1]

# Get transcript path from hook payload
try:
    payload = json.loads(raw)
    transcript_path = payload.get("transcript_path", "")
except Exception:
    transcript_path = ""

def extract_summary(path):
    if not path:
        return ""
    try:
        with open(path) as f:
            lines = f.readlines()
    except Exception:
        return ""

    # Walk backwards to find the last non-empty assistant text
    for line in reversed(lines):
        try:
            msg = json.loads(line)
        except Exception:
            continue
        if msg.get("type") != "assistant":
            continue
        content = msg.get("message", {}).get("content", "")
        text = ""
        if isinstance(content, list):
            for item in content:
                if isinstance(item, dict) and item.get("type") == "text":
                    text = item.get("text", "")
                    break
        elif isinstance(content, str):
            text = content
        text = text.strip()
        if not text:
            continue
        # Clean up markdown and collapse whitespace
        text = re.sub(r"[#*`_~>]", "", text)
        text = re.sub(r"\s+", " ", text).strip()
        # Truncate to fit a notification banner (~120 chars)
        return text[:120] + ("…" if len(text) > 120 else "")
    return ""

print(extract_summary(transcript_path))
PYEOF
)

# Determine sound: error vs normal finish
if echo "$INPUT" | grep -qi '"is_error"\s*:\s*true'; then
    SOUND="Basso"
    TITLE="Claude Code — Error"
    MESSAGE="${SUMMARY:-Session ended with errors}"
else
    SOUND="Glass"
    TITLE="Claude Code"
    MESSAGE="${SUMMARY:-Task finished ✓}"
fi

"$DIR/notify.sh" "$TITLE" "$MESSAGE" "$SOUND"
