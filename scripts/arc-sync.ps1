. ./shared-functions.ps1

function SyncArcConfigurationFiles($config) {
  Write-Host "Copying configuration files from repo directory to Arc's configuration directory... " -NoNewLine -ForegroundColor Magenta

  if(!(test-path $($config)?.RepoDirectory)) {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "The repository directory does not exist, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  $configurationFiles =
    Get-ChildItem -Filter *.json -Path $($config)?.RepoDirectory | Where-Object { $($config)?.ConfigFilenames.Contains($_.Name) } | Select-Object -ExpandProperty FullName

  foreach ($filePath in $configurationFiles) {
    Copy-Item -Path $filePath -Destination $($config)?.ConfigDirectory -Force
  }

  Write-Host "[OK]`n" -ForegroundColor Green
}

function Conclude($config) {
  Write-Host "arc-sync completed successfully." -ForegroundColor Green
}

function main() {
  $config = Get-Content -Path "../config.json" | ConvertFrom-Json
  Startup $config
  GetUserPermission
  ValidateArcConfigurationDirectory $($config)?.ConfigDirectory
  CloneOrPullBackupRepository $config
  SyncArcConfigurationFiles $config
  Conclude $config
}

main
