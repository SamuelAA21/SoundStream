import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../theme/app_colors.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_hero.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmail = TextEditingController(text: 'demo@soundstream.local');
  final _loginPassword = TextEditingController(text: 'Demo12345');
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();
  final _regArtist = TextEditingController();
  String _accountType = 'user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _regArtist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final wide = constraints.maxWidth >= 860;
                    final card = AuthCard(
                      auth: auth,
                      tabController: _tabController,
                      loginEmail: _loginEmail,
                      loginPassword: _loginPassword,
                      regName: _regName,
                      regEmail: _regEmail,
                      regPassword: _regPassword,
                      regArtist: _regArtist,
                      accountType: _accountType,
                      onTypeChanged: (v) => setState(() => _accountType = v),
                    );
                    if (wide) {
                      return Row(
                        children: [
                          const Expanded(child: AuthHero()),
                          const SizedBox(width: 32),
                          Expanded(child: card),
                        ],
                      );
                    }
                    return SingleChildScrollView(child: card);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
