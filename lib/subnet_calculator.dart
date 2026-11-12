class SubnetResult {
  final String network;
  final String broadcast;
  final String firstHost;
  final String lastHost;
  final String mask;
  final int prefix;
  final int usableHosts;

  const SubnetResult({
    required this.network,
    required this.broadcast,
    required this.firstHost,
    required this.lastHost,
    required this.mask,
    required this.prefix,
    required this.usableHosts,
  });
}

class Ipv6SubnetResult {
  final String compressedAddress;
  final String expandedAddress;
  final String networkPrefix;
  final String expandedNetwork;
  final String firstAddress;
  final String lastAddress;
  final int prefix;
  final String totalAddressesLabel;
  final String subnets64Label;

  const Ipv6SubnetResult({
    required this.compressedAddress,
    required this.expandedAddress,
    required this.networkPrefix,
    required this.expandedNetwork,
    required this.firstAddress,
    required this.lastAddress,
    required this.prefix,
    required this.totalAddressesLabel,
    required this.subnets64Label,
  });
}

/// Aceita "192.168.0.0/24", "192.168.0.0 255.255.255.0" ou apenas "192.168.0.0" (assume /24)
SubnetResult calculateSubnetFromInput(String rawInput) {
  final cleaned = rawInput.trim();
  if (cleaned.isEmpty) {
    throw const FormatException(
      'Informe o endereço IPv4/CIDR (ex.: 192.168.0.0/24).',
    );
  }

  String ipPart;
  String maskPart;

  if (cleaned.contains('/')) {
    final idx = cleaned.indexOf('/');
    ipPart = cleaned.substring(0, idx).trim();
    maskPart = cleaned.substring(idx + 1).trim();
    if (ipPart.isEmpty || maskPart.isEmpty) {
      throw const FormatException(
        'Formato inválido. Use IP/CIDR (ex.: 192.168.0.0/24).',
      );
    }
  } else if (cleaned.contains(RegExp(r'\s+'))) {
    final parts = cleaned.split(RegExp(r'\s+'));
    ipPart = parts.first.trim();
    maskPart = parts.sublist(1).join('').trim();
  } else {
    ipPart = cleaned;
    maskPart = '24';
  }

  return calculateSubnet(ipPart, maskPart);
}

/// Aceita "2804:14d:5c80::1/56" ou apenas "2804:14d:5c80::1" (assume /64)
Ipv6SubnetResult calculateIpv6SubnetFromInput(String rawInput) {
  final cleaned = rawInput.trim();
  if (cleaned.isEmpty) {
    throw const FormatException(
      'Informe o endereço IPv6/Prefixo (ex.: 2804:14d:5c80::1/56).',
    );
  }

  String ipPart;
  String prefixPart;

  if (cleaned.contains('/')) {
    final idx = cleaned.indexOf('/');
    ipPart = cleaned.substring(0, idx).trim();
    prefixPart = cleaned.substring(idx + 1).trim();
    if (ipPart.isEmpty || prefixPart.isEmpty) {
      throw const FormatException(
        'Formato inválido. Use IPv6/Prefixo (ex.: 2804:14d:5c80::1/56).',
      );
    }
  } else if (cleaned.contains(RegExp(r'\s+'))) {
    final parts = cleaned.split(RegExp(r'\s+'));
    ipPart = parts.first.trim();
    prefixPart = parts.sublist(1).join('').trim();
  } else {
    ipPart = cleaned;
    prefixPart = '64';
  }

  return calculateIpv6Subnet(ipPart, prefixPart);
}

