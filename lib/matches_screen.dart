import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MatchesScreen extends StatefulWidget {
  final int userId;
  final bool soloActivas; // true = Partidas a medias / false = Historial

  const MatchesScreen({
    super.key,
    required this.userId,
    required this.soloActivas,
  });

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<dynamic> _matches = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Suponemos que tienes un endpoint para activas y otro para historial.
      // Si en C# aún no tienes el de historial, puedes usar el general y filtrar aquí.
      final endpoint = widget.soloActivas ? 'active' : 'history';
      final url = Uri.parse('http://blightedproperty.somee.com/api/matches/$endpoint/${widget.userId}');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _matches = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Error del servidor: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error de conexión. Revisa tu internet.";
        _isLoading = false;
      });
    }
  }

  // Traductor de Pisos a Zonas (Igual que en Unity)
  String _getZoneName(int floor) {
    if (floor < 5) return "Bosque Oscuro";
    if (floor < 10) return "Cavernas del Lamento";
    return "Castillo del Rey";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.soloActivas ? "PARTIDAS EN CURSO" : "HISTORIAL DE GLORIA"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 15),
            const Text("No hay partidas registradas aquí", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final int floor = match['floorReached'] ?? 0;
    final String zoneName = _getZoneName(floor);
    final List<dynamic> characters = match['characters'] ?? [];
    
    // Formatear tiempo
    final int totalSeconds = match['playTimeSeconds'] ?? 0;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF1A1A1A),
        // Aquí podrías cargar una imagen real desde tus assets de Flutter
        // image: DecorationImage(image: AssetImage('assets/zones/zone_$floor.jpg'), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          // Capa 1: Fondo oscuro semitransparente (el efecto de Unity)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withOpacity(0.6), // Filtro oscuro
            ),
          ),
          
          // Capa 2: Contenido
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: Zona y Piso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      zoneName.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    Text(
                      "PISO $floor",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Stats: Oro, Enemigos, Tiempo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(icon: Icons.monetization_on, value: "${match['goldCollected']} G", color: Colors.amber),
                    _StatBadge(icon: Icons.sports_kabaddi, value: "${match['enemiesKilled']}", color: Colors.redAccent),
                    _StatBadge(icon: Icons.timer, value: timeStr, color: Colors.lightBlue),
                  ],
                ),
                
                const Spacer(),
                
                // Retratos de los personajes
                Row(
                  children: characters.map((char) => _buildCharacterPortrait(char)).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterPortrait(Map<String, dynamic> char) {
    String name = char['characterName'] ?? 'Unknown';
    int life = char['currentLife'] ?? 0;
    bool isDead = life <= 0;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          // El círculo del retrato
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDead ? Colors.red : Colors.green, width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[800],
              // Si subes las caras a Flutter, usarías: backgroundImage: AssetImage('assets/faces/${name.toLowerCase()}.png'),
              // Mientras tanto, ponemos la inicial del nombre:
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(color: isDead ? Colors.grey : Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatBadge({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}