Import-Module -Name PowerType
Import-Module -Name kmt.winget.autocomplete
Import-Module -Name posh-git
Import-Module -Name posh-docker
Import-Module -Name npm-completion

# PowerType
Enable-PowerType
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView

# Oh My Posh
oh-my-posh init pwsh --config "$powershellrc\themes\negligible.omp.json" | Invoke-Expression