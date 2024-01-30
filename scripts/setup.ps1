function Quit() {
  Write-Host("Closing program, press [enter] to exit...") -NoNewLine
  $Host.UI.ReadLine()

  exit
}

function Startup() {
  write-host "Starting process...`n"
}

function VerifyOrCreateProfile() {
  write-host "Verifying or creating profile... " -NoNewLine

  if (!(test-path $profile.AllUsersAllHosts)) {
    New-Item -Path $profile.AllUsersAllHosts -ItemType File
  }

  write-host "[OK]`n" -ForegroundColor Green
}

function AddArcScriptsToProfile() {
  $profileContents = Get-Content -Path $profile.AllUsersAllHosts
  $finalIndex = $profileContents.Count - 1
  $additionalContents = @(
    "# Arc Scripts",
    "Set-Alias -Name arc-backup -Value `"& $PSScriptRoot/arc-backup.ps1`"",
    "Set-Alias -Name arc-sync -Value `"& $PSScriptRoot/arc-sync.ps1`""
  )
  $profileAlreadyContainsArcScripts = $profileContents | Where-Object { $_ -like "*arc-backup*" -or $_ -like "*arc-sync*" }

  if ($profileAlreadyContainsArcScripts) {
    write-host "Arc scripts already exist in profile, skipping...`n" -ForegroundColor Yellow
    
    Quit
  }

  write-host "Adding arc scripts to profile... " -NoNewLine

  if($profileContents.Length -eq 0 -or $profileContents[$finalindex] -match "[\r\n]") {
    $profileContents += $additionalContents
  } else {
    $profileContents += "`n" + $additionalContents
  }

  try{
    Set-Content -Path $profile.AllUsersAllHosts -Value $profileContents -Force
  } catch {
    write-host "[FAIL]" -ForegroundColor Red
    write-host "There was an error adding arc scripts to profile, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  write-host "[OK]`n" -ForegroundColor Green
}

function Conclude() {
  . $profile.AllUsersAllHosts
  
  write-host "arc-setup completed successfully." -ForegroundColor Green
}

function main() {
  Startup
  VerifyOrCreateProfile
  AddArcScriptsToProfile
  Conclude
  Quit
}

main
