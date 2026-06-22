import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/core/utils/stopwatch_manager.dart';

void main() {
  group('StopwatchManager', () {
    test('calculateDuration returns correct duration', () {
      final startTime = DateTime(2026, 1, 1, 10, 0, 0);
      final now = DateTime(2026, 1, 1, 11, 30, 0);
      
      final duration = StopwatchManager.calculateDuration(startTime, now: now);
      
      expect(duration.inMinutes, 90);
    });

    test('calculateTariff returns correct tariff based on duration', () {
      const tariffPerHour = 5000.0;
      
      // 0 minutes = 0
      expect(StopwatchManager.calculateTariff(const Duration(minutes: 0), tariffPerHour), 0.0);
      
      // 30 minutes = 1 hour charge
      expect(StopwatchManager.calculateTariff(const Duration(minutes: 30), tariffPerHour), 5000.0);
      
      // 60 minutes = 1 hour charge
      expect(StopwatchManager.calculateTariff(const Duration(minutes: 60), tariffPerHour), 5000.0);
      
      // 61 minutes = 2 hours charge
      expect(StopwatchManager.calculateTariff(const Duration(minutes: 61), tariffPerHour), 10000.0);
    });

    test('formatDuration returns HH:MM:SS format', () {
      const duration = Duration(hours: 1, minutes: 5, seconds: 9);
      expect(StopwatchManager.formatDuration(duration), "01:05:09");
      
      const duration2 = Duration(hours: 12, minutes: 30, seconds: 0);
      expect(StopwatchManager.formatDuration(duration2), "12:30:00");
    });
  });
}
