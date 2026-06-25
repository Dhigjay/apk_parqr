class Validators {
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    final regex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!regex.hasMatch(value)) {
      return 'Format nomor HP tidak valid';
    }
    return null;
  }

  static String? licensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor polisi wajib diisi';
    }
    // Simple regex for Indonesian license plate (e.g. B 1234 ABC)
    final regex = RegExp(r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$');
    if (!regex.hasMatch(value.toUpperCase())) {
      return 'Format nomor polisi tidak valid (contoh: B 1234 ABC)';
    }
    return null;
  }
}
