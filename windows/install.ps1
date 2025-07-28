Set-StrictMode -Version Latest

sudo config --enable normal

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

sudo winget import ./programs/installation/winget.json

$bin_dir = "$PSScriptRoot/bin"

pwsh $PSScriptRoot/programs/installation/unlisted.ps1 --install_dir $bin_dir