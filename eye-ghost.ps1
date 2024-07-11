# Import necessary modules
Import-Module -Name "$PSScriptRoot\Telegram.psm1"
Import-Module -Name "$PSScriptRoot\LogProcessing.psm1"

# Load configuration
. "$PSScriptRoot\config.ps1"

# Initialize an empty hash table to store IP-port mappings
$ipPortMap = @{}

# Read and process the generic log file (if exists)
if (Test-Path $logFile) {
    try {
        Get-Content -Path $logFile | ForEach-Object {
            $logEntry = $_ -split ' '
            Process-LogEntry -logEntry $logEntry -ipPortMap $ipPortMap -botToken $botToken -chatID $chatID
        }
    } catch {
        Write-Error "Failed to read or process the log file: $_"
    }
}

# Define the event IDs to track
$eventIDs = @(4672, 4624)

# Read and process the Windows event log
try {
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=$eventIDs} | ForEach-Object {
        Track-LoginEvents -eventRecord $_ -botToken $botToken -chatID $chatID
    }
} catch {
    Write-Error "Failed to read or process the event log: $_"
}
