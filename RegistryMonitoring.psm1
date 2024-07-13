function Start-RegistryMonitor {
    param (
        [string]$keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        [string]$botToken,
        [string]$chatID
    )

    try {
        
        $filter = [Microsoft.Win32.RegistryKeyChangeEvent]::new($keyPath)
        $query = New-Object System.Management.EventQuery
        $query.EventClassName = "__InstanceModificationEvent"
        $query.WithinInterval = "00:00:01"
        $query.Condition = $filter.QueryString

        $watcher = New-Object System.Management.ManagementEventWatcher
        $watcher.Query = $query

        $watcher.Start() | Out-Null
        Write-Log "Started monitoring registry key: $keyPath"

        while ($true) {
            try {
                $event = $watcher.WaitForNextEvent()
                $message = "Registry key '$($event.TargetInstance.keyName)' was modified by $($event.TargetInstance.UserName)"
                Write-Log $message
                Write-Host $message

                
                if ($botToken -and $chatID) {
                    Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
                    Write-Log "Telegram alert sent to chat ID $chatID"
                }
            } catch {
                Write-Log "Error processing registry event: $_" -level "ERROR"
            }
        }
    } catch {
        Write-Log "Error starting registry monitor: $_" -level "ERROR"
    }
}

function Write-Log {
    param (
        [string]$message,
        [string]$level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$level] $message"
    Add-Content -Path "script.log" -Value $logMessage
}


Export-ModuleMember -Function Start-RegistryMonitor, Write-Log
