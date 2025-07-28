Set-StrictMode -Version Latest

sudo config --enable normal

if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

sudo winget import ./programs/installation/winget.json

# Read fresh environment variables after installation
$env:Path = [System.Environment]::GetEnvironmentVariable("Path")

$bin_dir = "$PSScriptRoot/bin"
New-Item $bin_dir -ItemType Directory -Force > $null
$bin_dir = Resolve-Path -Path $bin_dir

pwsh $PSScriptRoot/programs/installation/unlisted.ps1 --install_dir $bin_dir

$user_path = [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not ($user_path -like "*$bin_dir*")) {
	[System.Environment]::SetEnvironmentVariable("Path", $user_path + "$bin_dir;", "User")
	$env:Path += "$bin_dir;"
}