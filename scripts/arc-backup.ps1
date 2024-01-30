. $PSScriptRoot/shared-functions.ps1

function BackupArcConfigurationFiles($config) {
  Write-Host "Copying arc configuration files to your local repo directory... " -NoNewLine -ForegroundColor Magenta

  try {
    $configurationFiles = 
      Get-ChildItem -Filter *.json -Path $($config)?.ConfigDirectory | Where-Object { $($config)?.ConfigFilenames.Contains($_.Name) } | Select-Object -ExpandProperty FullName
    
    foreach ($filePath in $configurationFiles) {
      Copy-Item -Path $filePath -Destination $($config)?.RepoDirectory -Force
    }
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error copying the arc configuration files, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  Write-Host "[OK]`n" -ForegroundColor Green
}

function PushChangesToBackupRepository($config) {
  Write-Host "Pushing changes to backup repository..." -ForegroundColor Magenta

  try {
    git -C $($config)?.RepoDirectory add -A
    git -C $($config)?.RepoDirectory commit -m "$Env:COMPUTERNAME $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
    git -C $($config)?.RepoDirectory push
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error pushing the changes to the backup repository, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  Write-Host "Changes pushed successfully`n" -ForegroundColor Green
}

function Conclude($config) {
  Write-Host "arc-backup completed successfully." -ForegroundColor Green
}

function main() {
  $config = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json
  Startup $config
  GetUserPermission
  ValidateArcConfigurationDirectory $($config)?.ConfigDirectory
  CloneOrPullBackupRepository $config
  BackupArcConfigurationFiles $config
  PushChangesToBackupRepository $config 
  Conclude $config
  Quit
}

main
