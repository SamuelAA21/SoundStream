import 'package:flutter/material.dart';

import '../../../controllers/controllers.dart';
import '../../../theme/app_colors.dart';
import 'login_panel.dart';
import 'register_panel.dart';
import 'totp_login_panel.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.auth,
    required this.tabController,
    required this.loginEmail,
    required this.loginPassword,
    required this.regName,
    required this.regEmail,
    required this.regPassword,
    required this.regArtist,
    required this.accountType,
    required this.onTypeChanged,
  });

  final AuthController auth;
  final TabController tabController;
  final TextEditingController loginEmail, loginPassword;
  final TextEditingController regName, regEmail, regPassword, regArtist;
  final String accountType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.15),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Bienvenido',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Accede con tu cuenta o crea una nueva',
            style: TextStyle(color: AppColors.textMid, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple, AppColors.pink],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.textMid,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Iniciar sesión'),
                Tab(text: 'Registrarse'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error
          if (auth.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tab content — swap for TOTP panel when challenge pending
          SizedBox(
            height: 420,
            child: auth.requiresTOTP
                ? TotpLoginPanel(auth: auth)
                : TabBarView(
                    controller: tabController,
                    children: [
                      LoginPanel(
                        auth: auth,
                        email: loginEmail,
                        password: loginPassword,
                      ),
                      RegisterPanel(
                        auth: auth,
                        name: regName,
                        email: regEmail,
                        password: regPassword,
                        artistName: regArtist,
                        accountType: accountType,
                        onAccountTypeChanged: onTypeChanged,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
