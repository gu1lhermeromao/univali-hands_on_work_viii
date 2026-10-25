import 'ipv4_validator.dart';
import 'subnet_mask.dart';

/// Resultado do cálculo de uma sub-rede IPv4.
class SubnetResult {
  const SubnetResult({
    required this.prefix,
    required this.mask,
    required this.network,
    required this.broadcast,
    required this.firstHost,
    required this.lastHost,
    required this.usableHosts,
  });

  final int prefix;
  final String mask;
  final String network;
  final String broadcast;
  final String firstHost;
  final String lastHost;
  final int usableHosts;
}

int _toInt(String ip) =>
    ip.split('.').fold<int>(0, (acc, p) => (acc << 8) | int.parse(p));

String _toIp(int v) =>
    [24, 16, 8, 0].map((s) => (v >> s) & 0xFF).join('.');

/// Calcula rede, broadcast e faixa de hosts a partir de IP e máscara.
/// Lança [FormatException] se o IP ou a máscara forem inválidos.
SubnetResult calculateSubnet(String ip, String mask) {
  if (!isValidIpv4(ip)) {
    throw const FormatException('Endereço IPv4 inválido.');
  }
  final prefix = parsePrefix(mask);
  if (prefix == null) {
    throw const FormatException('Máscara inválida.');
  }

  final maskInt = (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
  final network = _toInt(ip.trim()) & maskInt;
  final broadcast = network | (~maskInt & 0xFFFFFFFF);

  final int first;
  final int last;
  final int usable;
  if (prefix == 32) {
    first = network;
    last = network;
    usable = 1;
  } else if (prefix == 31) {
    first = network;
    last = broadcast;
    usable = 2;
  } else {
    first = network + 1;
    last = broadcast - 1;
    usable = (1 << (32 - prefix)) - 2;
  }

  return SubnetResult(
    prefix: prefix,
    mask: _toIp(maskInt),
    network: _toIp(network),
    broadcast: _toIp(broadcast),
    firstHost: _toIp(first),
    lastHost: _toIp(last),
    usableHosts: usable,
  );
}
