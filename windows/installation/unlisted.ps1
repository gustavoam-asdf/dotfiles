[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[string]$install_dir
)

if (-not (Test-Path $install_dir)) {
	New-Item $install_dir -ItemType Directory -Force > $null
}

Write-Host "Installing in $install_dir"

$tmp_dir = "./tmp"
New-Item $tmp_dir -ItemType Directory -Force > $null


$yt_dlp_url = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
Invoke-WebRequest -Uri $yt_dlp_url -OutFile "$install_dir/yt-dlp.exe"
Write-Host "✅ Installed yt-dlp"

$platform_tools_url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" 
$platform_tools_zip = "$tmp_dir/platform-tools.tmp.zip"
Invoke-WebRequest -Uri $platform_tools_url -OutFile $platform_tools_zip
Expand-Archive -LiteralPath $platform_tools_zip -DestinationPath "$tmp_dir"
Move-Item -Path "$tmp_dir/platform-tools/*" -Destination $install_dir -Force
Remove-Item $platform_tools_zip
Write-Host "✅ Installed platform tools"


Remove-Item $tmp_dir -Force -Recurse