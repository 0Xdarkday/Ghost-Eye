# Import necessary modules
Import-Module -Name "$PSScriptRoot\Telegram.psm1"
Import-Module -Name "$PSScriptRoot\LogProcessing.psm1"
Import-Module -Name "$PSScriptRoot\RegistryMonitoring.psm1"

# Load configuration
. "$PSScriptRoot\config.ps1"

# Initialize an empty hash table to store IP-port mappings
$ipPortMap = @{}

if (Test-Path $logFile) {
    try {
        Write-Output "Reading log file: $logFile"
        Get-Content -Path $logFile | ForEach-Object {
            $logEntry = $_ -split ' '
            Process-LogEntry -logEntry $logEntry -ipPortMap $ipPortMap -botToken $botToken -chatID $chatID
        }
    } catch {
        Write-Error "Failed to read or process the log file: $_"
    }
} else {
    Write-Error "Log file not found: $logFile"
}

Track-SuccessfulLogins -botToken $botToken -chatID $chatID
Start-RegistryMonitor -botToken $botToken -chatID $chatID -keyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
