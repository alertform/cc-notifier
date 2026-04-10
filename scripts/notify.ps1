# Core notification sender — Windows Toast Notifications
# Usage: notify.ps1 <title> <message> [sound]
# Sound options: success, error, info (maps to Windows system sounds)

param(
    [string]$Title = "Claude Code",
    [string]$Message = "Notification",
    [string]$Sound = "info"
)

# Force UTF-8 so Chinese/CJK characters survive the bash → powershell boundary
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Map sound names to Windows audio URIs
$soundUri = switch ($Sound) {
    "success" { "ms-winsoundevent:Notification.Default" }
    "error"   { "ms-winsoundevent:Notification.Looping.Call" }
    "info"    { "ms-winsoundevent:Notification.IM" }
    default   { "ms-winsoundevent:Notification.Default" }
}

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType=WindowsRuntime] | Out-Null

# Escape XML special characters
$safeTitle = [System.Security.SecurityElement]::Escape($Title)
$safeMessage = [System.Security.SecurityElement]::Escape($Message)

$templateXml = @"
<toast duration="short">
  <visual>
    <binding template="ToastGeneric">
      <text>$safeTitle</text>
      <text>$safeMessage</text>
    </binding>
  </visual>
  <audio src="$soundUri" />
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($templateXml)
$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
# Use PowerShell's registered AUMID — custom strings like "Claude Code" are silently ignored by Windows
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
