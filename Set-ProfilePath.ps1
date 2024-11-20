# Script to change the PowerShell profile path

# Step 1: Define the new profile path
$NewProfilePath = "$HOME\dotfiles\Microsoft.PowerShell_profile.ps1"

# Step 4: Update the global PowerShell profile to use the new path
$GlobalProfilePath = $PROFILE.AllUsersAllHosts
Write-Host "Updating global PowerShell profile: $GlobalProfilePath" -ForegroundColor Cyan

# Add code to set $PROFILE in the global profile
if (-not (Test-Path -Path $GlobalProfilePath)) {
    Write-Host "Creating global profile file: $GlobalProfilePath" -ForegroundColor Yellow
    New-Item -ItemType File -Path $GlobalProfilePath -Force
}

# Ensure the $PROFILE variable is overridden in the global profile
$ProfileUpdate = "`$PROFILE = `"$NewProfilePath`""
if (-not (Get-Content $GlobalProfilePath | Select-String -Pattern "\`$PROFILE =")) {
    Add-Content -Path $GlobalProfilePath -Value $ProfileUpdate
    Write-Host "Added new profile path to global profile." -ForegroundColor Green
} else {
    Write-Host "Global profile already contains a profile override." -ForegroundColor Green
}

# Step 5: Reload PowerShell profile
. $NewProfilePath
Write-Host "Profile path updated and reloaded: $NewProfilePath" -ForegroundColor Green

