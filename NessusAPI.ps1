#############################################################################
# POWERSHELL SCRIPT FOR MANAGING SCAN RESULTS USING NESSUS PROFESSIONAL API #
# CODE BY: EBUKA JOHN ONYEJEGBU                                             #
# https://github.com/Johnng007                                              #
#############################################################################
param (
  [string]$Server = "https://localhost:8834",
  [string]$Format = "html",
  [string]$ID,
  [string]$Name

)

$RequiredPSVersion = 6

If ($PSVersionTable.PSVersion.Major -ge $RequiredPSVersion) {

  # Enter you Nessus API details Below
  $AccessKey = "****************************************************************"
  $secretKey = "****************************************************************"

  $ExportFileName = Get-Date –format 'yyyyMMdd_HHmmss'
  $SaveFile = "$ExportFileName.$Format"

  # SECTION: Fetch scan details

  Write-Host -Fore Cyan "[!] Fetching Scan Details..."

  $headers = @{}
  $headers.Add("accept", "application/json")
  $headers.Add("X-ApiKeys", "accessKey=$AccessKey;secretKey=$secretKey")
  $ScanURI = "$Server/scans"
  $response = Invoke-WebRequest -Uri $ScanURI -SkipCertificateCheck -Method GET -Headers $headers 

  $keyValueScan = ConvertFrom-Json $response.Content | Select-Object -expand "scans"

  if ($ID -and -not  $Name) {
    
    $result = $keyValueScan | Where-Object { $_.id -eq $ID } | Select-Object *
    
  }
  elseif ($Name -and -not $ID) {
    
    $result = $keyValueScan | Where-Object { $_.name -eq $Name } | Select-Object *
    
  }
  else {

    Write-Host "Please provide either ID or Name."
    exit 1
  }

  # SECTION: Display Important Info

  $ScanName = $result | Select-Object -expand "name"
  Write-Host "[!] Scan Name is:" -NoNewline; Write-Host -Fore DarkCyan "$ScanName"

  $ID = $result | Select-Object -expand "id"
  Write-Host "[!] Scan ID is:" -NoNewline; Write-Host -Fore DarkCyan "$ID"

  $ScanStatus = $result | Select-Object -expand "status"
  Write-Host "[!] Scan Status is:" -NoNewline; Write-Host -Fore DarkCyan "$ScanStatus"

  $ScanStartDate = $result | Select-Object -expand "creation_date"
  $readableDate = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($ScanStartDate))
  Write-Host "[!] Scan Start Date is:" -NoNewline; Write-Host -Fore DarkCyan "$readableDate"

  $ScanModDate = $result | Select-Object -expand "last_modification_date"
  $readableModDate = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($ScanModDate))
  Write-Host "[!] Scan Last Modified Date is:" -NoNewline; Write-Host -Fore DarkCyan "$readableModDate"

  $ScanOwner = $result | Select-Object -expand "owner"
  Write-Host "[!] Scan Owner is:" -NoNewline; Write-Host -Fore DarkCyan "$ScanOwner"

  Write-Host ""
  Write-Host ""

  Write-Host -Fore Cyan "[!] Exporting Scan.."


  # SECTION: EXPORT SCAN

  $headers = @{}
  $headers.Add("accept", "application/json")
  $headers.Add("content-type", "application/json")
  $headers.Add("X-ApiKeys", "accessKey=$AccessKey;secretKey=$secretKey")
  $ExportURI = "$Server/scans/$ID/export"
  $ExportBody = @"
{
	"format": "$Format",
	"chapters": "vuln_hosts_summary"
}
"@
  $response = Invoke-WebRequest -Uri $ExportURI -SkipCertificateCheck -Method POST -Headers $headers -ContentType 'application/json' -Body $ExportBody

  if ($response.statuscode -eq '200') {
    $keyValue = ConvertFrom-Json $response.Content | Select-Object -expand "file"
    Write-Host -Fore DarkCyan "[*] Export Successful. File ID: $keyValue"
  }
  else {
    Write-Host -Fore DarkCyan "[!] Export Not Successful Check Credentials"
  }

  # SECTION CHECK EXPORT STATUS
  Write-Host -Fore Cyan "[!] Checking Export Status..."
  $headers = @{}
  $headers.Add("accept", "application/json")
  $headers.Add("X-ApiKeys", "accessKey=$AccessKey;secretKey=$secretKey")
  $StatusURI = "$Server/scans/$ID/export/$keyValue/status"
  $response = Invoke-WebRequest -Uri $StatusURI -SkipCertificateCheck -Method GET -Headers $headers
		 
  if ($response.statuscode -eq '200') {
    $keyValueStatus = ConvertFrom-Json $response.Content | Select-Object -expand "status"
    Write-Host -Fore DarkCyan "[*] Export Status is: $keyValueStatus"
    Start-Sleep -Seconds 120
  }


  # RE-CHECK EXPORT STATUS AND download

  while ($true) {
    try {

      Write-Host -Fore Cyan "[!] Re-Trying Status Check"
      $response = Invoke-WebRequest -Uri $StatusURI -SkipCertificateCheck -Method GET -Headers $headers
      $keyValueStatus = ConvertFrom-Json $response.Content | Select-Object -expand "status"
      Write-Host -Fore DarkCyan "[*] Export Status is: $keyValueStatus"
      if ($keyValueStatus -eq 'ready') {
        Write-Host -Fore DarkCyan "[*] Starting Download!"
			
			
        # DOWNLOAD SCAN EXPORT

        $headers = @{}
        $headers.Add("accept", "application/octet-stream")
        $headers.Add("X-ApiKeys", "accessKey=$AccessKey;secretKey=$secretKey")
        $DownloadURI = "$Server/scans/$ID/export/$keyValue/download"
        Invoke-WebRequest -Uri $DownloadURI -Method GET -SkipCertificateCheck -Headers $headers -OutFile $SaveFile

        Write-Host -Fore DarkCyan "[!] Download Completed!"		
			
        break  
      }
      else {
        Write-Host -Fore Cyan "[!] Let's keep Waiting....."
      }
    }
    catch {
      Write-Host "Error: $($_.Exception.Message). Retrying in 120 seconds..."
    }

    Start-Sleep -Seconds 120

  }
		
	
}
Else {


  Write-Host -Fore DarkCyan "The Recommended PowerShell Version is 7"

  # Prompt the user to download and install PowerShell version 7
  $installChoice = Read-Host "Do you want to download and install PowerShell version 7? (Y/N)"

  if ($installChoice -eq 'Y' -or $installChoice -eq 'y') {
    
    $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.msi"

    
    $installerPath = "$env:TEMP\PowerShell7Installer.msi"

    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    
    $installProperties = "/i $installerPath /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1"

    
    Start-Process -FilePath msiexec -ArgumentList $installProperties -Wait
	
    Start-Sleep -Seconds 10
	
    # Check if the installation directory exists
    $installDirectory = "${env:SystemDrive}\Program Files\PowerShell\7"
    if (Test-Path $installDirectory) {
      Write-Host -Fore DarkCyan "[!] PowerShell version 7 has been installed successfully."
    }
    else {
      Write-Host -Fore DarkCyan "[!] PowerShell version 7 installation failed. Please check for errors."
    }
    
  }
  else {
    Write-Host -Fore DarkCyan "[!] PowerShell version 7 installation aborted."
  }



}
