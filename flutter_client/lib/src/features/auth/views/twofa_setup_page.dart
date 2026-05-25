import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../models/domain_models.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';

class TwofaSetupPage extends StatefulWidget {
  const TwofaSetupPage({super.key});

  @override
  State<TwofaSetupPage> createState() => _TwofaSetupPageState();
}

class _TwofaSetupPageState extends State<TwofaSetupPage> {
  TotpSetupData? _setupData;
  bool _loading = true;
  String? _error;
  bool _confirmed = false;

  final _codeController = TextEditingController();
  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _loadSetup();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadSetup() async {
    try {
      final auth = context.read<AuthController>();
      final data = await auth.setupTotp();
      if (mounted) setState(() { _setupData = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _confirm() async {
    if (_codeController.text.length != 6) return;
    setState(() { _submitting = true; _submitError = null; });
    try {
      final auth = context.read<AuthController>();
      await auth.confirmTotp(_codeController.text);
      if (mounted) setState(() { _confirmed = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitError = 'Código inválido. Intenta de nuevo.';
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.white,
        title: const Text(
          'Autenticación de dos factores',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
      );
    }
    if (_confirmed) {
      return _buildSuccess();
    }
    return _buildSetupForm();
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cyan.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.verified_rounded, color: AppColors.cyan, size: 36),
        ),
        const SizedBox(height: 24),
        const Text(
          '2FA activado',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tu cuenta está protegida. Al iniciar sesión se pedirá el código de Google Authenticator.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMid, fontSize: 14),
        ),
        const SizedBox(height: 32),
        AppGradientButton(
          label: 'Listo',
          icon: Icons.check_rounded,
          fullWidth: true,
          height: 52,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSetupForm() {
    final data = _setupData!;
    final qrBytes = base64.decode(data.qrDataUrl.split(',').last);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configura Google Authenticator',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sigue estos pasos para activar la verificación en dos pasos.',
            style: TextStyle(color: AppColors.textMid, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _step('1', 'Instala Google Authenticator en tu teléfono si aún no lo tienes.'),
          const SizedBox(height: 16),
          _step('2', 'Abre la app, toca el botón + y elige "Escanear código QR".'),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.memory(qrBytes, width: 200, height: 200),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data.secret));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clave copiada al portapapeles')),
                );
              },
              icon: Icon(Icons.copy_rounded, size: 16, color: AppColors.textMid),
              label: Text(
                'Ingresar clave manual: ${data.secret}',
                style: TextStyle(color: AppColors.textMid, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _step('3', 'Ingresa el código de 6 dígitos que muestra la app para confirmar.'),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 10,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: AppColors.textMid.withValues(alpha: 0.4),
                fontSize: 28,
                letterSpacing: 10,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cyan),
              ),
            ),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 10),
            Text(
              _submitError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          AppGradientButton(
            label: 'Activar 2FA',
            icon: Icons.shield_rounded,
            isLoading: _submitting,
            fullWidth: true,
            height: 52,
            onPressed: _submitting ? null : _confirm,
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.cyan],
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
