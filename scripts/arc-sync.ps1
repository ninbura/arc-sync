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

  Write-Host "Configuration files have been successfully deleted from arc's configuration directory.`n" -ForegroundColor Green
}

function SyncArcConfigurationFiles($config) {
  Write-Host "Copying configuration files from backup directory to Arc's configuration directory... " -NoNewLine -ForegroundColor Magenta

  if(!(test-path $($config)?.BackupDirectory)) {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "The provided backup directory does not exist, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  $latestBackup = Get-ChildItem -Path $($config)?.BackupDirectory -Filter "*.zip" `
    | Sort-Object -Property LastWriteTime -Descending `
    | Select-Object -First 1 -ExpandProperty FullName

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
  SyncArcConfigurationFiles $($config)?.ArcConfigDirectory
  Conclude
}

main
