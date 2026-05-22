import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_dark_text_field.dart';
import '../../../shared/widgets/app_gradient_button.dart';
import '../../../theme/app_colors.dart';
import 'account_type_chip.dart';

class RegisterPanel extends StatelessWidget {
  const RegisterPanel({
    super.key,
    required this.auth,
    required this.name,
    required this.email,
    required this.password,
    required this.artistName,
    required this.accountType,
    required this.onAccountTypeChanged,
  });
  final AuthController auth;
  final TextEditingController name, email, password, artistName;
  final String accountType;
  final ValueChanged<String> onAccountTypeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppDarkTextField(
            controller: name,
            label: 'Nombre',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppDarkTextField(
            controller: email,
            label: 'Correo',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppDarkTextField(
            controller: password,
            label: 'Contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          // Selector tipo de cuenta
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                AccountTypeChip(
                  label: 'Usuario',
                  icon: Icons.person_rounded,
                  selected: accountType == 'user',
                  onTap: () => onAccountTypeChanged('user'),
                ),
                AccountTypeChip(
                  label: 'Artista',
                  icon: Icons.mic_rounded,
                  selected: accountType == 'artist',
                  onTap: () => onAccountTypeChanged('artist'),
                ),
              ],
            ),
          ),
          if (accountType == 'artist') ...[
            const SizedBox(height: 12),
            AppDarkTextField(
              controller: artistName,
              label: 'Nombre artístico',
              icon: Icons.mic_none_rounded,
            ),
          ],
          const SizedBox(height: 20),
          AppGradientButton(
            label: 'Crear cuenta',
            icon: Icons.person_add_alt_1_rounded,
            isLoading: auth.isBusy,
            fullWidth: true,
            height: 52,
            onPressed: auth.isBusy
                ? null
                : () async {
                    try {
                      await auth.register(
                        name: name.text.trim(),
                        email: email.text.trim(),
                        password: password.text,
                        accountType: accountType,
                        artistName: accountType == 'artist'
                            ? artistName.text.trim()
                            : null,
                      );
                    } catch (_) {}
                  },
          ),
        ],
      ),
    );
  }
}
