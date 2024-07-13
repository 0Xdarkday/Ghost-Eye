# Function to track specific event IDs and send alerts to Telegram
function Track-SuccessfulLogins {
    param (
        [string]$botToken,
        [string]$chatID
    )

    
    while ($true) {
        try {
            # Get the latest Event ID 4624 (successful logins)
            $event4624 = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 1
            # Get the latest Event ID 4672 (admin logins)
            $event4672 = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4672} -MaxEvents 1
            # Get the latest Event ID 4688 (new process creation)
            $event4688 = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4688} -MaxEvents 1
            # Get the latest PowerShell Event ID 4103 (Module Logging)
            $event4103 = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; ID=4103} -MaxEvents 1
            # Get the latest PowerShell Event ID 4104 (Script Block Logging)
            $event4104 = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; ID=4104} -MaxEvents 1
            
            if ($event4624) {
                Process-Event4624 -eventRecord $event4624 -botToken $botToken -chatID $chatID
            }

            if ($event4672) {
                Process-Event4672 -eventRecord $event4672 -botToken $botToken -chatID $chatID
            }

            if ($event4688) {
                Process-Event4688 -eventRecord $event4688 -botToken $botToken -chatID $chatID
            }
            
            if ($event4103) {
                Process-PSEvent4103 -eventRecord $event4103 -botToken $botToken -chatID $chatID
            }
            if ($event4104) {
                Process-PSEvent4104 -eventRecord $event4104 -botToken $botToken -chatID $chatID
            }


            Start-Sleep -Seconds 1500
        } catch {
            Write-Error "Error tracking logins: $_"
        }
    }
}


function Process-Event4624 {
    param (
        [System.Object]$eventRecord,
        [string]$botToken,
        [string]$chatID
    )

    Write-Output "Processing Event ID 4624: $($eventRecord.Id)"

    try {
       
        $eventID = $eventRecord.Id
        $timeCreated = $eventRecord.TimeCreated
        $subjectSecurityID = ($eventRecord.Properties[0]).Value
        $subjectAccountName = ($eventRecord.Properties[1]).Value
        $subjectAccountDomain = ($eventRecord.Properties[2]).Value
        $subjectLogonID = ($eventRecord.Properties[3]).Value
        $logonType = ($eventRecord.Properties[8]).Value
        $logonTypeDescription = Get-LogonTypeDescription -logonType $logonType
        $newLogonSecurityID = ($eventRecord.Properties[5]).Value
        $newLogonAccountName = ($eventRecord.Properties[6]).Value
        $newLogonAccountDomain = ($eventRecord.Properties[7]).Value
        $newLogonID = ($eventRecord.Properties[8]).Value
        $processID = ($eventRecord.Properties[9]).Value
        $processName = ($eventRecord.Properties[10]).Value

        Write-Output "Event ID: $eventID, Time Created: $timeCreated, Subject Account Name: $subjectAccountName, Subject Account Domain: $subjectAccountDomain, New Logon Account Name: $newLogonAccountName, New Logon Account Domain: $newLogonAccountDomain, Logon Type: $logonTypeDescription"

        
        $message = "Login Alert: "
        $message += "Event ID: $eventID, "
        $message += "Time Created: $timeCreated, "
        $message += "Subject Security ID: $subjectSecurityID, "
        $message += "Subject Account Name: $subjectAccountName, "
        $message += "Subject Account Domain: $subjectAccountDomain, "
        $message += "Subject Logon ID: $subjectLogonID, "
        $message += "Logon Type: $logonTypeDescription, "
        $message += "New Logon Security ID: $newLogonSecurityID, "
        $message += "New Logon Account Name: $newLogonAccountName, "
        $message += "New Logon Account Domain: $newLogonAccountDomain, "
        $message += "New Logon ID: $newLogonID, "
        $message += "Process ID: $processID, "
        $message += "Process Name: $processName"

        
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
    } catch {
        Write-Error "Failed to process event record: $_"
    }
}


function Process-Event4672 {
    param (
        [System.Object]$eventRecord,
        [string]$botToken,
        [string]$chatID
    )

    Write-Output "Processing Event ID 4672: $($eventRecord.Id)"

    try {
      
        $eventID = $eventRecord.Id
        $timeCreated = $eventRecord.TimeCreated
        $securityID = ($eventRecord.Properties[0]).Value
        $accountName = ($eventRecord.Properties[1]).Value
        $accountDomain = ($eventRecord.Properties[2]).Value
        $logonID = ($eventRecord.Properties[3]).Value

        Write-Output "Event ID: $eventID, Time Created: $timeCreated, Security ID: $securityID, Account Name: $accountName, Account Domain: $accountDomain, Logon ID: $logonID"

       
        $message = "Admin Login Alert: "
        $message += "Event ID: $eventID, "
        $message += "Time Created: $timeCreated, "
        $message += "Security ID: $securityID, "
        $message += "Account Name: $accountName, "
        $message += "Account Domain: $accountDomain, "
        $message += "Logon ID: $logonID"

        
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
    } catch {
        Write-Error "Failed to process event record: $_"
    }
}


