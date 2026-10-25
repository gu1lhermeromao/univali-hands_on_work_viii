import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora_subrede/subnet_mask.dart';

void main() {
  group('parsePrefix - notação CIDR', () {
    test('aceita /26', () => expect(parsePrefix('/26'), 26));
    test('aceita 26 sem barra', () => expect(parsePrefix('26'), 26));
    test('aceita os limites /0 e /32', () {
      expect(parsePrefix('/0'), 0);
      expect(parsePrefix('/32'), 32);
    });
    test('rejeita /33', () => expect(parsePrefix('/33'), isNull));
    test('rejeita texto e vazio', () {
      expect(parsePrefix('abc'), isNull);
      expect(parsePrefix(''), isNull);
    });
  });

  group('parsePrefix - decimal pontuada', () {
    test('converte máscaras comuns', () {
      expect(parsePrefix('255.255.255.192'), 26);
      expect(parsePrefix('255.255.255.0'), 24);
      expect(parsePrefix('255.0.0.0'), 8);
      expect(parsePrefix('255.255.255.255'), 32);
      expect(parsePrefix('0.0.0.0'), 0);
    });
    test('rejeita máscara não contígua', () {
      expect(parsePrefix('255.0.255.0'), isNull);
    });
    test('rejeita máscara malformada', () {
      expect(parsePrefix('255.255.255.256'), isNull);
      expect(parsePrefix('255.255.255'), isNull);
    });
  });
}
