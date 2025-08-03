Import-Module -Name Microsoft.WinGet.Configuration
Import-Module -Name WinGet-Essentials
Import-Module -Name posh-git
Import-Module -Name DockerCompletion
Import-Module -Name pnpm-tab-completion

Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView

# Oh My Posh
oh-my-posh init pwsh --config "$env:DotFiles/config/powershell/themes/default.omp.json" | Invoke-Expression