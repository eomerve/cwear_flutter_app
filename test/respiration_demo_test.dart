import 'package:flutter_test/flutter_test.dart';
import 'package:c_wear/utils/respiration_demo.dart';

void main() {
  test('simulated resting respiration rate is 12–20 BPM', () {
    expect(RespirationDemo.rateBpm, inInclusiveRange(
      RespirationDemo.typicalAdultRestMin,
      RespirationDemo.typicalAdultRestMax,
    ));
  });

  test('synthetic strain values stay within chart range', () {
    for (var n = 0; n <= 300; n++) {
      final value = RespirationDemo.strainAt(n / 20);
      expect(value, inInclusiveRange(0.0, 2.0));
    }
  });

  test('fifteen-second window covers exactly four breathing cycles at 16 BPM', () {
    final breaths = RespirationDemo.windowSeconds * RespirationDemo.rateBpm / 60;
    expect(breaths, 4);
  });
}
