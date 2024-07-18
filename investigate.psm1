function Get-IPInfo {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting local IP info..."
    $Ipinfoutput = "$FolderCreation\ipinfo.txt"
    Get-NetIPAddress | Out-File -Force -FilePath $Ipinfoutput
    $CSVExportLocation = "$CSVOutputFolder\IPConfiguration.csv"
    Get-NetIPAddress | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-ShadowCopies {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Shadow Copies..."
    $ShadowCopy = "$FolderCreation\ShadowCopies.txt"
    Get-CimInstance Win32_ShadowCopy | Out-File -Force -FilePath $ShadowCopy
    $CSVExportLocation = "$CSVOutputFolder\ShadowCopy.csv"
    Get-CimInstance Win32_ShadowCopy | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-OpenConnections {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Open Connections..."
    $ConnectionFolder = "$FolderCreation\Connections"
    mkdir -Force $ConnectionFolder | Out-Null
    $Ipinfoutput = "$ConnectionFolder\OpenConnections.txt"
    Get-NetTCPConnection -State Established | Out-File -Force -FilePath $Ipinfoutput
    $CSVExportLocation = "$CSVOutputFolder\OpenTCPConnections.csv"
    Get-NetTCPConnection -State Established | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}


function Get-AutoRunInfo {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting AutoRun info..."
    $AutoRunFolder = "$FolderCreation\Persistence"
    mkdir -Force $AutoRunFolder | Out-Null
    $RegKeyOutput = "$AutoRunFolder\AutoRunInfo.txt"
    Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | Format-List | Out-File -Force -FilePath $RegKeyOutput
    $CSVExportLocation = "$CSVOutputFolder\AutoRun.csv"
    Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}


function Get-InstalledDrivers {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Installed Drivers..."
    $AutoRunFolder = "$FolderCreation\Persistence"
    $RegKeyOutput = "$AutoRunFolder\InstalledDrivers.txt"
    driverquery | Out-File -Force -FilePath $RegKeyOutput
    $CSVExportLocation = "$CSVOutputFolder\Drivers.csv"
    (driverquery) -split "\n" -replace '\s\s+', ','  | Out-File -Force $CSVExportLocation -Encoding UTF8
}


function Get-ActiveUsers {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Active users..."
    $UserFolder = "$FolderCreation\UserInformation"
    mkdir -Force $UserFolder | Out-Null
    $ActiveUserOutput = "$UserFolder\ActiveUsers.txt"
    query user /server:$server | Out-File -Force -FilePath $ActiveUserOutput
    $CSVExportLocation = "$CSVOutputFolder\ActiveUsers.csv"
    (query user /server:$server) -split "\n" -replace '\s\s+', ','  | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}


function Get-LocalUsers {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Local users..."
    $UserFolder = "$FolderCreation\UserInformation"
    $ActiveUserOutput = "$UserFolder\LocalUsers.txt"
    Get-LocalUser | Format-Table | Out-File -Force -FilePath $ActiveUserOutput
    $CSVExportLocation = "$CSVOutputFolder\LocalUsers.csv"
    Get-LocalUser | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}


function Get-ActiveProcesses {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Active Processes..."
    $ProcessFolder = "$FolderCreation\ProcessInformation"
    New-Item -Path $ProcessFolder -ItemType Directory -Force | Out-Null
    $TaskListOutput = "$ProcessFolder\TaskList.txt"
    tasklist | Out-File -Force -FilePath $TaskListOutput
    $CSVExportLocation = "$CSVOutputFolder\TaskList.csv"
    (tasklist) -split "\n" -replace '\s\s+', ',' | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-SecurityEventCount {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder,
        [int]$sw
    )
    Write-Host "Collecting stats Security Events for the last $sw days..."

    # Create folder structure if it does not exist
    $SecurityEventsFolder = "$FolderCreation\SecurityEvents"
    if (-Not (Test-Path $SecurityEventsFolder)) {
        mkdir -Force $SecurityEventsFolder | Out-Null
    }

    $ProcessOutput = "$SecurityEventsFolder\EventCount.txt"
    $CSVExportLocation = "$CSVOutputFolder\SecEventCount.csv"

    try {
        # Get security events for the specified number of days
        $SecurityEvents = Get-EventLog -LogName Security -After (Get-Date).AddDays(-$sw)
        
        # Group by EventID and sort by count descending
        $GroupedEvents = $SecurityEvents | Group-Object -Property EventID -NoElement | Sort-Object -Property Count -Descending
        
        # Output result to files
        $GroupedEvents | Out-File -Force -FilePath $ProcessOutput
        $GroupedEvents | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8

        Write-Host "Security event counts collected successfully."
    } catch {
        Write-Warning "Failed to query the Security log: $_"
    }
}


function Get-SecurityEvents {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder,
        [int]$sw
    )
    Write-Host "Collecting security events..."
    $EventLogFolder = "$FolderCreation\EventLogs"
    $secEvent = "$EventLogFolder\SecEvent.txt"
    Get-WinEvent -FilterHashTable @{LogName='Security';ID=4625} -MaxEvents $sw | Format-List | Out-File -Force -FilePath $secEvent
    $CSVExportLocation = "$CSVOutputFolder\SecEvent.csv"
    Get-WinEvent -FilterHashTable @{LogName='Security';ID=4625} -MaxEvents $sw | Select-Object * | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-SecurityEventCount {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder,
        [int]$sw
    )
    Write-Host "Collecting security event counts..."
    $EventLogFolder = "$FolderCreation\EventLogs"
    mkdir -Force $EventLogFolder | Out-Null
    $secEventCount = "$EventLogFolder\SecEventCount.txt"
    wevtutil el | Foreach-Object { 
        "$($_) : $(wevtutil qe $_ /f:text /rd:true /c:$sw /q:`"*[System/Level=1]`" | Measure-Object | Select-Object -ExpandProperty Count)" 
    } | Out-File -Force -FilePath $secEventCount
    $CSVExportLocation = "$CSVOutputFolder\SecEventCount.csv"
    wevtutil el | Foreach-Object { 
        "$($_) : $(wevtutil qe $_ /f:text /rd:true /c:$sw /q:`"*[System/Level=1]`" | Measure-Object | Select-Object -ExpandProperty Count)" 
    } | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-SecurityEvents {
    param (
        [string]$FolderCreation,
        [string]$CSVOutputFolder,
        [int]$sw
    )
    Write-Host "Collecting security events..."
    $EventLogFolder = "$FolderCreation\EventLogs"
    $secEvent = "$EventLogFolder\SecEvent.txt"
    Get-WinEvent -FilterHashTable @{LogName='Security';ID=4625} -MaxEvents $sw | Format-List | Out-File -Force -FilePath $secEvent
    $CSVExportLocation = "$CSVOutputFolder\SecEvent.csv"
    Get-WinEvent -FilterHashTable @{LogName='Security';ID=4625} -MaxEvents $sw | Select-Object * | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-EventViewerFiles {
    param(
        [string]$FolderCreation
    )

    Write-Host "Collecting Important Event Viewer Files..."
    $EventViewer = "$FolderCreation\Event Viewer"
    mkdir -Force $EventViewer | Out-Null
    $evtxPath = "C:\Windows\System32\winevt\Logs"
    $channels = @(
        "Application",
        "Security",
        "System",
        "Microsoft-Windows-Sysmon%4Operational",
        "Microsoft-Windows-TaskScheduler%4Operational",
        "Microsoft-Windows-PowerShell%4Operational"
    )

    Get-ChildItem "$evtxPath\*.evtx" | Where-Object{$_.BaseName -in $channels} | ForEach-Object{
        Copy-Item -Path $_.FullName -Destination "$($EventViewer)\$($_.Name)"
    }
}

function Get-OfficeConnections {
    param(
       [String]$UserSid,
       [string]$FolderCreation,
       [string]$CSVOutputFolder
    )

    Write-Host "Collecting connections made from office applications..."
    $ConnectionFolder = "$FolderCreation\Connections"
    $OfficeConnection = "$ConnectionFolder\ConnectionsMadeByOffice.txt"
    $CSVExportLocation = "$CSVOutputFolder\OfficeConnections.csv"

    if($UserSid) {
        Get-ChildItem -Path "registry::HKEY_USERS\$UserSid\SOFTWARE\Microsoft\Office\16.0\Common\Internet\Server Cache" -ErrorAction 'SilentlyContinue' | Out-File -Force -FilePath $OfficeConnection
        Get-ChildItem -Path "registry::HKEY_USERS\$UserSid\SOFTWARE\Microsoft\Office\16.0\Common\Internet\Server Cache" -ErrorAction 'SilentlyContinue' | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
    }
    else {
        Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Internet\Server Cache -ErrorAction 'SilentlyContinue' | Out-File -Force -FilePath $OfficeConnection 
        Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Internet\Server Cache -ErrorAction 'SilentlyContinue' | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
    }
}

function Get-NetworkShares {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )
    Write-Host "Collecting Network Shares..."
    $NetShare = "$FolderCreation\Connections\NetworkShares.txt"
    if (-not (Test-Path -Path "$FolderCreation\Connections")) {
        New-Item -Path "$FolderCreation\Connections" -ItemType Directory -Force | Out-Null
    }
    net share | Out-File -Force -FilePath $NetShare
    $CSVExportLocation = "$CSVOutputFolder\NetworkShares.csv"
    net share | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8

     if($UserSid) {
        Get-ItemProperty -Path "registry::HKEY_USERS\$UserSid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\" -ErrorAction 'SilentlyContinue' | Format-Table | Out-File -Force -FilePath $NetShare
        Get-ItemProperty -Path "registry::HKEY_USERS\$UserSid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\" -ErrorAction 'SilentlyContinue' | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
    }
    else {
        Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\ -ErrorAction 'SilentlyContinue' | Format-Table | Out-File -Force -FilePath $NetShare
        Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\ -ErrorAction 'SilentlyContinue' | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
    }
}

function Get-SMBShares {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting SMB Shares..."
    $ConnectionFolder = "$FolderCreation\Connections"
    $ProcessOutput = "$ConnectionFolder\SMBShares.txt"
    Get-SmbShare | Out-File -Force -FilePath $ProcessOutput
    $CSVExportLocation = "$CSVOutputFolder\SMBShares.csv"
    Get-SmbShare | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-RDPSessions {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting RDS Sessions..."
    $ConnectionFolder = "$FolderCreation\Connections"
    $ProcessOutput = "$ConnectionFolder\RDPSessions.txt"
    $CSVExportLocation = "$CSVOutputFolder\RDPSessions.csv"
    qwinsta /server:localhost | Out-File -Force -FilePath $ProcessOutput
    (qwinsta /server:localhost) -split "\n" -replace '\s\s+', ',' | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-RemotelyOpenedFiles {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting Remotely Opened Files..."
    $ConnectionFolder = "$FolderCreation\Connections"
    $ProcessOutput = "$ConnectionFolder\RemotelyOpenedFiles.txt"
    $CSVExportLocation = "$CSVOutputFolder\RemotelyOpenedFiles.csv"
    openfiles | Out-File -Force -FilePath $ProcessOutput
    (openfiles) -split "\n" -replace '\s\s+', ',' | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-DNSCache {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting DNS Cache..."
    $ConnectionFolder = "$FolderCreation\Connections"
    $ProcessOutput = "$ConnectionFolder\DNSCache.txt"
    Get-DnsClientCache | Format-List | Out-File -Force -FilePath $ProcessOutput
    $CSVExportLocation = "$CSVOutputFolder\DNSCache.csv"
    Get-DnsClientCache | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
   
}

function Get-PowershellHistoryCurrentUser {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting Powershell History..."
    $PowershellConsoleHistory = "$FolderCreation\PowerShellHistory"
    mkdir -Force $PowershellConsoleHistory | Out-Null
    $PowershellHistoryOutput = "$PowershellConsoleHistory\PowershellHistoryCurrentUser.txt"
    history | Out-File -Force -FilePath $PowershellHistoryOutput
    $CSVExportLocation = "$CSVOutputFolder\PowerShellHistory.csv"
    history | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-PowershellConsoleHistory-AllUsers {
    param(
        [string]$FolderCreation
    )

    Write-Host "Collecting Console Powershell History for All Users..."
    $PowershellConsoleHistory = "$FolderCreation\PowerShellHistory"
    $usersDirectory = "C:\Users"
    $userDirectories = Get-ChildItem -Path $usersDirectory -Directory
    foreach ($userDir in $userDirectories) {
        $userName = $userDir.Name
        $historyFilePath = Join-Path -Path $userDir.FullName -ChildPath "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
        if (Test-Path -Path $historyFilePath -PathType Leaf) {
            $outputDirectory = "$PowershellConsoleHistory\$userDir.Name"
            mkdir -Force $outputDirectory | Out-Null
            Copy-Item -Path $historyFilePath -Destination $outputDirectory -Force
        }
    }
}

function Get-RecentlyInstalledSoftwareEventLogs {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting Recently Installed Software EventLogs..."
    $ApplicationFolder = "$FolderCreation\Applications"
    mkdir -Force $ApplicationFolder | Out-Null
    $ProcessOutput = "$ApplicationFolder\RecentlyInstalledSoftwareEventLogs.txt"
    Get-WinEvent -ProviderName msiinstaller | where id -eq 1033 | select timecreated,message | FL *| Out-File -Force -FilePath $ProcessOutput
    $CSVExportLocation = "$CSVOutputFolder\InstalledSoftware.csv"
    Get-WinEvent -ProviderName msiinstaller | where id -eq 1033 | select timecreated,message | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-RunningServices {
    param(
       [string]$FolderCreation,
       [string]$CSVOutputFolder
    )

    Write-Host "Collecting Running Services..."
    $ApplicationFolder = "$FolderCreation\Services"
    New-Item -Path $ApplicationFolder -ItemType Directory -Force | Out-Null
    $ProcessOutput = "$ApplicationFolder\RunningServices.txt"
    Get-Service | Where-Object {$_.Status -eq "Running"} | Format-List | Out-File -Force -FilePath $ProcessOutput
    $CSVExportLocation = "$CSVOutputFolder\RunningServices.csv"
    Get-Service | Where-Object {$_.Status -eq "Running"} | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-ScheduledTasks {
    param(
       [string]$FolderCreation,
       [string]$CSVOutputFolder
    )

    Write-Host "Collecting Scheduled Tasks..."
    $ScheduledTaskFolder = "$FolderCreation\ScheduledTask"
    mkdir -Force $ScheduledTaskFolder | Out-Null
    $ProcessOutput = "$ScheduledTaskFolder\ScheduledTasksList.txt"
    Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | Format-List | Out-File -Force -FilePath $ProcessOutput
    $CSVExportLocation = "$CSVOutputFolder\ScheduledTasks.csv"
    Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-ScheduledTasksRunInfo {
    param(
        [string]$FolderCreation,
        [string]$CSVOutputFolder
    )

    Write-Host "Collecting Scheduled Tasks Run Info..."
    $ScheduledTaskFolder = "$FolderCreation\ScheduledTask"
    $ProcessOutput = "$ScheduledTaskFolder\ScheduledTasksListRunInfo.txt"
    $CSVExportLocation = "$CSVOutputFolder\ScheduledTasksRunInfo.csv"
    Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | Get-ScheduledTaskInfo | Out-File -Force -FilePath $ProcessOutput
    Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"} | Get-ScheduledTaskInfo | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-ConnectedDevices {
    param(
       [string]$FolderCreation,
       [string]$CSVOutputFolder
    )

    Write-Host "Collecting Information about Connected Devices..."
    $DeviceFolder = "$FolderCreation\ConnectedDevices"
    New-Item -Path $DeviceFolder -ItemType Directory -Force | Out-Null
    $ConnectedDevicesOutput = "$DeviceFolder\ConnectedDevices.csv"
    Get-PnpDevice | Export-Csv -NoTypeInformation -Path $ConnectedDevicesOutput
    $CSVExportLocation = "$CSVOutputFolder\ConnectedDevices.csv"
    Get-PnpDevice | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVExportLocation -Encoding UTF8
}

function Get-ChromiumFiles {
    param(
       [String]$Username,
       [string]$FolderCreation
    )

    Write-Host "Collecting raw Chromium history and profile files..."
    $HistoryFolder = "$FolderCreation\Browsers\Chromium"
    New-Item -Path $HistoryFolder -ItemType Directory -Force | Out-Null

    $filesToCopy = @(
        'Preferences',
        'History'
    )

    Get-ChildItem "C:\Users\$Username\AppData\Local\*\*\User Data\*\" | Where-Object { `
        (Test-Path "$_\History") -and `
        [char[]](Get-Content "$($_.FullName)\History" -Encoding byte -TotalCount 'SQLite format'.Length) -join ''
    } | Where-Object { 
        $srcpath = $_.FullName
        $destpath = $_.FullName -replace "^C:\\Users\\$Username\\AppData\\Local",$HistoryFolder -replace "User Data\\",""
        New-Item -Path $destpath -ItemType Directory -Force | Out-Null

        $filesToCopy | ForEach-Object{
            $filesToCopy | Where-Object{ Test-Path "$srcpath\$_" } | ForEach-Object{ Copy-Item -Path "$srcpath\$_" -Destination "$destpath\$_" }
        }
    }
}



function Send-CompletionMessage {
    param (
        [string]$BotToken,
        [string]$ChatID
    )

    $ExecutionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "Data collection completed for $env:COMPUTERNAME on $ExecutionTime."
    Send-TelegramMessage -BotToken $BotToken -ChatID $ChatID -Message $Message
}

Export-ModuleMember -Function Get-IPInfo, Get-ShadowCopies, Get-OpenConnections, Get-AutoRunInfo, Get-InstalledDrivers, Get-ActiveUsers, Get-LocalUsers, Get-ActiveProcesses, Get-SecurityEventCount, Get-SecurityEvents , Send-CompletionMessage , Get-EventViewerFiles,Get-OfficeConnections,Get-NetworkShares,Get-SMBShares,Get-RDPSessions,Get-RemotelyOpenedFiles,Get-DNSCache,Get-PowershellHistoryCurrentUser,Get-PowershellConsoleHistory-AllUsers,Get-RecentlyInstalledSoftwareEventLogs,Get-RunningServices,Get-ScheduledTasks,Get-ScheduledTasksRunInfo,Get-ConnectedDevices
