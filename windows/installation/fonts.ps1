[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Get-FontGlyphTypefaceName {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]$font_file_path
	)

	try {
		Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase
	}
	catch {
		Write-Error "Failed to load WPF assemblies. This function requires WPF components to run. $($_.Exception.Message)"
		return
	}

	if (-not (Test-Path $font_file_path -PathType Leaf)) {
		Write-Warning "Font file not found: $font_file_path"
		return
	}

	$absolute_font_uri = New-Object System.Uri -ArgumentList (Resolve-Path $font_file_path).Path

	try {
		$glyphTypeface = New-Object Windows.Media.GlyphTypeface -ArgumentList $absolute_font_uri
	}
	catch {
		Write-Error "Can not read internal name of font file '$font_file_path' (GlyphTypeface): $($_.Exception.Message)"
		return
	}

	$fontFamilyName = $glyphTypeface.Win32FamilyNames['en-us']
	if (-not $fontFamilyName) {
		$fontFamilyName = ($glyphTypeface.Win32FamilyNames.Values | Select-Object -First 1)
		if (-not $fontFamilyName) {
			$fontFamilyName = "Unknown Family"
		}
	}

	$fontFaceName = $glyphTypeface.Win32FaceNames['en-us']
	if (-not $fontFaceName) {
		$fontFaceName = ($glyphTypeface.Win32FaceNames.Values | Select-Object -First 1)
		if (-not $fontFaceName) {
			$fontFaceName = "Regular"
		}
	}

	$fontTypeIndicator = switch ([System.IO.Path]::GetExtension($font_file_path).ToLower()) {
		".ttf" { "(TrueType)" }
		".otf" { "(OpenType)" }
		default { "" }
	}

	$fontRegistryName = "$fontFamilyName"
	if ($fontFaceName -ne "Regular" -and $fontFaceName -ne $fontFamilyName) {
		$fontRegistryName += " $fontFaceName"
	}
	$fontRegistryName += " $fontTypeIndicator"
	$fontRegistryName = $fontRegistryName.Trim()

	[PSCustomObject]@{
		FamilyName       = $fontFamilyName
		FaceName         = $fontFaceName
		FontRegistryName = $fontRegistryName
	}
}

$fontsDir = "$env:LOCALAPPDATA/Microsoft/Windows/Fonts"
$fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

$tmpDir = "./tmp"
New-Item $tmpDir -ItemType Directory -Force > $null

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip"
$fontZip = "$tmpDir/cascadia-code.tmp.zip"

Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
Expand-Archive -LiteralPath $fontZip -DestinationPath "$tmpDir/cascadia-code" -Force

$selectedFontName = "CaskaydiaCoveNerdFontMono-Regular.ttf"
$tmpFontPath = "$tmpDir/cascadia-code/$selectedFontName"
$fontPath = "$fontsDir/$selectedFontName"
Copy-Item -Path $tmpFontPath -Destination $fontsDir -Force
$fontPath = Resolve-Path $fontPath

$font = Get-FontGlyphTypefaceName -font_file_path $fontPath

Add-ItemProperty -Path $fontsRegistry -Name $font.FontRegistryName -PropertyType string -Value $fontPath

Write-Host "✅ Installed $($font.FontRegistryName) font"

Remove-Item $tmpDir -Force -Recurse
