#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
INSTALL_DIR="${CLAUDE_DIR}/scripts/cc-notifier"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

echo "Installing cc-notifier..."

# Copy scripts
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/scripts/"*.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/"*.sh
echo "  ✓ Scripts installed to $INSTALL_DIR"

# Patch ~/.claude/settings.json with hooks
python3 - "$SETTINGS_FILE" "$INSTALL_DIR" <<'PYEOF'
import sys, json, os

settings_file = sys.argv[1]
install_dir   = sys.argv[2]

settings = {}
if os.path.exists(settings_file):
    with open(settings_file) as f:
        settings = json.load(f)

hooks = {
    "Stop": [{"matcher": "", "hooks": [{"type": "command", "command": f"{install_dir}/on-stop.sh"}]}],
    "Notification": [{"matcher": "", "hooks": [{"type": "command", "command": f"{install_dir}/on-notification.sh"}]}],
    "PostToolUse": [{"matcher": "", "hooks": [{"type": "command", "command": f"{install_dir}/on-tool-use.sh"}]}],
}

existing = settings.get("hooks", {})
existing.update(hooks)
settings["hooks"] = existing

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"  ✓ Hooks added to {settings_file}")
PYEOF

echo ""
echo "Done! Notifications active for:"
echo "  • Task finished  → Glass sound + last assistant message as summary"
echo "  • Needs input    → Ping sound"
echo "  • Tool executed  → Tink sound (Bash/Write/Edit/Agent)"
echo "  • Tool error     → Basso sound"
echo ""
echo "To change which tools notify: export NOTIFY_TOOLS='Bash,Write,Edit'"
