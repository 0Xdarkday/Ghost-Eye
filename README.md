# Ghost Eye - Advanced Attacks Detection Tool

## Introduction

welcome to Ghost Eye is a multi-functional PowerShell tool designed for cybersecurity monitoring and incident response. It tracks specific event IDs, monitors registry changes, and sends alerts to a Telegram bot. Additionally, it collects and processes various system data useful for digital forensics and incident response (DFIR).

## Features
 Ghost Eye is equipped to detect a wide array of aims, including but not limited to:
 
- **Detect Active Scan**
   - Detect active scan that occured on Network with alertion such as src & dest ip and dest port and  count
- **Real-time Registry Monitoring**
   - monitoring registry keys for changes and send alerts when modifications are detecte
-**Data Collection for SIEM**
   -Collects various system and security-related data, exporting it to CSV format for easy import into Security Information and Event Management (SIEM) systems.
- **Event-Based Monitoring**
   -Monitors Windows Event Log for specific security-related events such as successful logins, admin logins, new process creations, and PowerShell script executions.
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
## Example usages
  ```sh

   
