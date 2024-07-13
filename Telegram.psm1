function Send-TelegramMessage {
    param (
        [string]$botToken,
        [string]$chatID,
        [string]$message
    )

    if (-not $botToken) {
        throw "Bot token is required."
    }
    if (-not $chatID) {
        throw "Chat ID is required."
    }

    # Define the Telegram API URL and parameters
    $url = "https://api.telegram.org/bot$botToken/sendMessage"
    $params = @{
        chat_id = $chatID
        text = $message
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json" -Body ($params | ConvertTo-Json)
        Write-Output "Message sent successfully: $response"
    } catch {
        Write-Error "Failed to send message to Telegram: $_"
    }
}

Export-ModuleMember -Function Send-TelegramMessage
