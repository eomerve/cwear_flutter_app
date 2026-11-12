import 'dart:math' as math;

/// Synthetic adult resting pattern. Not a measured or diagnostic value.
abstract final class RespirationDemo {
  static const int rateBpm = 16;
  static const int typicalAdultRestMin = 12;
  static const int typicalAdultRestMax = 20;
  static const int windowSeconds = 15;

  static double strainAt(double seconds, {double phase = 0}) {
    final radians = seconds * (rateBpm / 60) * 2 * math.pi + phase;
    final main = math.sin(radians - math.pi / 2);
    return (0.95 + 0.63 * main + 0.025 * math.sin(radians * 2)).clamp(0.0, 2.0).toDouble();
  }

  static const weeklyRates = <double?>[16, 17, 15, 16, 16, null, null];
  static const monthlyRates = <double?>[16, 16, 17, 15, 16, 16, 15];
}
