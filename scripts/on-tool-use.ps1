# Hook: PostToolUse — fires after tool calls.
# Notifies on write/exec tools and always on errors.
# Set NOTIFY_TOOLS env var to control which tools trigger (default: Bash,Write,Edit,Agent).

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Force UTF-8 for CJK characters
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Read JSON from stdin
$inputJson = $null
try {
    $raw = [Console]::In.ReadToEnd()
    $inputJson = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
} catch {
    exit 0
}

if (-not $inputJson) { exit 0 }

$notifyToolsRaw = if ($env:NOTIFY_TOOLS) { $env:NOTIFY_TOOLS } else { "Bash,Write,Edit,Agent" }
$notifyTools = $notifyToolsRaw -split ',' | ForEach-Object { $_.Trim() }

$toolName = if ($inputJson.tool_name) { $inputJson.tool_name } else { "Unknown" }

# Detect errors
$isError = $false
$toolResponse = $inputJson.tool_response
if ($toolResponse) {
    if ($toolResponse.is_error -eq $true) {
        $isError = $true
    }
    if ($null -ne $toolResponse.exit_code -and $toolResponse.exit_code -ne 0) {
        $isError = $true
    }
}

if ($isError) {
    & "$ScriptDir\notify.ps1" -Title "Claude Code - Error" -Message "$toolName failed" -Sound "error"
} elseif ($toolName -in $notifyTools) {
    $label = switch ($toolName) {
        "Bash"  { "Command executed" }
        "Write" { "File written" }
        "Edit"  { "File edited" }
        "Agent" { "Sub-agent finished" }
        default { "$toolName completed" }
    }
    & "$ScriptDir\notify.ps1" -Title "Claude Code" -Message $label -Sound "info"
}
