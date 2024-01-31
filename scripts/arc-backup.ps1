. $PSScriptRoot/shared-functions.ps1

function BackupArcConfigurationFiles($config) {
  Write-Host "Copressing/copying configuration files to backup directory... " -NoNewLine -ForegroundColor Magenta

  # todo: delete oldest archive if there's more than 10

  try {
    $configDirectory = $($config)?.ArcConfigDirectory
    $backupDirectory = $($config)?.BackupDirectory
    $computerName = $env:COMPUTERNAME
    $dateTime = Get-Date -Format "yyyy-MM-dd HH-mm-ss"
    $ProgressAction = [system.management.automation.actionpreference]::silentlycontinue

    Write-Host $ProgressAction.GetType()

    Compress-Archive -Path "$configDirectory/*" -DestinationPath "$backupDirectory/$computerName $dateTime.zip" -CompressionLevel Fastest -Force
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error copying the arc configuration files, please check your configuration file and try again." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Quit
  }

  Write-Host "Arc configuration backed up succesfully.`n" -ForegroundColor Green
}

function Conclude() {
  Write-Host "arc-backup completed successfully." -ForegroundColor Green
}

function main() {
  $config = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json
  Startup $config
  GetUserPermission
  ValidateArcConfigurationDirectory $config
  BackupArcConfigurationFiles $config
  Conclude
  Quit
}

main
