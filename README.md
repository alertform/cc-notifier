# cc-notifier

macOS native notifications for Claude Code via hooks.

## Notifications

| Trigger | Sound | Message |
|---------|-------|---------|
| Task finished (Stop) | Glass | Last assistant message as progress summary |
| Needs input (Notification) | Ping | Claude's message |
| Tool executed (PostToolUse) | Tink | Tool name |
| Tool error | Basso | Tool name + "failed" |

The **Stop** notification extracts the last assistant message from the session transcript and shows it as a one-line summary in the banner.

## cmux compatibility

When running inside [cmux](https://cmux.app), Stop and Notification hooks are skipped — cmux handles those itself. PostToolUse (tool execution and errors) still fires via cc-notifier.

| Hook | Inside cmux | Outside cmux |
|------|-------------|--------------|
| Stop | cmux | cc-notifier |
| Notification | cmux | cc-notifier |
| PostToolUse | cc-notifier | cc-notifier |

## Install

```bash
git clone https://github.com/alertform/cc-notifier.git
cd cc-notifier
./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Configuration

Control which tools trigger PostToolUse notifications (default: `Bash,Write,Edit,Agent`):

```bash
export NOTIFY_TOOLS='Bash,Write,Edit,Agent'  # add/remove tools
export NOTIFY_TOOLS=''                        # errors only, no tool noise
```

Add to `~/.zshrc` to persist.

## Requirements

- macOS (uses `osascript` for notifications — works on all versions including macOS 14+)
- Python 3 (pre-installed on macOS)
