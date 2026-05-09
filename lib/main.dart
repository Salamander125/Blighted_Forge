import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu_screen.dart';

void main() {
  runApp(const BlightedAdminApp());
}

class BlightedAdminApp extends StatelessWidget {
  const BlightedAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blighted Property',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.merriweatherTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          color: const Color(0xFF141B2D).withOpacity(0.96),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Arrancamos directamente en el menú principal como "Jugador"
      home: const MainMenuScreen(username: 'Jugador', userId: 0),
    );
  }
}