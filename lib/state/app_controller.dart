import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-side preferences only. NO clinical data, cloud, network, or BLE.
class AppController extends ChangeNotifier {
  AppController({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;
  String fullName = 'Mira Chen';
  int age = 32;
  String? avatarPath;
  bool connected = false;

  Future<void> initialize() async {
    fullName = await _preferences.getString('profile.name') ?? 'Mira Chen';
    age = await _preferences.getInt('profile.age') ?? 32;
    avatarPath = await _preferences.getString('profile.avatar');
    connected = await _preferences.getBool('sensor.demoConnected') ?? false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required int newAge,
    String? newAvatarPath,
  }) async {
    fullName = name.trim();
    age = newAge;
    if (newAvatarPath != null) avatarPath = newAvatarPath;
    await Future.wait([
      _preferences.setString('profile.name', fullName),
      _preferences.setInt('profile.age', age),
      if (newAvatarPath != null)
        _preferences.setString('profile.avatar', newAvatarPath),
    ]);
    notifyListeners();
  }

  /// Any nonempty QR is accepted intentionally: connection is simulated.
  Future<void> connectDemo(String qrPayload) async {
    final normalized = qrPayload.trim();
    if (normalized.isEmpty) return;
    connected = true;
    await _preferences.setBool('sensor.demoConnected', true);
    notifyListeners();
  }

  Future<void> disconnectDemo() async {
    connected = false;
    await _preferences.setBool('sensor.demoConnected', false);
    notifyListeners();
  }
}
