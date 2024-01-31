function Quit() {
  Write-Host("Closing program, press [enter] to exit...") -NoNewLine
  $Host.UI.ReadLine()

  exit
}

function PrintConfig($config) {
  Write-Host "Arc Config Directory - $($($config)?.ArcConfigDirectory)" -ForegroundColor Cyan
  Write-Host "Backup Directory - $($($config)?.BackupDirectory)" -ForegroundColor Cyan
  Write-Host ""
}

function Startup($config) {
  Write-Host "Starting process...`n"
  Write-Host "Running with the following configuration:" -ForegroundColor Magenta
 
  PrintConfig $config
}

function ValidateArcConfigurationDirectory($config) {
  Write-Host "Verifying that the Arc configuration directory exists... " -NoNewLine

  if (!(test-path $($config).ArcConfigDirectory)) {
    Write-Host "[FAIL]" -ForegroundColor Red
    Write-Host "The Arc parent configuration directory you provided does not exist, please check your configuration file and try again." -ForgroundColor Red
    
    Quit
  }

  Write-Host "[OK]`n" -ForegroundColor Green
}

function GetUserPermission() {
  Write-Host "You need to close arc before running this script." -ForegroundColor Yellow
  Write-Host "Do you want to continue? [y/n]: " -NoNewLine -ForegroundColor Yellow

  $response = $Host.UI.ReadLine()

  if ($response -ne "y") {
    Quit
  }

  Write-Host ""
}
