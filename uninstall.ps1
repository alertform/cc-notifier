# cc-notifier Windows uninstaller
# Usage: powershell -ExecutionPolicy Bypass -File uninstall.ps1

$ErrorActionPreference = "Stop"

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$InstallDir = Join-Path $ClaudeDir "scripts\cc-notifier"
$SettingsFile = Join-Path $ClaudeDir "settings.json"

Write-Host "Uninstalling cc-notifier..."

# Remove scripts
if (Test-Path $InstallDir) {
    Remove-Item $InstallDir -Recurse -Force
    Write-Host "  OK Removed $InstallDir"
} else {
    Write-Host "  - Scripts not found, skipping"
}

# Remove hooks from settings.json
if (Test-Path $SettingsFile) {
    $settings = Get-Content $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json

    if ($settings.hooks) {
        @("Stop", "Notification", "PostToolUse") | ForEach-Object {
            $hookName = $_
            $existing = $settings.hooks.$hookName
            if ($existing) {
                $filtered = @($existing | Where-Object {
                    $hooks = $_.hooks
                    -not ($hooks | Where-Object { $_.command -like "*cc-notifier*" })
                })
                if ($filtered.Count -eq 0) {
                    $settings.hooks.PSObject.Properties.Remove($hookName)
                } else {
                    $settings.hooks | Add-Member -NotePropertyName $hookName -NotePropertyValue $filtered -Force
                }
            }
        }

        $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
        Write-Host "  OK Hooks removed from $SettingsFile"
    }
}

Write-Host ""
Write-Host "Done! cc-notifier uninstalled."
