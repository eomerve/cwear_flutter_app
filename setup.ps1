# Install Flutter first (3.35+). From the project directory run:
# PowerShell: Set-ExecutionPolicy -Scope Process Bypass; .\setup.ps1
$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter is not in PATH. Install Flutter 3.35+ and restart PowerShell.'
}
flutter create --project-name c_wear --org com.ertuncozcan --platforms=android .
if ($LASTEXITCODE -ne 0) { throw 'flutter create failed' }
dart tool/configure_platforms.dart
if ($LASTEXITCODE -ne 0) { throw 'platform configuration failed' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
Write-Host "Project ready. Connect an Android device and run: flutter run" -ForegroundColor Green
Write-Host "For iOS, copy this same project to a Mac and run ./setup.sh (Xcode required)." -ForegroundColor Cyan
