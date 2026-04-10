# cc-notifier Windows installer
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$InstallDir = Join-Path $ClaudeDir "scripts\cc-notifier"
$SettingsFile = Join-Path $ClaudeDir "settings.json"

Write-Host "Installing cc-notifier (Windows)..."

# Copy scripts
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Copy-Item "$ScriptDir\scripts\*.ps1" -Destination $InstallDir -Force
Write-Host "  OK Scripts installed to $InstallDir"

# Patch settings.json with hooks
$settings = @{}
if (Test-Path $SettingsFile) {
    $settings = Get-Content $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
}

if (-not $settings.hooks) {
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue @{} -Force
}

$pwsh = "powershell -ExecutionPolicy Bypass -File"
$hooks = @{
    Stop = @(@{
        hooks = @(@{
            type = "command"
            command = "$pwsh $InstallDir/on-stop.ps1"
        })
    })
    Notification = @(@{
        hooks = @(@{
            type = "command"
            command = "$pwsh $InstallDir/on-notification.ps1"
        })
    })
}

$settings.hooks | Add-Member -NotePropertyName "Stop" -NotePropertyValue $hooks.Stop -Force
$settings.hooks | Add-Member -NotePropertyName "Notification" -NotePropertyValue $hooks.Notification -Force

$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
Write-Host "  OK Hooks added to $SettingsFile"

Write-Host ""
Write-Host "Done! Notifications active for:"
Write-Host "  - Task finished  -> Windows Toast + last assistant message as summary"
Write-Host "  - Needs input    -> Windows Toast"
Write-Host ""
Write-Host "To also enable PostToolUse notifications, add the hook manually to settings.json."
