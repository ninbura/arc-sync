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
  Write-Host "Running with the following configuration:" -ForegroundColor Magenta
 
  PrintConfig $config
}

function GetUserPermission() {
  Write-Host "It is recommended that you close Arc before running this script" -ForegroundColor Yellow
  Write-Host "Do you want to continue? [y/n]: " -NoNewLine -ForegroundColor Yellow

  $response = $Host.UI.ReadLine()

  if ($response -ne "y") {
    Quit
  }

  Write-Host ""
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
