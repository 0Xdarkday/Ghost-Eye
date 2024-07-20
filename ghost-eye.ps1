# Import necessary modules
Import-Module -Name "$PSScriptRoot\Telegram.psm1"
Import-Module -Name "$PSScriptRoot\LogProcessing.psm1"
Import-Module -Name "$PSScriptRoot\RegistryMonitoring.psm1"
Import-Module -Name "$PSScriptRoot\investigate.psm1"
Import-Module -Name "$PSScriptRoot\zip.psm1"
# Load configuration
. "$PSScriptRoot\config.ps1"

# Initialize an empty hash table to store IP-port mappings
$ipPortMap = @{}

$logo = @"
  ______   __                              __            ________                    
 /      \ |  \                            |  \          |        \                   
|  $$$$$$\| $$____    ______    _______  _| $$_         | $$$$$$$$__    __   ______  
| $$ __\$$| $$    \  /      \  /       \|   $$ \ ______ | $$__   |  \  |  \ /      \ 
| $$|    \| $$$$$$$\|  $$$$$$\|  $$$$$$$ \$$$$$$|      \| $$  \  | $$  | $$|  $$$$$$\
| $$ \$$$$| $$  | $$| $$  | $$ \$$    \   | $$ __\$$$$$$| $$$$$  | $$  | $$| $$    $$
| $$__| $$| $$  | $$| $$__/ $$ _\$$$$$$\  | $$|  \      | $$_____| $$__/ $$| $$$$$$$$
 \$$    $$| $$  | $$ \$$    $$|       $$   \$$  $$      | $$     \\$$    $$ \$$     \
  \$$$$$$  \$$   \$$  \$$$$$$  \$$$$$$$     \$$$$        \$$$$$$$$_\$$$$$$$  \$$$$$$$
                                                                 |  \__| $$          
                                                                  \$$    $$          
                                                                   \$$$$$$   
                                        Made by Mahmoud Shaker
					Welcome to Ghost-Eye investigator     
"@
Write-Host $logo -ForegroundColor Yellow

# Read and process the generic log file (if exists)
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
 

# Creating output directory
Write-Host "Creating output directory..."
$CurrentPath = $pwd
$ExecutionTime = $(get-date -f yyyy-MM-dd)
$FolderCreation = "$CurrentPath\DFIR-$env:computername-$ExecutionTime"
mkdir -Force $FolderCreation | Out-Null
Write-Host "Output directory created: $FolderCreation..."
$currentUsername = (Get-WmiObject Win32_Process -f 'Name="explorer.exe"').GetOwner().User
$currentUserSid = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match 'S-1-5-21-\d+-\d+\-\d+\-\d+$' -and $_.ProfileImagePath -match "\\$currentUsername$"} | ForEach-Object{$_.PSChildName}
Write-Host "Current user: $currentUsername $currentUserSid"
 CSV Output for import in SIEM
$CSVOutputFolder = "$FolderCreation\CSV Results (SIEM Import Data)"
mkdir -Force $CSVOutputFolder | Out-Null
Write-Host "SIEM Export Output directory created: $CSVOutputFolder..."

 # Function to get the current user's SID
function Get-CurrentUserSid {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.User.Value
}

# Get the current user's SID
$UserSid = Get-CurrentUserSid

# Execute Functions
Get-IPInfo -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-ShadowCopies -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-OpenConnections -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-AutoRunInfo -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-InstalledDrivers -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-ActiveUsers -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-LocalUsers -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-ActiveProcesses -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-EventViewerFiles -FolderCreation $FolderCreation
Get-OfficeConnections -UserSid $SID -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-NetworkShares -UserSid $SID  -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-SMBShares -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-RDPSessions -FolderCreation $FolderCrea  -CSVOutputFolder $CSVOutputFolder
Get-RemotelyOpenedFiles -FolderCreation $FolderCrea  -CSVOutputFolder $CSVOutputFolder
Get-DNSCache -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-PowershellHistoryCurrentUser -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-PowershellConsoleHistory-AllUsers -FolderCreation $FolderCrea
Get-RecentlyInstalledSoftwareEventLogs -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-RunningServices -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-ScheduledTasks -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-ScheduledTasksRunInfo -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-ConnectedDevices -FolderCreation $FolderCrea -CSVOutputFolder $CSVOutputFolder
Get-RecentFiles -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder -days 7
Get-InstalledSoftware -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
Get-SystemInfo -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder
#Get-ChromiumFiles -Username "UserName" -FolderCreation $FolderCrea
#Get-SecurityEventCount -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder -sw 3
#Get-SecurityEvents -FolderCreation $FolderCreation -CSVOutputFolder $CSVOutputFolder -sw 3
# Sending Alerts to Telegram
Write-Host "Sending alerts to Telegram..."
# Send completion alert to Telegram
Send-TelegramMessage -BotToken $botToken -ChatID $chatID -Message "Data collection and monitoring setup completed on $env:COMPUTERNAME."
# Create zip file of the extracted data
$ZipFilePath = "$CurrentPath\DFIR-$env:computername-$ExecutionTime.zip"

Compress-ExtractedData -SourceFolder $FolderCreation -ZipFilePath $ZipFilePath
# Send the zip file to Telegram
Send-TelegramFile -botToken $botToken -chatID $chatID -filePath $ZipFilePath

# Define the number of iterations and interval
$iterations = 1
$interval = 1

# Run Track-SuccessfulLogins
Track-SuccessfulLogins -botToken $botToken -chatID $chatID -iterations $iterations -interval $interval
Start-RegistryMonitor -botToken $botToken -chatID $chatID -keyPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
