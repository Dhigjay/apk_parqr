class StopwatchManager {
  /// Calculates the duration between the start time and now.
  static Duration calculateDuration(DateTime startTime, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return currentTime.difference(startTime);
  }

  /// Calculates the tariff based on the duration.
  /// Example: Tariff applies per hour or fraction thereof.
  static double calculateTariff(Duration duration, double tariffPerHour) {
    // Handle edge cases
    if (duration.isNegative || duration.inSeconds == 0) return 0.0;

    // Rounded up per jam, minimum 1 jam
    int hours = (duration.inMinutes / 60).ceil();
    if (hours == 0) hours = 1;

    return hours * tariffPerHour;
  }

  /// Formats the duration into a HH:MM:SS string.
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
