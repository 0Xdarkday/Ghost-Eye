
function Process-LogEntry {
    param (
        [string[]]$logEntry,
        [hashtable]$ipPortMap,
        [string]$botToken,
        [string]$chatID
    )

    # Extract relevant fields from the log entry
    $action = $logEntry[2]
    $srcIP = $logEntry[3]
    $destIP = $logEntry[4]
    $destPort = $logEntry[6]

    # Update the IP-port mapping
    if (-not $ipPortMap.ContainsKey($srcIP)) {
        $ipPortMap[$srcIP] = @{}
    }
    $ipPortMap[$srcIP][$destPort] = $true

    # Check for possible scan activity and send an alert
    if ($ipPortMap[$srcIP].Keys.Count -gt 200) {
        $message = "Possible scan activity detected:`n"
        $message += "Action: $action`n"
        $message += "Source IP: $srcIP`n"
        $message += "Destination IP: $destIP`n"
        $message += "Destination Port: $destPort`n"
        $message += "Time: $($logEntry[0]) $($logEntry[1])`n"
        $message += "Port Count: $($ipPortMap[$srcIP].Keys.Count)`n"

        # Send the alert message to Telegram
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message                
    }
}

Export-ModuleMember -Function Process-LogEntry
