import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora_subrede/main.dart';

void main() {
  testWidgets('calcula e exibe rede, broadcast e hosts', (tester) async {
    await tester.pumpWidget(const CalculadoraApp());

    await tester.enterText(find.byKey(const Key('ip')), '192.168.10.37');
    await tester.enterText(find.byKey(const Key('mask')), '/26');
    await tester.tap(find.byKey(const Key('calcular')));
    await tester.pump();

    expect(find.text('Endereço de rede: 192.168.10.0'), findsOneWidget);
    expect(find.text('Broadcast: 192.168.10.63'), findsOneWidget);
    expect(find.text('Hosts utilizáveis: 62'), findsOneWidget);
  });

  testWidgets('mostra mensagem de erro para IP inválido', (tester) async {
    await tester.pumpWidget(const CalculadoraApp());

    await tester.enterText(find.byKey(const Key('ip')), '300.1.1.1');
    await tester.enterText(find.byKey(const Key('mask')), '/24');
    await tester.tap(find.byKey(const Key('calcular')));
    await tester.pump();

    expect(find.text('Endereço IPv4 inválido.'), findsOneWidget);
  });
}
