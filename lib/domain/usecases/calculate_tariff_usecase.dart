class CalculateTariffUseCase {
  /// Calculate tariff based on check-in time and hourly rate.
  /// Minimum charge is 1 hour.
  double execute({
    required DateTime checkInTime,
    required double hourlyRate,
    DateTime? checkOutTime,
  }) {
    final endTime = checkOutTime ?? DateTime.now();
    final duration = endTime.difference(checkInTime);
    
    // Calculate hours (ceiling to next hour, e.g., 1 hour 1 minute = 2 hours)
    // Minimum 1 hour
    int hours = duration.inMinutes ~/ 60;
    if (duration.inMinutes % 60 > 0 || hours == 0) {
      hours += 1;
    }

    return hours * hourlyRate;
  }
}
