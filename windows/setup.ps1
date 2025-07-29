Set-StrictMode -Version Latest

sudo config --enable normal

if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

sudo winget import $PSScriptRoot/installation/winget.json

# Read fresh environment variables after installation
$env:Path = [System.Environment]::GetEnvironmentVariable("Path")

$binDir = "$PSScriptRoot/bin"
New-Item $binDir -ItemType Directory -Force > $null
$binDir = Resolve-Path -Path $binDir

pwsh $PSScriptRoot/installation/unlisted.ps1 --install_dir $binDir

$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not ($userPath -like "*$binDir*")) {
	[System.Environment]::SetEnvironmentVariable("Path", $userPath + "$binDir;", "User")
	$env:Path += "$binDir;"
}

pwsh $PSScriptRoot/installation/fonts.ps1