function Process-Event4688 {
    param (
        [System.Object]$eventRecord,
        [string]$botToken,
        [string]$chatID
    )

    Write-Output "Processing Event ID 4688: $($eventRecord.Id)"

    try {
      
        $eventID = $eventRecord.Id
        $timeCreated = $eventRecord.TimeCreated
        $newProcessID = ($eventRecord.Properties[4]).Value
        $newProcessName = ($eventRecord.Properties[5]).Value
        $securityID = ($eventRecord.Properties[0]).Value
        $accountName = ($eventRecord.Properties[1]).Value
        $accountDomain = ($eventRecord.Properties[2]).Value
        $logonID = ($eventRecord.Properties[3]).Value
        $creatorProcessID = ($eventRecord.Properties[6]).Value
        $creatorProcessName = ($eventRecord.Properties[7]).Value

        Write-Output "Event ID: $eventID, Time Created: $timeCreated, New Process ID: $newProcessID, New Process Name: $newProcessName, Security ID: $securityID, Account Name: $accountName, Account Domain: $accountDomain, Logon ID: $logonID, Creator Process ID: $creatorProcessID, Creator Process Name: $creatorProcessName"

        
        $message = "New Process Creation Alert: "
        $message += "Event ID: $eventID, "
        $message += "Time Created: $timeCreated, "
        $message += "New Process ID: $newProcessID, "
        $message += "New Process Name: $newProcessName, "
        $message += "Security ID: $securityID, "
        $message += "Account Name: $accountName, "
        $message += "Account Domain: $accountDomain, "
        $message += "Logon ID: $logonID, "
        $message += "Creator Process ID: $creatorProcessID, "
        $message += "Creator Process Name: $creatorProcessName"

       
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
    } catch {
        Write-Error "Failed to process event record: $_"
    }
}


function Process-PSEvent4103 {
    param (
        [System.Object]$eventRecord,
        [string]$botToken,
        [string]$chatID
    )

    Write-Output "Processing PowerShell Event ID 4103: $($eventRecord.Id)"

    try {
       
        $eventID = $eventRecord.Id
        $timeCreated = $eventRecord.TimeCreated
        $scriptName = ($eventRecord.Properties[0]).Value
        $command = ($eventRecord.Properties[1]).Value

        Write-Output "Event ID: $eventID, Time Created: $timeCreated, Script Name: $scriptName, Command: $command"

        
        $message = "PowerShell Module Load Alert: "
        $message += "Event ID: $eventID, "
        $message += "Time Created: $timeCreated, "
        $message += "Script Name: $scriptName, "
        $message += "Command: $command"

       
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
    } catch {
        Write-Error "Failed to process event record: $_"
    }
}


function Process-PSEvent4104 {
    param (
        [System.Object]$eventRecord,
        [string]$botToken,
        [string]$chatID
    )

    Write-Output "Processing PowerShell Event ID 4104: $($eventRecord.Id)"

    try {
       
        $eventID = $eventRecord.Id
        $timeCreated = $eventRecord.TimeCreated
        $scriptBlock = ($eventRecord.Properties[0]).Value

        Write-Output "Event ID: $eventID, Time Created: $timeCreated, Script Block: $scriptBlock"

        
        $message = "PowerShell Script Block Logging Alert: "
        $message += "Event ID: $eventID, "
        $message += "Time Created: $timeCreated, "
        $message += "Script Block: $scriptBlock"

       
        Send-TelegramMessage -botToken $botToken -chatID $chatID -message $message
    } catch {
        Write-Error "Failed to process event record: $_"
    }
}


function Get-LogonTypeDescription {
    param (
        [int]$logonType
    )

    switch ($logonType) {
        2 { return "Interactive (local logon)" }
        3 { return "Network (i.e., connection to shared folder)" }
        4 { return "Batch (i.e., scheduled task)" }
        5 { return "Service (service startup)" }
        7 { return "Unlock (i.e., unlocking workstation)" }
        8 { return "NetworkCleartext (i.e., cleartext logon)" }
        9 { return "NewCredentials (i.e., runas)" }
        10 { return "RemoteInteractive (i.e., RDP)" }
        11 { return "CachedInteractive (i.e., cached credentials)" }
        default { return "Unknown Logon Type" }
    }
}

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


Export-ModuleMember -Function Track-SuccessfulLogins, Process-Event4624, Process-Event4672, Process-Event4688,Process-PSEvent4103,Process-PSEvent4104, Process-LogEntry

