import 'package:flutter/material.dart';

import 'subnet_calculator.dart';

void main() => runApp(const CalculadoraApp());

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Sub-rede',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  final _ip = TextEditingController();
  final _mask = TextEditingController();
  SubnetResult? _result;
  String? _error;

  void _calcular() {
    try {
      final r = calculateSubnet(_ip.text, _mask.text);
      setState(() {
        _result = r;
        _error = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _result = null;
        _error = e.message;
      });
    }
  }

  @override
  void dispose() {
    _ip.dispose();
    _mask.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Sub-rede')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('ip'),
            controller: _ip,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Endereço IPv4',
              hintText: '192.168.10.37',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('mask'),
            controller: _mask,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Máscara (/26 ou 255.255.255.192)',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('calcular'),
            onPressed: _calcular,
            child: const Text('Calcular'),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          if (r != null) ...[
            Text('Máscara: ${r.mask} (/${r.prefix})'),
            Text('Endereço de rede: ${r.network}'),
            Text('Broadcast: ${r.broadcast}'),
            Text('Primeiro host: ${r.firstHost}'),
            Text('Último host: ${r.lastHost}'),
            Text('Hosts utilizáveis: ${r.usableHosts}'),
          ],
        ],
      ),
    );
  }
}
