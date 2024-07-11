
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

function Track-LoginEvents {
    param (
        [string[]]$logEntry,
        [string]$botToken,
        [string]$chatID
    )

    # Extract relevant fields from the log entry
    $eventID = $logEntry[0]
    $accountName = $logEntry[1]
    $accountDomain = $logEntry[2]
    $loginID = $logEntry[3]

    # Check for event ID 4672 (admin logins) or 4624 (successful logins)
    if ($eventID -eq 4672 -or $eventID -eq 4624) {
        $message = "Login Alert:`n"
        $message += "Event ID: $eventID`n"
        $message += "Account Name: $accountName`n"
        $message += "Account Domain: $accountDomain`n"
        $message += "Login ID: $loginID`n"

        # Send the alert message to Telegram
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
    }
}

Export-ModuleMember -Function Process-LogEntry, Track-LoginEvents
