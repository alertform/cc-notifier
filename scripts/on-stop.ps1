# Hook: Stop — fires when Claude finishes a session.
# Reads the transcript to extract a one-line progress summary for the notification.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Force UTF-8 for CJK characters
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Read JSON from stdin
$inputJson = $null
$raw = ""
try {
    $raw = [Console]::In.ReadToEnd()
    $inputJson = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
} catch {}

# Extract summary from transcript
function Get-TranscriptSummary {
    param([string]$TranscriptPath)

    if (-not $TranscriptPath -or -not (Test-Path $TranscriptPath)) {
        return ""
    }

    try {
        $lines = Get-Content $TranscriptPath -Encoding UTF8 -ErrorAction Stop
    } catch {
        return ""
    }

    # Walk backwards to find last assistant message
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        try {
            $msg = $lines[$i] | ConvertFrom-Json -ErrorAction Stop
        } catch {
            continue
        }

        if ($msg.type -ne "assistant") { continue }

        $content = $msg.message.content
        $text = ""

        if ($content -is [System.Array]) {
            foreach ($item in $content) {
                if ($item.type -eq "text" -and $item.text) {
                    $text = $item.text
                    break
                }
            }
        } elseif ($content -is [string]) {
            $text = $content
        }

        $text = $text.Trim()
        if (-not $text) { continue }

        # Strip markdown symbols and collapse whitespace
        $text = $text -replace '[#*_~>`]', ''
        $text = $text -replace '`+', ''
        $text = $text -replace '\s+', ' '
        $text = $text.Trim()

        if ($text.Length -gt 120) {
            return $text.Substring(0, 117) + "..."
        }
        return $text
    }

    return ""
}

$transcriptPath = ""
if ($inputJson -and $inputJson.transcript_path) {
    $transcriptPath = $inputJson.transcript_path
}

$summary = Get-TranscriptSummary -TranscriptPath $transcriptPath

# Determine if error
$isError = $false
if ($raw -match '"is_error"\s*:\s*true') {
    $isError = $true
}

if ($isError) {
    $title = "Claude Code - Error"
    $message = if ($summary) { $summary } else { "Session ended with errors" }
    $sound = "error"
} else {
    $title = "Claude Code"
    $message = if ($summary) { $summary } else { "Task finished" }
    $sound = "success"
}

& "$ScriptDir\notify.ps1" -Title $title -Message $message -Sound $sound
