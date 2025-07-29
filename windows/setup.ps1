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


$windowsTerminalConfig = [PSCustomObject]@{
	Source = "$PSScriptRoot/config/windows-terminal/settings.json"
	Target = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
}
Remove-Item -Path $windowsTerminalConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $windowsTerminalConfig.Target -Target $windowsTerminalConfig.Source > $null