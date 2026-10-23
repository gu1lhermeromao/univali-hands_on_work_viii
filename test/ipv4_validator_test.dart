import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora_subrede/ipv4_validator.dart';

void main() {
  group('isValidIpv4', () {
    test('aceita endereço válido', () {
      expect(isValidIpv4('10.0.0.1'), isTrue);
    });
    test('rejeita octeto acima de 255', () {
      expect(isValidIpv4('300.1.1.1'), isFalse);
    });
    test('rejeita endereço com menos de 4 octetos', () {
      expect(isValidIpv4('192.168.1'), isFalse);
    });
  });
}