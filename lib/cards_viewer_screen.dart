import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class CardModel {
  int id;
  int rarity;
  String description;
  int buffType;
  double amount;
  bool appliesState;
  int stateToApply;
  int stateDuration;
  int stateIntensity;

  CardModel({
    required this.id,
    required this.rarity,
    required this.description,
    required this.buffType,
    required this.amount,
    required this.appliesState,
    required this.stateToApply,
    required this.stateDuration,
    required this.stateIntensity,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? 0,
      rarity: json['rarity'] ?? 1,
      description: json['description'] ?? '',
      buffType: json['buffType'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      appliesState: json['appliesState'] ?? false,
      stateToApply: json['stateToApply'] ?? 0,
      stateDuration: json['stateDuration'] ?? 0,
      stateIntensity: json['stateIntensity'] ?? 0,
    );
  }
}

class CardsViewerScreen extends StatefulWidget {
  const CardsViewerScreen({super.key});

  @override
  State<CardsViewerScreen> createState() => _CardsViewerScreenState();
}

class _CardsViewerScreenState extends State<CardsViewerScreen> {
  static const String apiUrl = 'http://blightedproperty.somee.com/api/cards';

  List<CardModel> cards = [];
  List<CardModel> filteredCards = [];
  bool isLoading = false;
  int rarityFilter = -1; // -1 = todas

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<void> fetchCards() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        cards = data.map((json) => CardModel.fromJson(json)).toList();

        // Ordenamos por rareza y luego por descripción
        cards.sort((a, b) {
          if (b.rarity != a.rarity) return b.rarity.compareTo(a.rarity);
          return a.description.compareTo(b.description);
        });

        applyFilters();
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    filteredCards = cards.where((card) {
      return rarityFilter == -1 || card.rarity == rarityFilter;
    }).toList();
    if (mounted) setState(() {});
  }

  String getRarityName(int rarity) {
    switch (rarity) {
      case 1: return 'Normal';
      case 2: return 'Especial';
      case 3: return 'Epica';
      case 4: return 'Mitica';
      default: return 'Normal';
    }
  }

  int getCardCost(int rarity) {
    switch (rarity) {
      case 1: return 60;
      case 2: return 80;
      case 3: return 120;
      case 4: return 150;
      default: return 60;
    }
  }

  Color getRarityColor(int rarity) {
    switch (rarity) {
      case 1: return const Color(0xFF94A3B8); // Normal
      case 2: return const Color(0xFF22D3EE); // Especial
      case 3: return const Color(0xFF8B5CF6); // Épica
      case 4: return const Color(0xFFF59E0B); // Mítica
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090E1A),
        elevation: 0,
        title: Text(
          "Colección de Cartas",
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Pestañas de Filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _filterChip('Todas', -1, Colors.white),
                  _filterChip('Normales', 1, const Color(0xFF94A3B8)),
                  _filterChip('Especiales', 2, const Color(0xFF22D3EE)),
                  _filterChip('Épicas', 3, const Color(0xFF8B5CF6)),
                  _filterChip('Míticas', 4, const Color(0xFFF59E0B)),
                ],
              ),
            ),
          ),

          // Grid de Cartas
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                : filteredCards.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron cartas.',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchCards,
                        child: AnimationLimiter(
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                            physics: const BouncingScrollPhysics(),
                            // ESTO ASEGURA EL TAMAÑO FIJO EN PC Y MÓVIL
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 240, // Ancho ideal de la carta
                              childAspectRatio: 0.70, // Proporción clásica 
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                columnCount: 2,
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildCardItem(card),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(CardModel card) {
    final String rarityName = getRarityName(card.rarity);
    final int cost = getCardCost(card.rarity);
    final Color rarityColor = getRarityColor(card.rarity);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.20),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Imagen de Fondo
            Image.asset(
              'assets/cards/$rarityName.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF141B2D),
                child: const Icon(Icons.broken_image, color: Colors.white24),
              ),
            ),

            // Opcional: Un ligero oscurecimiento general
            Container(color: Colors.black.withOpacity(0.15)),

            // 2. Descripción con LÍMITES PORCENTUALES (FractionallySizedBox)
            Align(
              alignment: const Alignment(0.0, -0.25), // Posición vertical
              child: FractionallySizedBox(
                widthFactor: 0.5, // <-- MAGIA: El texto ocupará como máximo el 82% del ancho de la carta. Cambia este número para estrechar o ensanchar el límite (ej. 0.75, 0.90).
                child: Text(
                  card.description,
                  textAlign: TextAlign.center,
                  maxLines: 8, // Si supera las 4 líneas, pone "..." (ellipsis)
                  overflow: TextOverflow.ellipsis,
                  softWrap: true, // Fuerza el salto de línea
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    // Sombra fuerte para asegurar visibilidad
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 12),
                      Shadow(color: Colors.black, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Indicador de Coste
            Align(
              alignment: const Alignment(0.0, 0.55), 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withOpacity(0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cost.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFBBF24), // Oro
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.monetization_on_rounded, // Icono Moneda
                      color: Color(0xFFFBBF24),
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int value, Color color) {
    final bool isSelected = rarityFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          rarityFilter = value;
          applyFilters();
        },
        selectedColor: color.withOpacity(0.20),
        backgroundColor: const Color(0xFF141B2D),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.white.withOpacity(0.60),
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 13,
        ),
        side: BorderSide(
          color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}