import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmail = TextEditingController(text: 'demo@soundstream.local');
  final _loginPassword = TextEditingController(text: 'Demo12345');
  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  final _registerArtistName = TextEditingController();
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
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    _registerArtistName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primaryContainer,
              const Color(0xFFF4F7F8),
              const Color(0xFFEAF3F5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 860;
                  return compact
                      ? _AuthCard(
                          auth: auth,
                          tabController: _tabController,
                          loginEmail: _loginEmail,
                          loginPassword: _loginPassword,
                          registerName: _registerName,
                          registerEmail: _registerEmail,
                          registerPassword: _registerPassword,
                          registerArtistName: _registerArtistName,
                          accountType: _accountType,
                          onAccountTypeChanged: (value) => setState(() => _accountType = value),
                        )
                      : Row(
                          children: [
                            const Expanded(child: _AuthHero()),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _AuthCard(
                                auth: auth,
                                tabController: _tabController,
                                loginEmail: _loginEmail,
                                loginPassword: _loginPassword,
                                registerName: _registerName,
                                registerEmail: _registerEmail,
                                registerPassword: _registerPassword,
                                registerArtistName: _registerArtistName,
                                accountType: _accountType,
                                onAccountTypeChanged: (value) => setState(() => _accountType = value),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.24),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 52),
          SizedBox(height: 24),
          Text(
            'SoundStream',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Streaming, favoritos, playlists, historial y recomendacion inteligente en una sola app Flutter.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.45,
            ),
          ),
          SizedBox(height: 28),
          _HeroStat(
            title: 'Listo para Web y Android',
            subtitle: 'Conectado al backend REST actual',
          ),
          SizedBox(height: 14),
          _HeroStat(
            title: 'Roles reales',
            subtitle: 'Usuario, artista y administrador',
          ),
          SizedBox(height: 14),
          _HeroStat(
            title: 'Flujo editorial mejorado',
            subtitle: 'Canciones sueltas, albumes vacios y asignacion posterior',
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.auth,
    required this.tabController,
    required this.loginEmail,
    required this.loginPassword,
    required this.registerName,
    required this.registerEmail,
    required this.registerPassword,
    required this.registerArtistName,
    required this.accountType,
    required this.onAccountTypeChanged,
  });

  final AuthController auth;
  final TabController tabController;
  final TextEditingController loginEmail;
  final TextEditingController loginPassword;
  final TextEditingController registerName;
  final TextEditingController registerEmail;
  final TextEditingController registerPassword;
  final TextEditingController registerArtistName;
  final String accountType;
  final ValueChanged<String> onAccountTypeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Acceso',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Usa una cuenta demo o crea una nueva para empezar.'),
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: colors.onPrimary,
                unselectedLabelColor: colors.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Iniciar sesion'),
                  Tab(text: 'Registrarse'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (auth.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  auth.error!,
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
            SizedBox(
              height: 440,
              child: TabBarView(
                controller: tabController,
                children: [
                  _LoginPanel(auth: auth, email: loginEmail, password: loginPassword),
                  _RegisterPanel(
                    auth: auth,
                    name: registerName,
                    email: registerEmail,
                    password: registerPassword,
                    artistName: registerArtistName,
                    accountType: accountType,
                    onAccountTypeChanged: onAccountTypeChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.auth,
    required this.email,
    required this.password,
  });

  final AuthController auth;
  final TextEditingController email;
  final TextEditingController password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: email,
          decoration: const InputDecoration(
            labelText: 'Correo',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contrasena',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuenta demo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text('demo@soundstream.local'),
              Text('Demo12345'),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
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
            icon: auth.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: const Text('Entrar a SoundStream'),
          ),
        ),
      ],
    );
  }
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.auth,
    required this.name,
    required this.email,
    required this.password,
    required this.artistName,
    required this.accountType,
    required this.onAccountTypeChanged,
  });

  final AuthController auth;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController artistName;
  final String accountType;
  final ValueChanged<String> onAccountTypeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: email,
            decoration: const InputDecoration(
              labelText: 'Correo',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contrasena',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: accountType,
            decoration: const InputDecoration(
              labelText: 'Tipo de cuenta',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'user', child: Text('Usuario')),
              DropdownMenuItem(value: 'artist', child: Text('Artista')),
            ],
            onChanged: (value) {
              if (value != null) {
                onAccountTypeChanged(value);
              }
            },
          ),
          if (accountType == 'artist') ...[
            const SizedBox(height: 12),
            TextField(
              controller: artistName,
              decoration: const InputDecoration(
                labelText: 'Nombre artistico',
                prefixIcon: Icon(Icons.mic_none_rounded),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: auth.isBusy
                  ? null
                  : () async {
                      try {
                        await auth.register(
                          name: name.text.trim(),
                          email: email.text.trim(),
                          password: password.text,
                          accountType: accountType,
                          artistName: accountType == 'artist' ? artistName.text.trim() : null,
                        );
                      } catch (_) {}
                    },
              icon: auth.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Crear cuenta'),
            ),
          ),
        ],
      ),
    );
  }
}
