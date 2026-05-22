import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_dark_text_field.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';

class LoginPanel extends StatelessWidget {
  const LoginPanel({
    super.key,
    required this.auth,
    required this.email,
    required this.password,
  });
  final AuthController auth;
  final TextEditingController email, password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDarkTextField(
          controller: email,
          label: 'Correo',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        AppDarkTextField(
          controller: password,
          label: 'Contraseña',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        // Demo hint
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.purple,
                size: 18,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cuenta demo',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'demo@soundstream.local  ·  Demo12345',
                    style: TextStyle(color: AppColors.textMid, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        AppGradientButton(
          label: 'Entrar a SoundStream',
          icon: Icons.login_rounded,
          isLoading: auth.isBusy,
          fullWidth: true,
          height: 52,
          onPressed: auth.isBusy
              ? null
              : () async {
                  try {
                    await auth.login(
                      email: email.text.trim(),
                      password: password.text,
                    );
                  } catch (_) {}
                },
        ),
      ],
    );
  }
}