SubnetResult calculateSubnet(String rawIp, String rawMask) {
  final ipStr = rawIp.trim();
  final maskStr = rawMask.trim();

  // Caso alguém passe "192.168.0.0/24" direto no primeiro parâmetro
  if (ipStr.contains('/') && maskStr.isEmpty) {
    return calculateSubnetFromInput(ipStr);
  }

  final ipInt = _parseIpv4(ipStr);
  final prefix = _parseIpv4Mask(maskStr);

  final maskInt = prefix == 0
      ? 0
      : ((0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF);
  final networkInt = ipInt & maskInt;
  final broadcastInt = (networkInt | (~maskInt & 0xFFFFFFFF)) & 0xFFFFFFFF;

  final int firstHostInt;
  final int lastHostInt;
  final int usableHosts;

  if (prefix == 32) {
    firstHostInt = networkInt;
    lastHostInt = networkInt;
    usableHosts = 1;
  } else if (prefix == 31) {
    firstHostInt = networkInt;
    lastHostInt = broadcastInt;
    usableHosts = 2;
  } else {
    firstHostInt = networkInt + 1;
    lastHostInt = broadcastInt - 1;
    usableHosts = (1 << (32 - prefix)) - 2;
  }

  return SubnetResult(
    network: _intToIpv4(networkInt),
    broadcast: _intToIpv4(broadcastInt),
    firstHost: _intToIpv4(firstHostInt),
    lastHost: _intToIpv4(lastHostInt),
    mask: _intToIpv4(maskInt),
    prefix: prefix,
    usableHosts: usableHosts,
  );
}

int _parseIpv4(String ip) {
  final parts = ip.split('.');
  if (parts.length != 4) {
    throw const FormatException('Endereço IPv4 inválido. Use o formato X.X.X.X');
  }
  int result = 0;
  for (final part in parts) {
    final value = int.tryParse(part.trim());
    if (value == null || value < 0 || value > 255) {
      throw const FormatException('Cada octeto IPv4 deve estar entre 0 e 255.');
    }
    result = (result << 8) | value;
  }
  return result >>> 0;
}

int _parseIpv4Mask(String mask) {
  final clean = mask.startsWith('/') ? mask.substring(1).trim() : mask.trim();

  if (!clean.contains('.')) {
    final prefix = int.tryParse(clean);
    if (prefix == null || prefix < 0 || prefix > 32) {
      throw const FormatException('O prefixo IPv4 deve estar entre /0 e /32.');
    }
    return prefix;
  }

  final maskInt = _parseIpv4(clean);
  int bits = 0;
  bool zeroSeen = false;

  for (int i = 31; i >= 0; i--) {
    final bit = (maskInt >> i) & 1;
    if (bit == 1) {
      if (zeroSeen) {
        throw const FormatException('Máscara de sub-rede descontínua inválida.');
      }
      bits++;
    } else {
      zeroSeen = true;
    }
  }
  return bits;
}

String _intToIpv4(int value) {
  final o1 = (value >> 24) & 0xFF;
  final o2 = (value >> 16) & 0xFF;
  final o3 = (value >> 8) & 0xFF;
  final o4 = value & 0xFF;
  return o1.toString() + '.' + o2.toString() + '.' + o3.toString() + '.' + o4.toString();
}

Ipv6SubnetResult calculateIpv6Subnet(String rawIp, String rawPrefix) {
  final ipStr = rawIp.trim();
  final cleanPrefix = rawPrefix.trim().startsWith('/')
      ? rawPrefix.trim().substring(1).trim()
      : rawPrefix.trim();

  final prefix = int.tryParse(cleanPrefix);
  if (prefix == null || prefix < 0 || prefix > 128) {
    throw const FormatException('O prefixo IPv6 deve estar entre /0 e /128.');
  }

  final ipBig = _parseIpv6(ipStr);
  final max128 = (BigInt.one << 128) - BigInt.one;
  final hostBits = 128 - prefix;

  final maskBig = prefix == 0
      ? BigInt.zero
      : ((max128 >> hostBits) << hostBits) & max128;

  final networkBig = ipBig & maskBig;
  final hostMask = (BigInt.one << hostBits) - BigInt.one;
  final lastAddressBig = networkBig | hostMask;

  final totalAddresses = BigInt.one << hostBits;
  final totalLabel = hostBits > 53
      ? '2^' + hostBits.toString() + ' (' + _formatBigNumber(totalAddresses) + ')'
      : _formatBigNumber(totalAddresses);

  final String subnets64Label;
  if (prefix <= 64) {
    final count64 = BigInt.one << (64 - prefix);
    subnets64Label = _formatBigNumber(count64) + ' redes /64';
  } else {
    subnets64Label = 'Sub-rede menor que /64';
  }

  return Ipv6SubnetResult(
    compressedAddress: _bigIntToIpv6(ipBig, compress: true),
    expandedAddress: _bigIntToIpv6(ipBig, compress: false),
    networkPrefix: _bigIntToIpv6(networkBig, compress: true) + '/' + prefix.toString(),
    expandedNetwork: _bigIntToIpv6(networkBig, compress: false),
    firstAddress: _bigIntToIpv6(networkBig, compress: true),
    lastAddress: _bigIntToIpv6(lastAddressBig, compress: true),
    prefix: prefix,
    totalAddressesLabel: totalLabel,
    subnets64Label: subnets64Label,
  );
}

BigInt _parseIpv6(String input) {
  if (input.isEmpty || input.contains(':::')) {
    throw const FormatException('Endereço IPv6 inválido.');
  }

  final doubleColonCount = '::'.allMatches(input).length;
  if (doubleColonCount > 1) {
    throw const FormatException('Um endereço IPv6 só pode conter um "::".');
  }

  List<String> groups;
  if (input.contains('::')) {
    final sides = input.split('::');
    final left = sides[0].isEmpty ? <String>[] : sides[0].split(':');
    final right = sides[1].isEmpty ? <String>[] : sides[1].split(':');
    final missing = 8 - (left.length + right.length);
    if (missing < 1) {
      throw const FormatException('Quantidade de blocos IPv6 inválida.');
    }
    groups = [...left, ...List.filled(missing, '0'), ...right];
  } else {
    groups = input.split(':');
    if (groups.length != 8) {
      throw const FormatException('O endereço IPv6 deve ter 8 grupos ou usar "::".');
    }
  }

  BigInt result = BigInt.zero;
  for (final group in groups) {
    if (group.isEmpty || group.length > 4) {
      throw const FormatException('Cada bloco IPv6 deve ter de 1 a 4 dígitos hex.');
    }
    final value = int.tryParse(group, radix: 16);
    if (value == null || value < 0 || value > 0xFFFF) {
      throw const FormatException('Caractere hexadecimal inválido no IPv6.');
    }
    result = (result << 16) | BigInt.from(value);
  }
  return result;
}

String _bigIntToIpv6(BigInt value, {required bool compress}) {
  final groups = List<int>.generate(8, (index) {
    final shift = (7 - index) * 16;
    return ((value >> shift) & BigInt.from(0xFFFF)).toInt();
  });

  if (!compress) {
    return groups.map((g) => g.toRadixString(16).padLeft(4, '0')).join(':');
  }

  int bestStart = -1;
  int bestLength = 0;
  int currentStart = -1;
  int currentLength = 0;

  for (int i = 0; i < 8; i++) {
    if (groups[i] == 0) {
      if (currentStart == -1) {
        currentStart = i;
        currentLength = 1;
      } else {
        currentLength++;
      }
      if (currentLength > bestLength && currentLength >= 2) {
        bestStart = currentStart;
        bestLength = currentLength;
      }
    } else {
      currentStart = -1;
      currentLength = 0;
    }
  }

  if (bestStart == -1) {
    return groups.map((g) => g.toRadixString(16)).join(':');
  }

  final left = groups
      .sublist(0, bestStart)
      .map((g) => g.toRadixString(16))
      .join(':');
  final right = groups
      .sublist(bestStart + bestLength)
      .map((g) => g.toRadixString(16))
      .join(':');

  return left + '::' + right;
}

String _formatBigNumber(BigInt number) {
  final str = number.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return buffer.toString();
}
