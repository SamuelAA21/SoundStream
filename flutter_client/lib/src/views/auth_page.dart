import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/controllers.dart';

// ─── Paleta vibrante ──────────────────────────────────────────────────────────
class _C {
  static const purple   = Color(0xFF7C3AED);
  static const pink     = Color(0xFFEC4899);
  static const cyan     = Color(0xFF06B6D4);
  static const dark     = Color(0xFF0F0A1E);
  static const darkCard = Color(0xFF1A1030);
  static const surface  = Color(0xFF231845);
  static const border   = Color(0xFF3D2D6B);
  static const textMid  = Color(0xFFB8A9D9);
  static const white    = Colors.white;
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmail    = TextEditingController(text: 'demo@soundstream.local');
  final _loginPassword = TextEditingController(text: 'Demo12345');
  final _regName       = TextEditingController();
  final _regEmail      = TextEditingController();
  final _regPassword   = TextEditingController();
  final _regArtist     = TextEditingController();
  String _accountType  = 'user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose(); _loginPassword.dispose();
    _regName.dispose(); _regEmail.dispose();
    _regPassword.dispose(); _regArtist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: _C.dark,
      body: Stack(
        children: [
          // Fondo con orbes de color
          Positioned(top: -120, left: -80,
            child: _GlowOrb(color: _C.purple, size: 380)),
          Positioned(bottom: -100, right: -60,
            child: _GlowOrb(color: _C.pink, size: 320)),
          Positioned(top: 200, right: 80,
            child: _GlowOrb(color: _C.cyan, size: 180)),
          // Contenido
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      final wide = constraints.maxWidth >= 860;
                      if (wide) {
                        return Row(children: [
                          const Expanded(child: _Hero()),
                          const SizedBox(width: 32),
                          Expanded(child: _Card(
                            auth: auth,
                            tabController: _tabController,
                            loginEmail: _loginEmail, loginPassword: _loginPassword,
                            regName: _regName, regEmail: _regEmail,
                            regPassword: _regPassword, regArtist: _regArtist,
                            accountType: _accountType,
                            onTypeChanged: (v) => setState(() => _accountType = v),
                          )),
                        ]);
                      }
                      return SingleChildScrollView(child: _Card(
                        auth: auth,
                        tabController: _tabController,
                        loginEmail: _loginEmail, loginPassword: _loginPassword,
                        regName: _regName, regEmail: _regEmail,
                        regPassword: _regPassword, regArtist: _regArtist,
                        accountType: _accountType,
                        onTypeChanged: (v) => setState(() => _accountType = v),
                      ));
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Orbe de luz de fondo ─────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [
        color.withValues(alpha: 0.35),
        color.withValues(alpha: 0.0),
      ]),
    ),
  );
}

