#!/bin/bash
set -e

CLAUDE_DIR="${HOME}/.claude"
INSTALL_DIR="${CLAUDE_DIR}/scripts/cc-notifier"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

echo "Uninstalling cc-notifier..."

[ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR" && echo "  ✓ Scripts removed"

python3 - "$SETTINGS_FILE" <<'PYEOF'
import sys, json, os

settings_file = sys.argv[1]
if not os.path.exists(settings_file):
    sys.exit(0)

with open(settings_file) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
for key in ["Stop", "Notification", "PostToolUse"]:
    hooks.pop(key, None)

if hooks:
    settings["hooks"] = hooks
else:
    settings.pop("hooks", None)

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"  ✓ Hooks removed from {settings_file}")
PYEOF

echo "Done."
