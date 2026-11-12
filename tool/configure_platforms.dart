// Run AFTER `flutter create --platforms=android,ios .`.
// Pure Dart (part of Flutter SDK); no Python/third-party dependency needed.
import 'dart:io';

void main() {
  final androidManifest = File('android/app/src/main/AndroidManifest.xml');
  if (androidManifest.existsSync()) {
    var content = androidManifest.readAsStringSync();
    if (!content.contains('android.permission.CAMERA')) {
      content = content.replaceFirstMapped(
        RegExp(r'<manifest\b[^>]*>'),
        (match) => '${match.group(0)}\n'
            '    <uses-permission android:name="android.permission.CAMERA" />\n'
            '    <uses-feature android:name="android.hardware.camera" android:required="false" />',
      );
      androidManifest.writeAsStringSync(content);
    }
    stdout.writeln('Configured Android camera permission.');
  } else {
    stderr.writeln('Android runner not found. Run flutter create first.');
  }

  for (final path in [
    'android/app/build.gradle.kts',
    'android/app/build.gradle',
  ]) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var gradle = file.readAsStringSync();
    gradle = gradle.replaceAll(
        RegExp(r'minSdk\s*=\s*flutter\.minSdkVersion'), 'minSdk = 24');
    gradle = gradle.replaceAll(
        RegExp(r'minSdkVersion\s+flutter\.minSdkVersion'), 'minSdkVersion 24');
    file.writeAsStringSync(gradle);
    stdout.writeln('Configured Android minSdk 24: $path');
  }

  final iosPlist = File('ios/Runner/Info.plist');
  if (iosPlist.existsSync()) {
    var content = iosPlist.readAsStringSync();
    for (final permission in {
      'NSCameraUsageDescription':
          'C-Wear scans a QR code to start a simulated respiratory monitoring session.',
      'NSPhotoLibraryUsageDescription':
          'C-Wear lets you choose a profile photo stored on this device.',
    }.entries) {
      if (!content.contains('<key>${permission.key}</key>')) {
        final endOfRootDictionary = content.lastIndexOf('</dict>');
        if (endOfRootDictionary != -1) {
          content = content.replaceRange(endOfRootDictionary,
              endOfRootDictionary, '    <key>${permission.key}</key>\n'
              '    <string>${permission.value}</string>\n');
        }
      }
    }
    iosPlist.writeAsStringSync(content);
    stdout.writeln('Configured iOS camera and photo library usage descriptions.');
  } else {
    stdout.writeln('iOS runner not available on this host; create it on macOS if needed.');
  }

  final podfile = File('ios/Podfile');
  if (podfile.existsSync()) {
    var content = podfile.readAsStringSync();
    final platformLine = RegExp(r"^\s*#?\s*platform\s+:ios,\s*'[^']+'",
        multiLine: true);
    if (platformLine.hasMatch(content)) {
      content = content.replaceFirst(platformLine, "platform :ios, '15.0'");
    } else {
      content = "platform :ios, '15.0'\n$content";
    }
    podfile.writeAsStringSync(content);
  }

  final iosProject = File('ios/Runner.xcodeproj/project.pbxproj');
  if (iosProject.existsSync()) {
    var content = iosProject.readAsStringSync();
    content = content.replaceAll(
      RegExp(r'IPHONEOS_DEPLOYMENT_TARGET\s*=\s*[0-9.]+;'),
      'IPHONEOS_DEPLOYMENT_TARGET = 15.0;',
    );
    iosProject.writeAsStringSync(content);
  }
  // Flutter's default counter-app test refers to MyApp, which this project
  // deliberately does not define. Remove ONLY that generated example test.
  final generatedCounterTest = File('test/widget_test.dart');
  if (generatedCounterTest.existsSync()) {
    final content = generatedCounterTest.readAsStringSync();
    if (content.contains('Counter increments smoke test') ||
        content.contains('MyApp()')) {
      generatedCounterTest.deleteSync();
      stdout.writeln('Removed unrelated generated counter-app test.');
    }
  }
  stdout.writeln('C-Wear platform configuration completed.');
}
