import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// Asegúrate de tener los imports correctos a tus pantallas
import 'abilities_screen.dart';
import 'cards_screen.dart';
import 'enemies_screen.dart';
import 'effects_screen.dart';
import 'cards_viewer_screen.dart';
import 'character_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final String username;
  final int userId;

  const MainMenuScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late String currentUsername;

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
  }

  // Ahora la comprobación es 100% a prueba de fallos de mayúsculas/minúsculas
  bool get isAdmin {
    final lower = currentUsername.toLowerCase();
    return lower == 'salamander' || lower == 'salamander125';
  }

  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AdminLoginDialog(
        onSuccess: (String realUsername) {
          // El setState obliga a Flutter a repintar la pantalla con las nuevas tarjetas
          setState(() {
            currentUsername = realUsername;
          });
        },
      ),
    );
  }

  void _logoutAdmin() {
    setState(() {
      currentUsername = "Jugador";
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<MenuOption> options = [
      MenuOption(
        title: "Efectos y estados",
        subtitle: "Consulta como funcionan los efectos",
        icon: Icons.explore_off_rounded,
        route: '/effects_and_states',
        accent: const Color(0xFFEF4444),
      ),
      MenuOption(
        title: "Personajes",
        subtitle: "Consulta los personajes y habilidades",
        icon: Icons.auto_stories_rounded,
        route: '/characters',
        accent: const Color(0xFF22D3EE),
      ),
      MenuOption(
        title: "Enemigos",
        subtitle: "Explora el bestiario de Yarnia",
        icon: Icons.face_rounded,
        route: '/enemies',
        accent: const Color(0xFF34D399),
      ),
      MenuOption(
        title: "Cartas",
        subtitle: "Explora las cartas disponibles",
        icon: Icons.save_rounded,
        route: '/cardsViewer',
        accent: const Color(0xFF8B5CF6),
      ),
      if (isAdmin)
        MenuOption(
          title: "Forja de cartas",
          subtitle: "Crea y equilibra cartas",
          icon: Icons.style_rounded,
          route: '/cards',
          accent: const Color(0xFFF59E0B),
          isAdminOption: true,
        ),
      if (isAdmin)
        MenuOption(
          title: "Habilidades",
          subtitle: "Edita poderes y estados",
          icon: Icons.auto_fix_high_rounded,
          route: '/abilities',
          accent: const Color(0xFF8B5CF6),
          isAdminOption: true,
        ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090E1A), Color(0xFF0F172A), Color(0xFF16112B)],
          ),
        ),
        child: Stack(
          children: [
            _glow(top: -60, right: -30, size: 180, color: const Color(0xFF8B5CF6).withOpacity(0.16)),
            _glow(bottom: -70, left: -40, size: 200, color: const Color(0xFF22D3EE).withOpacity(0.10)),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    isAdmin: isAdmin,
                    onLogoutAdmin: _logoutAdmin,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        _HeroBlock(
                          username: currentUsername,
                          isAdmin: isAdmin,
                          onAdminTap: _showAdminLoginDialog,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          "Accesos",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Selecciona una sección para continuar.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimationLimiter(
                          child: Column(
                            children: List.generate(options.length, (index) {
                              final option = options[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 420),
                                child: SlideAnimation(
                                  verticalOffset: 28,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: _MenuCard(
                                        option: option,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color, blurRadius: size * 0.55, spreadRadius: size * 0.18)],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onLogoutAdmin;

  const _TopBar({required this.isAdmin, required this.onLogoutAdmin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
              ),
            ),
            child: const Icon(Icons.videogame_asset_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Blighted Forge",
              style: GoogleFonts.pressStart2p(fontSize: 13, color: const Color(0xFFEDE9FE)),
            ),
          ),
          if (isAdmin)
            IconButton(
              tooltip: "Salir de Modo Admin",
              onPressed: onLogoutAdmin,
              icon: Icon(Icons.logout_rounded, color: Colors.redAccent.withOpacity(0.8)),
            ),
        ],
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  final String username;
  final bool isAdmin;
  final VoidCallback onAdminTap;

  const _HeroBlock({required this.username, required this.isAdmin, required this.onAdminTap});

  @override
  Widget build(BuildContext context) {
    final Color accent = isAdmin ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D).withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.24), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: accent.withOpacity(0.12),
                  border: Border.all(color: accent.withOpacity(0.26)),
                ),
                child: Icon(
                  isAdmin ? Icons.workspace_premium_rounded : Icons.person_rounded,
                  color: accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenido",
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: accent.withOpacity(0.25)),
                      ),
                      child: Text(
                        isAdmin ? "Acceso de administrador" : "Acceso de jugador",
                        style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isAdmin
                ? "Gestiona cartas, habilidades y partidas desde el núcleo de control."
                : "Consulta la base de datos de cartas, habilidades y personajes.",
            style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 13, height: 1.35),
          ),
          if (!isAdmin) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdminTap,
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                label: const Text("ENTRAR EN MODO ADMIN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B).withOpacity(0.15),
                  foregroundColor: const Color(0xFFFCD34D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuOption option;
  final int userId;

  const _MenuCard({required this.option, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (option.route == '/abilities') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AbilitiesAdminScreen())); 
          } else if (option.route == '/cards') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsAdminScreen()));
          } else if (option.route == '/enemies') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EnemiesScreen()));
          } else if (option.route == '/characters') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CharactersScreen()));
          } else if (option.route == '/effects_and_states') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EffectsScreen()));
          } else if (option.route == '/cardsViewer') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsViewerScreen()));
          }    
        },
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF141B2D).withOpacity(0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: option.accent.withOpacity(0.22)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10, bottom: -10,
                child: Icon(option.icon, size: 90, color: option.accent.withOpacity(0.06)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: option.accent.withOpacity(0.12),
                        border: Border.all(color: option.accent.withOpacity(0.24)),
                      ),
                      child: Icon(option.icon, color: option.accent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (option.isAdminOption)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                              child: const Text("ADMIN", style: TextStyle(color: Color(0xFFFCD34D), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                            ),
                          Text(option.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(option.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.62), fontSize: 13, height: 1.3)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white.withOpacity(0.70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color accent;
  final bool isAdminOption;

  MenuOption({required this.title, required this.subtitle, required this.icon, required this.route, required this.accent, this.isAdminOption = false});
}

// ==========================================
// EL NUEVO PANEL EMERGENTE DE LOGIN ADMIN (CON API)
// ==========================================
class AdminLoginDialog extends StatefulWidget {
  final Function(String) onSuccess;

  const AdminLoginDialog({super.key, required this.onSuccess});

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      _showError("Por favor, rellena todos los campos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Llamada real a la base de datos
      final response = await http.post(
        Uri.parse('http://blightedproperty.somee.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': user,
          'PasswordHash': pass,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final String loggedInUser = userData['username'].toString();
        final String lowerUser = loggedInUser.toLowerCase();

        // 2. Si la BDD dice que la contraseña es correcta, verificamos que el usuario sea el admin
        if (lowerUser == 'salamander' || lowerUser == 'salamander125') {
          if (!mounted) return;
          Navigator.pop(context); // Cierra el modal
          widget.onSuccess(loggedInUser); // Activa el modo admin y repinta la pantalla
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("🛡️ Acceso de administrador concedido", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: const Color(0xFF34D399).withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        } else {
          // Si hace login pero no es la cuenta de Salamander
          _showError("Acceso denegado: Tu cuenta no tiene permisos de administrador.");
        }
      } else {
        // Falló en la base de datos (contraseña incorrecta o no existe)
        _showError("Acceso denegado: Credenciales inválidas.");
      }
    } catch (e) {
      _showError("Error de conexión con el servidor.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF141B2D).withOpacity(0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.50), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 15)),
            BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.15), blurRadius: 50, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFFFD166), Color(0xFFF59E0B)]),
                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.35), blurRadius: 22, spreadRadius: 1)],
              ),
              child: const Icon(Icons.shield_moon, size: 36, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 20),
            Text(
              "PANEL DE CONTROL",
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 14, color: const Color(0xFFEDE9FE), letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              "Introduce credenciales de administrador para desbloquear la forja.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _userController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: _inputStyle("Usuario", Icons.person_outline_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              onSubmitted: (_) => _isLoading ? null : _handleLogin(),
              decoration: _inputStyle(
                "Contraseña", 
                Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white.withOpacity(0.65)),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCELAR", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)]),
                        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 8))],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleLogin,
                        icon: _isLoading 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                          : const Icon(Icons.login_rounded, size: 20),
                        label: Text(_isLoading ? "VERIFICANDO" : "ACCEDER", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledForegroundColor: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72), fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: const Color(0xFF22D3EE).withOpacity(0.9), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF0F1525),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.8)),
    );
  }
}