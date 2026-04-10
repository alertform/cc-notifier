# cc-notifier

macOS native notifications for Claude Code via hooks.

## Notifications

| Trigger | Sound | Message |
|---------|-------|---------|
| Task finished (Stop) | Glass | Last assistant message as summary |
| Needs input (Notification) | Ping | Claude's message |
| Tool executed (PostToolUse) | Tink | Tool name |
| Tool error | Basso | Tool name + "failed" |

The **Stop** notification shows what Claude actually did — extracted from the session transcript and truncated to fit the banner.

## Install

```bash
git clone https://github.com/ziton/cc-notifier.git
cd cc-notifier
./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Configuration

Control which tools trigger notifications (default: `Bash,Write,Edit,Agent`):

```bash
export NOTIFY_TOOLS='Bash,Write,Edit,Agent'  # add/remove tools
export NOTIFY_TOOLS=''                        # errors only
```

Add to `~/.zshrc` to persist.
