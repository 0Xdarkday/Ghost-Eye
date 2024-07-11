

Import-Module -Name "$PSScriptRoot\Telegram.psm1"
Import-Module -Name "$PSScriptRoot\LogProcessing.psm1"

# Load configuration
. "$PSScriptRoot\config.ps1"


$ipPortMap = @{}


try {
    Get-Content -Path $logFile | ForEach-Object {
        $logEntry = $_ -split ' '
        Process-LogEntry -logEntry $logEntry -ipPortMap $ipPortMap -botToken $botToken -chatID $chatID
    }
} catch {
    Write-Error "Failed to read or process the log file: $_"
}
