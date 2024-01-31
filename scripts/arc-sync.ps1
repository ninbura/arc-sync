. $PSScriptRoot/shared-functions.ps1

function DeleteConfigurationFiles($configDirectory) {
  Write-Host "Deleting configuration files from Arc's configuration directory... " -NoNewLine -ForegroundColor Magenta

  try {
    Remove-Item -Path "$configDirectory/*" -Recurse -Force
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error deleting the Arc configuration files, please check your configuration file and try again." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Quit
  }

  Write-Host ""
  Write-Host "Configuration files have been successfully deleted from arc's configuration directory.`n" -ForegroundColor Green
}

function SyncArcConfigurationFiles($config) {
  $latestBackup = Get-ChildItem -Path $($config)?.BackupDirectory -Filter "*.zip" `
    | Sort-Object -Property LastWriteTime -Descending `
    | Select-Object -First 1 -ExpandProperty FullName

  Write-Host "The latest backup is: $latestBackup" -ForegroundColor Cyan
  Read-Host "Do you want to continue? [y/n]: " -NoNewLine -ForegroundColor Yellow

  if ($response -ne "y") {
    Quit
  }

  DeleteConfigurationFiles $($config)?.ArcConfigDirectory

  Write-Host "Copying configuration files from backup directory to Arc's configuration directory... " -ForegroundColor Magenta

  try {
    Expand-Archive -Path $latestBackup -DestinationPath "$($($config)?.ArcConfigDirectory)/" -Force
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error copying the arc configuration files, please check your configuration file and try again." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Quit
  }

  Write-Host "Configuration files have been successfully copied from your backup directory.`n" -ForegroundColor Green
}

function Conclude() {
  Write-Host "arc-sync completed successfully." -ForegroundColor Green
}

function main() {
  $config = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json
  Startup $config
  GetUserPermission
  ValidateArcConfigurationDirectory $config
  SyncArcConfigurationFiles $config 
  Conclude
}

main
