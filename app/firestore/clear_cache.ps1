<# Clear Firebase / build caches for this project (Windows PowerShell)
Run from PowerShell in the `app\firestore` folder: `./clear_cache.ps1` #>

Write-Host "Removing local node_modules and npm cache..."
Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
npm cache clean --force

Write-Host "Removing app build output (Flutter) and pub cache references..."
Remove-Item -Recurse -Force "..\build\*" -ErrorAction SilentlyContinue

Write-Host "Removing firebase generated file references (if present)..."
Remove-Item -Force "..\lib\firebase_options.dart" -ErrorAction SilentlyContinue

Write-Host "Done. You may now run 'flutter pub get' and 'flutter clean' from the app root."
