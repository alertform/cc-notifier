# Hook: Notification — fires when Claude needs user attention / input.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Force UTF-8 for CJK characters
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Read JSON from stdin
$inputJson = $null
try {
    $raw = [Console]::In.ReadToEnd()
    $inputJson = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
} catch {}

$message = "Waiting for your input"
if ($inputJson -and $inputJson.message) {
    $message = $inputJson.message
    if ($message.Length -gt 120) {
        $message = $message.Substring(0, 117) + "..."
    }
}

& "$ScriptDir\notify.ps1" -Title "Claude Code - Action Required" -Message $message -Sound "info"
