#!/bin/bash
# Hook: PostToolUse — fires after tool calls.
# Notifies on write/exec tools and always on errors.
# Set NOTIFY_TOOLS env var to control which tools trigger notifications (default: Bash,Write,Edit,Agent).

DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT=$(cat 2>/dev/null || echo "{}")
NOTIFY_TOOLS="${NOTIFY_TOOLS:-Bash,Write,Edit,Agent}"

python3 - "$DIR" "$NOTIFY_TOOLS" <<'PYEOF'
import sys, json, subprocess, os

notify_dir = sys.argv[1]
notify_tools = set(t.strip() for t in sys.argv[2].split(","))

try:
    d = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)

tool_name = d.get("tool_name", "Unknown")
tool_response = d.get("tool_response", {})

is_error = False
if isinstance(tool_response, dict):
    is_error = (
        tool_response.get("is_error", False)
        or (isinstance(tool_response.get("exit_code"), int) and tool_response["exit_code"] != 0)
    )

script = os.path.join(notify_dir, "notify.sh")

if is_error:
    subprocess.run([script, "Claude Code — Error", f"{tool_name} failed", "Basso"])
elif tool_name in notify_tools:
    label = {
        "Bash": "Command executed",
        "Write": "File written",
        "Edit":  "File edited",
        "Agent": "Sub-agent finished",
    }.get(tool_name, f"{tool_name} completed")
    subprocess.run([script, "Claude Code", label, "Tink"])
PYEOF
