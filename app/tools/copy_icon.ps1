# Copy app icon source into expected assets root
$src = Join-Path $PSScriptRoot "..\assets\images\blue_sailing_logo_fondo.png"
$dstDir = Join-Path $PSScriptRoot "..\assets"
$dst = Join-Path $dstDir "blue_sailing_logo_fondo.png"

if (-Not (Test-Path $src)) {
  Write-Error "Source icon not found: $src"
  exit 1
}

if (-Not (Test-Path $dstDir)) {
  New-Item -ItemType Directory -Path $dstDir | Out-Null
}

Copy-Item -Force $src $dst
Write-Host "Copied $src to $dst"
