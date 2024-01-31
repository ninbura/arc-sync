. $PSScriptRoot/shared-functions.ps1

function SyncArcConfigurationFiles($config, $configDirectory) {
  Write-Host "Copying configuration files from repo directory to Arc's configuration directory... " -NoNewLine -ForegroundColor Magenta

  if(!(test-path $($config)?.RepoDirectory)) {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "The repository directory does not exist, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  $configurationFiles =
    Get-ChildItem -Filter *.json -Path $($config)?.RepoDirectory | Where-Object { $($config)?.ConfigFilenames.Contains($_.Name) } | Select-Object -ExpandProperty FullName

  foreach ($filePath in $configurationFiles) {
    Copy-Item -Path $filePath -Destination $configDirectory -Force
  }

  Write-Host "[OK]`n" -ForegroundColor Green
}

function Conclude($config) {
  Write-Host "arc-sync completed successfully." -ForegroundColor Green
}

function main() {
  $config = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json
  Startup $config
  GetUserPermission
  $configDirectory = GetArcConfigDirectory $config
  ValidateArcConfigurationDirectory $config $configDirectory
  CloneOrPullBackupRepository $config
  SyncArcConfigurationFiles $config $configDirectory
  Conclude $config
}

main
