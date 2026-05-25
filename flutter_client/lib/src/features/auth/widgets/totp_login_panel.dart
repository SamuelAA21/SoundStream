import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';

class TotpLoginPanel extends StatefulWidget {
  const TotpLoginPanel({super.key, required this.auth});
  final AuthController auth;

  @override
  State<TotpLoginPanel> createState() => _TotpLoginPanelState();
}

class _TotpLoginPanelState extends State<TotpLoginPanel> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.cyan, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Abre Google Authenticator e ingresa el código de 6 dígitos para SoundStream.',
                  style: TextStyle(color: AppColors.textMid, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: AppColors.textMid.withValues(alpha: 0.4),
              fontSize: 32,
              letterSpacing: 12,
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
        if (widget.auth.error != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.auth.error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
        const Spacer(),
        AppGradientButton(
          label: 'Verificar',
          icon: Icons.verified_outlined,
          isLoading: widget.auth.isBusy,
          fullWidth: true,
          height: 52,
          onPressed: widget.auth.isBusy
              ? null
              : () async {
                  if (_codeController.text.length != 6) return;
                  try {
                    await widget.auth.validateTotp(_codeController.text);
                  } catch (_) {}
                },
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: widget.auth.isBusy ? null : widget.auth.cancelTotp,
            child: Text(
              'Volver al inicio de sesión',
              style: TextStyle(color: AppColors.textMid, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
