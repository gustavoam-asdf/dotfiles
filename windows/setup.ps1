Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

sudo config --enable normal

if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

$dotFilesDir = Resolve-Path $PSScriptRoot

$binDir = "$dotFilesDir/bin"
New-Item $binDir -ItemType Directory -Force > $null
$binDir = Resolve-Path -Path $binDir

# Config environment variables
[System.Environment]::SetEnvironmentVariable("DotFiles", $dotfilesDir, "User")
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($userPath -like "*$binDir*")) {
	[System.Environment]::SetEnvironmentVariable("Path", $userPath + "$binDir;", "User")
	$env:Path += "$binDir;"
}

sudo pwsh $dotFilesDir/installation/fonts.ps1

sudo winget import $dotFilesDir/installation/winget.json
pwsh $dotFilesDir/installation/unlisted.ps1 --install_dir $binDir

# Read fresh environment variables after installation
$env:Path = [System.Environment]::GetEnvironmentVariable("Path")

# Windows Terminal config
$windowsTerminalConfig = [PSCustomObject]@{
	Source = "$dotFilesDir/config/windows-terminal/settings.json"
	Target = "$env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
}
Remove-Item -Path $windowsTerminalConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $windowsTerminalConfig.Target -Target $windowsTerminalConfig.Source > $null


# Git config
$gitConfig = [PSCustomObject]@{
	Source = "$dotFilesDir/config/git/.gitconfig"
	Target = "$HOME/.gitconfig"
}
Remove-Item -Path $gitConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $gitConfig.Target -Target $gitConfig.Source > $null

# Powershell config
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
if($null -eq (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction Ignore)) {
	Install-PackageProvider -Name nuget -MinimumVersion 2.8.5.201 -Force
}
Install-Module -Name Microsoft.WinGet.Configuration
Install-Module -Name WinGet-Essentials
Install-Module -Name DockerCompletion
# https://github.com/abgox/PSCompletions
Install-Module -Name PSCompletions
sudo pwsh $dotFilesDir/installation/pwsh-completions.ps1
$powershellCompletionsDir = "$dotFilesDir/config/powershell/completions"
New-Item -ItemType Directory -Path $powershellCompletionsDir -Force > $null
$powershellProfileInitDir = "$dotFilesDir/config/powershell/init"
New-Item -ItemType Directory -Path $powershellProfileInitDir -Force > $null
$pwshConfig = [PSCustomObject]@{
	Source = "$dotFilesDir/config/powershell/profile.ps1"
	Target = "$PROFILE"
}
Remove-Item -Path $pwshConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $pwshConfig.Target -Target $pwshConfig.Source > $null

# Oh My Posh config
$themesDir = "$dotFilesDir/config/powershell/themes"
New-Item -ItemType Directory -Path $themesDir -Force > $null
$themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-context.omp.json"
Invoke-WebRequest -Uri $themeUrl -OutFile "$themesDir/default.omp.json"


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
	Source = "$dotFilesDir/config/npm/.npmrc"
	Target = "$HOME/.npmrc"
}
Remove-Item -Path $npmConfig.Target -Force -ErrorAction Ignore
New-Item -ItemType SymbolicLink -Path $npmConfig.Target -Target $npmConfig.Source > $null

# Bun config
pwsh -c "irm bun.sh/install.ps1 | iex"