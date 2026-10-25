import 'ipv4_validator.dart';

/// Converte uma máscara (/26, 26 ou 255.255.255.192) em tamanho de prefixo.
/// Retorna null se a máscara for inválida.
int? parsePrefix(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;

  if (text.contains('.')) {
    if (!isValidIpv4(text)) return null;
    final bits = text
        .split('.')
        .fold<int>(0, (acc, p) => (acc << 8) | int.parse(p));
    final inverted = (~bits) & 0xFFFFFFFF;
    // máscara válida = uns seguidos de zeros (o inverso é 2^k - 1)
    if ((inverted & (inverted + 1)) != 0) return null;
    return bits.toRadixString(2).replaceAll('0', '').length;
  }

  final digits = text.startsWith('/') ? text.substring(1) : text;
  if (!RegExp(r'^\d{1,2}$').hasMatch(digits)) return null;
  final n = int.parse(digits);
  return n <= 32 ? n : null;
}
