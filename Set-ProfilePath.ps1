# Define the global profile path
$GlobalProfilePath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"

# Define the new $PROFILE override line
$NewProfileSetting = '$PROFILE = "~\.dotfiles\Microsoft.PowerShell_profile.ps1"'

# Check if the directory exists
$GlobalProfileDir = Split-Path -Parent $GlobalProfilePath
if (-not (Test-Path $GlobalProfileDir)) {
    Write-Host "Creating directory: $GlobalProfileDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $GlobalProfileDir -Force
}

# Check if the global profile file exists, and create it if necessary
if (-not (Test-Path $GlobalProfilePath)) {
    Write-Host "Creating global profile file: $GlobalProfilePath" -ForegroundColor Yellow
    New-Item -ItemType File -Path $GlobalProfilePath -Force
}

# Add the new $PROFILE setting if it doesn't already exist in the file
if (-not (Get-Content $GlobalProfilePath | Select-String -Pattern '\$PROFILE =')) {
    Write-Host "Adding new $PROFILE setting to the global profile." -ForegroundColor Green
    Add-Content -Path $GlobalProfilePath -Value $NewProfileSetting
} else {
    Write-Host "The $PROFILE setting already exists in the global profile." -ForegroundColor Cyan
}

# Display success message
Write-Host "Global profile updated: $GlobalProfilePath" -ForegroundColor Green

