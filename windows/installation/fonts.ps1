[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'

function Get-FontGlyphTypefaceName {
	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string]$FontFilePath
	)

	try {
		Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase
	}
	catch {
		Write-Error "No se pudieron cargar los ensamblados de WPF. Esta función los requiere para ejecutarse. $($_.Exception.Message)"
		return
	}

	if (-not (Test-Path $FontFilePath -PathType Leaf)) {
		Write-Warning "Archivo de fuente no encontrado: $FontFilePath"
		return
	}

	$absoluteFontUri = New-Object System.Uri -ArgumentList (Resolve-Path $FontFilePath).Path

	try {
		$glyphTypeface = New-Object Windows.Media.GlyphTypeface -ArgumentList $absoluteFontUri
	}
	catch {
		Write-Error "No se pudo leer el nombre interno del archivo de fuente '$FontFilePath' (GlyphTypeface): $($_.Exception.Message)"
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

	$fontTypeIndicator = switch ([System.IO.Path]::GetExtension($FontFilePath).ToLower()) {
		".ttf" { "(TrueType)" }
		".otf" { "(OpenType)" }
		default { "" }
	}

	$fontRegistryName = $fontFamilyName
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


$fontsDir = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Windows\Fonts"
$fontsRegistry = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

$tmpDir = Join-Path -Path $env:TEMP -ChildPath ([System.Guid]::NewGuid().ToString())


Write-Host "Creando directorio temporal en: $tmpDir"
New-Item -Path $tmpDir -ItemType Directory -Force > $null

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip"
$fontZip = Join-Path -Path $tmpDir -ChildPath "cascadia-code.tmp.zip"
$unzipDir = Join-Path -Path $tmpDir -ChildPath "cascadia-code"

Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip

Expand-Archive -LiteralPath $fontZip -DestinationPath $unzipDir -Force

if (-not (Test-Path -Path $fontsDir)) {
	New-Item -Path $fontsDir -ItemType Directory -Force > $null
}

$selectedFontName = "CaskaydiaCoveNerdFontMono-Regular.ttf"
$tmpFontPath = Join-Path -Path $unzipDir -ChildPath $selectedFontName
$finalFontPath = Join-Path -Path $fontsDir -ChildPath $selectedFontName

Copy-Item -Path $tmpFontPath -Destination $finalFontPath -Force

$font = Get-FontGlyphTypefaceName -FontFilePath $finalFontPath
if (-not $font) {
	throw "No se pudo obtener la información de la fuente. La instalación ha fallado."
}

Write-Host "Registrando fuente '$($font.FontRegistryName)'..."
New-ItemProperty -Path $fontsRegistry -Name $font.FontRegistryName -PropertyType String -Value $finalFontPath -Force

Write-Host "✅ ¡Fuente '$($font.FontRegistryName)' instalada correctamente!" -ForegroundColor Green

$HWND_BROADCAST = 0xffff
$WM_FONTCHANGE = 0x001D
$user32 = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name 'user32' -PassThru
$user32::SendMessage($HWND_BROADCAST, $WM_FONTCHANGE, 0, 0)

Remove-Item -Path $tmpDir -Force -Recurse