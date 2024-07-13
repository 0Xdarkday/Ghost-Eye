# Ghost Eye - Advanced Attack Detection Tool

## Introduction

welcome to Ghost Eye is a PowerShell tool designed to monitor specific Windows event logs and send alerts to a specified Telegram chat. This tool can help administrators and security professionals stay informed about important system and security events in real-time.

## Features
 Ghost Eye is equipped to detect a wide array of aims, including but not limited to:
 
- **Detect Active Scan**
- **Track Security Event Logs**
   - Event ID 4624: Successful logons.
   - Event ID 4672: Special privileges assigned to new logons (administrative logons).
   - Event ID 4688: New process creation.
     
- **Track PowerShell Events**
   - Event ID 4103: Module logging (PowerShell script module logging).
   - Event ID 4104: Script block logging (PowerShell script execution).
     
- **Alerting**
 - **Telegram Notifications:**
   - Real-time alerts for specified events sent to a Telegram chat.
   - Customizable messages include relevant details about each event.
   
- **Error Handling**
  - The script includes error handling to log and report any issues that occur during event tracking and processing.

## Prerequisites
- A Telegram bot token and chat ID to receive alerts. Follow the instructions here to create a bot and obtain the botToken and chatID
- Well Replace your bot token and chat ID within the Config.ps1 file

## Installation
Get started with Ghost Eye by following these steps:
```sh
git clone https://github.com/yourusername/Ghost-Eye.git
cd Ghost-Eye
```

   
