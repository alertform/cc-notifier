# cc-notifier

Native desktop notifications for Claude Code via hooks.

## Platform Support

| Platform | Notification | Sound | Requires |
|----------|-------------|-------|----------|
| macOS | `osascript` banners | System sounds | Python 3 |
| Windows | Toast notifications | Windows sound events | PowerShell 5.1+ |

## Notifications

| Trigger | macOS Sound | Windows Sound |
|---------|-------------|---------------|
| Task finished (Stop) | Glass | Notification.Default |
| Task error (Stop) | Basso | Notification.Looping.Call |
| Needs input (Notification) | Ping | Notification.IM |
| Tool executed (PostToolUse) | Tink | Notification.IM |
| Tool error (PostToolUse) | Basso | Notification.Looping.Call |

The **Stop** notification extracts the last assistant message from the session transcript and shows it as a one-line summary.

## cmux compatibility (macOS)

When running inside [cmux](https://cmux.app), Stop and Notification hooks are skipped — cmux handles those itself. PostToolUse still fires via cc-notifier.

## Install

### macOS

```bash
git clone https://github.com/alertform/cc-notifier.git
cd cc-notifier
./install.sh
```

### Windows

```powershell
git clone https://github.com/alertform/cc-notifier.git
cd cc-notifier
powershell -ExecutionPolicy Bypass -File install.ps1
```

## Uninstall

### macOS

```bash
./uninstall.sh
```

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

## Configuration

Control which tools trigger PostToolUse notifications (default: `Bash,Write,Edit,Agent`):

```bash
# macOS / Linux
export NOTIFY_TOOLS='Bash,Write,Edit,Agent'  # add/remove tools
export NOTIFY_TOOLS=''                        # errors only, no tool noise

# Windows (PowerShell)
$env:NOTIFY_TOOLS = 'Bash,Write,Edit,Agent'
```

## Scripts

| Script | macOS | Windows | Purpose |
|--------|-------|---------|---------|
| notify | `.sh` | `.ps1` | Core sender |
| on-stop | `.sh` | `.ps1` | Session end — transcript summary |
| on-notification | `.sh` | `.ps1` | Claude needs input |
| on-tool-use | `.sh` | `.ps1` | Tool call completed |

## Notes

- **Windows**: Uses PowerShell's registered AUMID for Toast app ID (custom IDs are silently ignored). All scripts set UTF-8 encoding for CJK support.
- **macOS**: Uses `osascript` which works on all versions including macOS 14+.