// ─── Panel izquierdo hero ─────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_C.purple, _C.pink],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.graphic_eq_rounded, color: _C.white, size: 36),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [_C.white, _C.cyan],
          ).createShader(b),
          child: const Text('SoundStream',
            style: TextStyle(
              color: _C.white, fontSize: 44,
              fontWeight: FontWeight.w900, height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu música, tus reglas.\nStreaming inteligente con\nrecomendaciones personalizadas.',
          style: TextStyle(
            color: _C.textMid, fontSize: 17, height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        _FeatureRow(icon: Icons.bolt_rounded,     color: _C.purple, label: 'Recomendaciones con IA'),
        const SizedBox(height: 16),
        _FeatureRow(icon: Icons.favorite_rounded, color: _C.pink,   label: 'Favoritos y playlists'),
        const SizedBox(height: 16),
        _FeatureRow(icon: Icons.history_rounded,  color: _C.cyan,   label: 'Historial de escucha'),
        const SizedBox(height: 16),
        _FeatureRow(icon: Icons.mic_rounded,      color: _C.purple, label: 'Panel de artista'),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 14),
      Text(label, style: const TextStyle(color: _C.white, fontSize: 15, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─── Tarjeta de autenticación ─────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({
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
        color: _C.darkCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.purple.withValues(alpha: 0.15),
            blurRadius: 60, offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text('Bienvenido',
            style: TextStyle(color: _C.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Accede con tu cuenta o crea una nueva',
            style: TextStyle(color: _C.textMid, fontSize: 14)),
          const SizedBox(height: 24),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [_C.purple, _C.pink]),
                borderRadius: BorderRadius.circular(11),
              ),
              labelColor: _C.white,
              unselectedLabelColor: _C.textMid,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: const [Tab(text: 'Iniciar sesión'), Tab(text: 'Registrarse')],
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
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(auth.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // Tab content
          SizedBox(
            height: 420,
            child: TabBarView(
              controller: tabController,
              children: [
                _LoginPanel(auth: auth, email: loginEmail, password: loginPassword),
                _RegisterPanel(
                  auth: auth, name: regName, email: regEmail,
                  password: regPassword, artistName: regArtist,
                  accountType: accountType, onAccountTypeChanged: onTypeChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input field con estilo dark ──────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _C.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _C.textMid, fontSize: 14),
        prefixIcon: Icon(icon, color: _C.textMid, size: 20),
        filled: true,
        fillColor: _C.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.purple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ─── Botón degradado ──────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.icon, required this.onPressed, required this.loading});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? null
              : const LinearGradient(colors: [_C.purple, _C.pink]),
          color: onPressed == null ? _C.border : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: _C.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, color: _C.white, size: 20),
                      const SizedBox(width: 10),
                      Text(label, style: const TextStyle(
                        color: _C.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Panel de login ───────────────────────────────────────────────────────────
class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.auth, required this.email, required this.password});
  final AuthController auth;
  final TextEditingController email, password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DarkField(controller: email,    label: 'Correo',     icon: Icons.mail_outline,  keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _DarkField(controller: password, label: 'Contraseña', icon: Icons.lock_outline,  obscure: true),
        const SizedBox(height: 16),
        // Demo hint
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.purple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.purple.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: _C.purple, size: 18),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cuenta demo', style: TextStyle(color: _C.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 3),
              Text('demo@soundstream.local  ·  Demo12345',
                style: TextStyle(color: _C.textMid, fontSize: 12)),
            ]),
          ]),
        ),
        const Spacer(),
        _GradientButton(
          label: 'Entrar a SoundStream',
          icon: Icons.login_rounded,
          loading: auth.isBusy,
          onPressed: auth.isBusy ? null : () async {
            try {
              await auth.login(email: email.text.trim(), password: password.text);
            } catch (_) {}
          },
        ),
      ],
    );
  }
}

// ─── Panel de registro ────────────────────────────────────────────────────────
class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.auth, required this.name, required this.email,
    required this.password, required this.artistName,
    required this.accountType, required this.onAccountTypeChanged,
  });
  final AuthController auth;
  final TextEditingController name, email, password, artistName;
  final String accountType;
  final ValueChanged<String> onAccountTypeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        _DarkField(controller: name,     label: 'Nombre',      icon: Icons.person_outline),
        const SizedBox(height: 12),
        _DarkField(controller: email,    label: 'Correo',      icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _DarkField(controller: password, label: 'Contraseña',  icon: Icons.lock_outline, obscure: true),
        const SizedBox(height: 12),
        // Selector tipo de cuenta
        Container(
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
          ),
          child: Row(children: [
            _TypeChip(label: 'Usuario', icon: Icons.person_rounded,
              selected: accountType == 'user', onTap: () => onAccountTypeChanged('user')),
            _TypeChip(label: 'Artista', icon: Icons.mic_rounded,
              selected: accountType == 'artist', onTap: () => onAccountTypeChanged('artist')),
          ]),
        ),
        if (accountType == 'artist') ...[
          const SizedBox(height: 12),
          _DarkField(controller: artistName, label: 'Nombre artístico', icon: Icons.mic_none_rounded),
        ],
        const SizedBox(height: 20),
        _GradientButton(
          label: 'Crear cuenta',
          icon: Icons.person_add_alt_1_rounded,
          loading: auth.isBusy,
          onPressed: auth.isBusy ? null : () async {
            try {
              await auth.register(
                name: name.text.trim(), email: email.text.trim(),
                password: password.text, accountType: accountType,
                artistName: accountType == 'artist' ? artistName.text.trim() : null,
              );
            } catch (_) {}
          },
        ),
      ]),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_C.purple, _C.pink])
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: selected ? _C.white : _C.textMid, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              color: selected ? _C.white : _C.textMid,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            )),
          ]),
        ),
      ),
    );
  }
}