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

# Windows Terminal config
$windowsTerminalConfig = [PSCustomObject]@{
	Source = "$PSScriptRoot/config/windows-terminal/settings.json"
	Target = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
}
Remove-Item -Path $windowsTerminalConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $windowsTerminalConfig.Target -Target $windowsTerminalConfig.Source -ErrorAction Stop > $null


# Git config
$gitConfig = [PSCustomObject]@{
	Source = "$PSScriptRoot/config/git/.gitconfig"
	Target = "$HOME/.gitconfig"
}
Remove-Item -Path $gitConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $gitConfig.Target -Target $gitConfig.Source -ErrorAction Stop > $null

# Powershell config
$pwshConfig = [PSCustomObject]@{
	Source = "$PSScriptRoot/config/powershell/profile.ps1"
	Target = "$PROFILE"
}
Remove-Item -Path $pwshConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $pwshConfig.Target -Target $pwshConfig.Source -ErrorAction Stop > $null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PowerType
Install-Module -Name kmt.winget.autocomplete
Install-Module -Name posh-git
Install-Module -Name posh-docker
Install-Module -Name npm-completion
$powershellCompletionsDir = "$PSScriptRoot/config/powershell/completions"
New-Item -ItemType Directory -Path $powershellCompletionsDir -Force > $null
$powershellProfileInitDir = "$PSScriptRoot/config/powershell/init"
New-Item -ItemType Directory -Path $powershellProfileInitDir -Force > $null

# Oh My Posh config
$themesDir = "$PSScriptRoot/config/powershell/themes"
New-Item -ItemType Directory -Path $themesDir -Force > $null
$themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-context.omp.json"
Invoke-WebRequest -Uri $themeUrl -OutFile "$themesDir/theme.json"


# GitHub CLI config
gh completion --shell powershell > $powershellCompletionsDir/github-cli.ps1

# NodeJs config
fnm completions --shell powershell > $powershellCompletionsDir/fnm.ps1
Write-Output "fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression" > $powershellProfileInitDir/fnm.ps1
fnm install --lts
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
fnm use default
corepack enable
$npmConfig = [PSCustomObject]@{
	Source = "$PSScriptRoot/config/npm/.npmrc"
	Target = "$HOME/.npmrc"
}
Remove-Item -Path $npmConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $npmConfig.Target -Target $npmConfig.Source -ErrorAction Stop > $null