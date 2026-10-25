import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora_subrede/subnet_calculator.dart';

void main() {
  group('calculateSubnet - rede e broadcast (RF02)', () {
    test('192.168.10.37/26', () {
      final r = calculateSubnet('192.168.10.37', '/26');
      expect(r.prefix, 26);
      expect(r.mask, '255.255.255.192');
      expect(r.network, '192.168.10.0');
      expect(r.broadcast, '192.168.10.63');
    });
    test('10.1.2.3/8', () {
      final r = calculateSubnet('10.1.2.3', '/8');
      expect(r.network, '10.0.0.0');
      expect(r.broadcast, '10.255.255.255');
    });
    test('máscara decimal pontuada', () {
      final r = calculateSubnet('172.16.5.130', '255.255.255.128');
      expect(r.network, '172.16.5.128');
      expect(r.broadcast, '172.16.5.255');
    });
    test('IP inválido lança FormatException', () {
      expect(() => calculateSubnet('300.1.1.1', '/24'),
          throwsA(isA<FormatException>()));
    });
    test('máscara inválida lança FormatException', () {
      expect(() => calculateSubnet('10.0.0.1', '255.0.255.0'),
          throwsA(isA<FormatException>()));
    });
  });

  group('calculateSubnet - hosts (RF03)', () {
    test('/26 tem 62 hosts utilizáveis', () {
      final r = calculateSubnet('192.168.10.37', '/26');
      expect(r.firstHost, '192.168.10.1');
      expect(r.lastHost, '192.168.10.62');
      expect(r.usableHosts, 62);
    });
    test('/24 tem 254 hosts', () {
      expect(calculateSubnet('192.168.10.77', '/24').usableHosts, 254);
    });
    test('/30 tem 2 hosts', () {
      final r = calculateSubnet('192.168.10.5', '/30');
      expect(r.network, '192.168.10.4');
      expect(r.broadcast, '192.168.10.7');
      expect(r.firstHost, '192.168.10.5');
      expect(r.lastHost, '192.168.10.6');
      expect(r.usableHosts, 2);
    });
    test('/31 (ponto a ponto) tem 2 hosts', () {
      final r = calculateSubnet('192.168.10.4', '/31');
      expect(r.firstHost, '192.168.10.4');
      expect(r.lastHost, '192.168.10.5');
      expect(r.usableHosts, 2);
    });
    test('/32 tem 1 host', () {
      final r = calculateSubnet('192.168.10.9', '/32');
      expect(r.firstHost, '192.168.10.9');
      expect(r.lastHost, '192.168.10.9');
      expect(r.usableHosts, 1);
    });
  });
}
