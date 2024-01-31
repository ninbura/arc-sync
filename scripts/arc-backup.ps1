. $PSScriptRoot/shared-functions.ps1

function BackupArcConfigurationFiles($configDirectory, $repoDirectory) {
  Write-Host "Copying arc configuration files to your local repo directory... " -NoNewLine -ForegroundColor Magenta

  try {
    $configurationFiles = 
      Get-ChildItem -Filter *.json -Path $configDirectory | Where-Object { $($config)?.ConfigFilenames.Contains($_.Name) } | Select-Object -ExpandProperty FullName
    
    foreach ($filePath in $configurationFiles) {
      Copy-Item -Path $filePath -Destination $repoDirectory -Force
    }
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error copying the arc configuration files, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  Write-Host "[OK]`n" -ForegroundColor Green
}

function PushChangesToBackupRepository($repoDirectory) {
  Write-Host "Pushing changes to backup repository..." -ForegroundColor Magenta

  try {
    git -C $repoDirectory add -A
    git -C $repoDirectory commit -m "$Env:COMPUTERNAME $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
    git -C $repoDirectory push
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error pushing the changes to the backup repository, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  Write-Host "Changes pushed successfully`n" -ForegroundColor Green
}

function Conclude() {
  Write-Host "arc-backup completed successfully." -ForegroundColor Green
}

function main() {
  $config = Get-Content -Path "$PSScriptRoot/../config.json" | ConvertFrom-Json
  Startup $config
  GetUserPermission
  $configDirectory = GetArcConfigDirectory $config
  ValidateArcConfigurationDirectory $config $configDirectory
  CloneOrPullBackupRepository $config
  BackupArcConfigurationFiles $configDirectory $($config)?.RepoDirectory
  PushChangesToBackupRepository $($config).RepoDirectory
  Conclude
  Quit
}

main
