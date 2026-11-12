#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null 2>&1 || { echo 'Install Flutter 3.35+ and add it to PATH.' >&2; exit 1; }
flutter create --project-name c_wear --org com.ertuncozcan --platforms=android,ios .
dart tool/configure_platforms.dart
flutter pub get
printf '\nReady. Run flutter devices, then flutter run.\n'
