import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'subnet_calculator.dart';

void main() => runApp(const CalculadoraApp());

enum IpVersion { ipv4, ipv6 }

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E40AF),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora IPv4 & IPv6',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
        ),
      ),
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

  IpVersion _version = IpVersion.ipv4;
  SubnetResult? _ipv4Result;
  Ipv6SubnetResult? _ipv6Result;
  String? _error;

  static const _ipv4Presets = ['/24', '/26', '/28', '/29', '/30'];
  static const _ipv6Presets = ['/48', '/56', '/64', '/126', '/128'];

  void _trocarVersao(IpVersion novaVersao) {
    if (_version == novaVersao) return;
    setState(() {
      _version = novaVersao;
      _ip.clear();
      _mask.clear();
      _ipv4Result = null;
      _ipv6Result = null;
      _error = null;
    });
  }

  void _preencherExemplo() {
    setState(() {
      if (_version == IpVersion.ipv4) {
        _ip.text = '192.168.10.37';
        _mask.text = '/26';
      } else {
        _ip.text = '2804:14d:5c80::1';
        _mask.text = '/56';
      }
    });
    _calcular();
  }

  void _calcular() {
    FocusScope.of(context).unfocus();

    if (_ip.text.trim().isEmpty || _mask.text.trim().isEmpty) {
      setState(() {
        _ipv4Result = null;
        _ipv6Result = null;
        _error = _version == IpVersion.ipv4
            ? 'Preencha o endereço IPv4 e a máscara.'
            : 'Preencha o endereço IPv6 e o prefixo.';
      });
      return;
    }

    try {
      if (_version == IpVersion.ipv4) {
        final result = calculateSubnet(_ip.text, _mask.text);
        setState(() {
          _ipv4Result = result;
          _ipv6Result = null;
          _error = null;
        });
      } else {
        final result = calculateIpv6Subnet(_ip.text, _mask.text);
        setState(() {
          _ipv6Result = result;
          _ipv4Result = null;
          _error = null;
        });
      }
    } on FormatException catch (exception) {
      setState(() {
        _ipv4Result = null;
        _ipv6Result = null;
        _error = exception.message;
      });
    }
  }

  void _limpar() {
    _ip.clear();
    _mask.clear();
    setState(() {
      _ipv4Result = null;
      _ipv6Result = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    _ip.dispose();
    _mask.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIpv4 = _version == IpVersion.ipv4;
    final presets = isIpv4 ? _ipv4Presets : _ipv6Presets;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.hub_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calculadora de Sub-rede',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Dimensionamento de blocos IPv4 e prefixos IPv6',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<IpVersion>(
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.12),
                            foregroundColor: Colors.white,
                            selectedBackgroundColor: Colors.white,
                            selectedForegroundColor: const Color(0xFF1E3A8A),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: IpVersion.ipv4,
                              icon: Icon(Icons.lan_outlined),
                              label: Text(
                                'IPv4 (32 bits)',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            ButtonSegment(
                              value: IpVersion.ipv6,
                              icon: Icon(Icons.public),
                              label: Text(
                                'IPv6 (128 bits)',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                          selected: {_version},
                          onSelectionChanged: (selection) =>
                              _trocarVersao(selection.first),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.blueGrey.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isIpv4
                                  ? 'Parâmetros da Rede IPv4'
                                  : 'Parâmetros do Prefixo IPv6',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _preencherExemplo,
                              icon: const Icon(Icons.bolt, size: 18),
                              label: const Text('Testar exemplo'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key('ip'),
                          controller: _ip,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            labelText:
                                isIpv4 ? 'Endereço IPv4' : 'Endereço IPv6',
                            hintText: isIpv4
                                ? 'Ex.: 192.168.10.37'
                                : 'Ex.: 2804:14d:5c80::1',
                            prefixIcon: const Icon(Icons.language),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          key: const Key('mask'),
                          controller: _mask,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _calcular(),
                          style: const TextStyle(fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            labelText: isIpv4
                                ? 'Máscara ou CIDR'
                                : 'Prefixo CIDR IPv6',
                            hintText: isIpv4
                                ? 'Ex.: /26 ou 255.255.255.192'
                                : 'Ex.: /56 ou /64',
                            prefixIcon: const Icon(Icons.settings_ethernet),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Atalhos:',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.blueGrey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ...presets.map(
                              (preset) => ActionChip(
                                label: Text(preset),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  _mask.text = preset;
                                  if (_ip.text.trim().isNotEmpty) {
                                    _calcular();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                key: const Key('calcular'),
                                onPressed: _calcular,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.calculate_outlined),
                                label: const Text(
                                  'Calcular Sub-rede',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _limpar,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Limpar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_ipv4Result != null) ...[
                  const SizedBox(height: 20),
                  _buildIpv4ResultCard(_ipv4Result!),
                ],
                if (_ipv6Result != null) ...[
                  const SizedBox(height: 20),
                  _buildIpv6ResultCard(_ipv6Result!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIpv4ResultCard(SubnetResult result) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blueGrey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resultado IPv4',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result.network}/${result.prefix}',
                    style: const TextStyle(
                      color: Color(0xFF1E40AF),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ResultRow(
              icon: Icons.security,
              label: 'Máscara Decimal',
              value: '${result.mask} (/${result.prefix})',
            ),
            _ResultRow(
              icon: Icons.router,
              label: 'Endereço de Rede',
              value: result.network,
            ),
            _ResultRow(
              icon: Icons.campaign,
              label: 'Endereço de Broadcast',
              value: result.broadcast,
            ),
            _ResultRow(
              icon: Icons.first_page,
              label: 'Primeiro Host Utilizável',
              value: result.firstHost,
            ),
            _ResultRow(
              icon: Icons.last_page,
              label: 'Último Host Utilizável',
              value: result.lastHost,
            ),
            _ResultRow(
              icon: Icons.devices,
              label: 'Total de Hosts Utilizáveis',
              value: '${result.usableHosts}',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpv6ResultCard(Ipv6SubnetResult result) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blueGrey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resultado IPv6',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '/${result.prefix}',
                    style: const TextStyle(
                      color: Color(0xFF1E40AF),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ResultRow(
              icon: Icons.account_tree_outlined,
              label: 'Prefixo da Rede (Abreviado)',
              value: result.networkPrefix,
            ),
            _ResultRow(
              icon: Icons.compress,
              label: 'Endereço Comprimido',
              value: result.compressedAddress,
            ),
            _ResultRow(
              icon: Icons.open_in_full,
              label: 'Endereço Expandido',
              value: result.expandedAddress,
            ),
            _ResultRow(
              icon: Icons.first_page,
              label: 'Início do Bloco',
              value: result.firstAddress,
            ),
            _ResultRow(
              icon: Icons.last_page,
              label: 'Fim do Bloco',
              value: result.lastAddress,
            ),
            _ResultRow(
              icon: Icons.grid_view_rounded,
              label: 'Capacidade de Redes /64',
              value: result.subnets64Label,
            ),
            _ResultRow(
              icon: Icons.all_inclusive,
              label: 'Total de Endereços IPv6',
              value: result.totalAddressesLabel,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey.shade50),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF1E40AF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copiar valor',
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: Colors.blueGrey.shade400,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copiado: $value'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
