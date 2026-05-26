import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';

class TotpSetupPanel extends StatefulWidget {
  const TotpSetupPanel({super.key, required this.auth});
  final AuthController auth;

  @override
  State<TotpSetupPanel> createState() => _TotpSetupPanelState();
}

class _TotpSetupPanelState extends State<TotpSetupPanel> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_codeController.text.length != 6) return;
    try {
      await widget.auth.confirmSetupTotp(_codeController.text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final setup = widget.auth.pendingTotpSetup!;
    final qrBytes = base64.decode(setup.qrDataUrl.split(',').last);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Configura la verificación',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Escanea el QR con Google Authenticator para proteger tu cuenta.',
            style: TextStyle(color: AppColors.textMid, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.memory(qrBytes, width: 160, height: 160),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: setup.secret));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clave copiada al portapapeles')),
                );
              },
              icon: Icon(Icons.copy_rounded, size: 14, color: AppColors.textMid),
              label: Text(
                setup.secret,
                style: TextStyle(
                  color: AppColors.textMid,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 10,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: AppColors.textMid.withValues(alpha: 0.4),
                fontSize: 26,
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
                borderSide: const BorderSide(color: AppColors.cyan),
              ),
            ),
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 16),
          AppGradientButton(
            label: 'Confirmar y entrar',
            icon: Icons.verified_user_rounded,
            isLoading: widget.auth.isBusy,
            fullWidth: true,
            height: 50,
            onPressed: widget.auth.isBusy ? null : _confirm,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: widget.auth.cancelTotp,
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textMid, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
