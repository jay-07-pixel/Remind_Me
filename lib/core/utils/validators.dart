abstract final class Validators {
  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Full name is required';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s'.-]+$").hasMatch(trimmed)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? mobileNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]').hasMatch(trimmed)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email address is required';
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
