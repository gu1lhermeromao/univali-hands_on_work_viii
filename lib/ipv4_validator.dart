bool isValidIpv4(String input) {
  final parts = input.trim().split('.');
  if (parts.length != 4) return false;
  for (final p in parts) {
    if (!RegExp(r'^\d{1,3}$').hasMatch(p)) return false;
    if (int.parse(p) > 255) return false;
  }
  return true;
}