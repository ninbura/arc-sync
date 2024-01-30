function Quit() {
  Write-Host("Closing program, press [enter] to exit...") -NoNewLine
  $Host.UI.ReadLine()

  exit
}

function PrintConfig($config) {
  Write-Host "Config Directory - $($($config)?.ConfigDirectory)" -ForegroundColor Cyan
  Write-Host "Repo Directory - $($($config)?.RepoDirectory)" -ForegroundColor Cyan
  Write-Host "Repo Url - $($($config)?.RepoUrl)" -ForegroundColor Cyan
  Write-Host "Git Username - $($($config)?.GitUsername)" -ForegroundColor Cyan
  Write-Host "Git Email - $($($config)?.GitEmail)`n" -ForegroundColor Cyan
}

function Startup($config) {
  Write-Host "Starting process...`n"
  Write-Host "running with the following configuration:" -ForegroundColor Magenta
 
  PrintConfig $config
}

function ValidateArcConfigurationDirectory($configDirectory) {
  Write-Host "Verifying that arc configuration directory exists... " -NoNewLine

  if (!(test-path $($configDirectory))) {
    Write-Host "p[FAIL]" -ForegroundColor Red
    Write-Host "The directory you provided does not exist, please check your configuration file and try again." -ForgroundColor Red
    
    Quit
  }

  Write-Host "[OK]`n" -ForegroundColor Green
}

function CloneOrPullBackupRepository($config) {
  try {
    Write-Host "Cloning/Pulling backup repository... " -ForegroundColor Magenta

    if (!(test-path $($config).RepoDirectory)) {
      git clone $($config)?.RepoUrl $($config)?.RepoDirectory --config user.name=$($($config).GitUsername) --config user.email=$($($config).GitEmail)
    } else {
      git -C $($config)?.RepoDirectory pull
    }
  } catch {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error cloning/pulling the repository, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  if (!(test-path $($config)?.RepoDirectory)) {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "There was an error cloning/pulling the repository, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  Write-Host "Repository cloned/pulled successfully.`n" -ForegroundColor Green
}

function CopyArcConfigurationFiles($config) {
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
  $config = Get-Content -Path "config.json" | ConvertFrom-Json
  Startup $config
  ValidateArcConfigurationDirectory $($config)?.ConfigDirectory
  CloneOrPullBackupRepository $config
  CopyArcConfigurationFiles $config
  PushChangesToBackupRepository $config 
  Conclude $config
  Quit
}

main
