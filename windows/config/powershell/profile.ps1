Import-Module -Name Microsoft.WinGet.Configuration
Import-Module -Name WinGet-Essentials
Import-Module -Name DockerCompletion
Import-Module -Name PSCompletions

Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView

# Oh My Posh
oh-my-posh init pwsh --config "$env:DotFiles/config/powershell/themes/default.omp.json" | Invoke-Expression