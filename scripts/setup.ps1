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

  if (!(test-path $profile.CurrentUserAllHosts)) {
    New-Item -Path $profile.CurrentUserAllHosts -ItemType File
  }

  write-host "[OK]`n" -ForegroundColor Green
}

function AddArcScriptsToProfile() {
  $profileContents = Get-Content -Path $profile.CurrentUserAllHosts -Raw
  $additionalContents = @(
    "# Arc Scripts",
    "Set-Alias -Name arc-backup -Value `"$PSScriptRoot/arc-backup.ps1`"",
    "Set-Alias -Name arc-sync -Value `"$PSScriptRoot/arc-sync.ps1`""
  )

  $profileAlreadyContainsArcScripts = $profileContents -match "arc-backup.ps1" -or $profileContents -match "arc-sync.ps1"

  if ($profileAlreadyContainsArcScripts) {
    write-host "Arc scripts already exist in profile, skipping...`n" -ForegroundColor Yellow
    
    Quit
  }

  write-host "Adding arc scripts to profile... " -NoNewLine

  if($profileContents.Length -eq 0) {
    $profileContents += $additionalContents.Join("`n")
  } else {
    if($profileContents -notmatch "\s[\r\n]$") { $profileContents += "`n" }

    $profileContents += $($additionalContents -join "`n")
  }

  try{
    Set-Content -Path $profile.CurrentUserAllHosts -Value $profileContents -NoNewLine -Force
  } catch {
    write-host "[FAIL]" -ForegroundColor Red
    write-host "There was an error adding arc scripts to profile, please check your configuration file and try again." -ForegroundColor Red

    Quit
  }

  write-host "[OK]`n" -ForegroundColor Green
}

function Conclude() {
  . $profile.CurrentUserAllHosts
  
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
