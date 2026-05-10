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

  Map<String, dynamic> toJson() => {
    'id': id,
    'rarity': rarity,
    'description': description,
    'buffType': buffType,
    'amount': amount,
    'appliesState': appliesState,
    'stateToApply': stateToApply,
    'stateDuration': stateDuration,
    'stateIntensity': stateIntensity,
  };
}

class CardsAdminScreen extends StatefulWidget {
  const CardsAdminScreen({super.key});

  @override
  State<CardsAdminScreen> createState() => _CardsAdminScreenState();
}

class _CardsAdminScreenState extends State<CardsAdminScreen> {
  static const String apiUrl = 'http://blightedproperty.somee.com/api/cards';

  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController(text: '0');
  final TextEditingController stateDurationCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController stateIntensityCtrl = TextEditingController(
    text: '0',
  );

  List<CardModel> cards = [];
  List<CardModel> filteredCards = [];
  bool isLoading = false;
  int currentId = 0;

  int rarityVal = 1;
  int buffTypeVal = 0;
  bool appliesStateVal = false;
  int stateToApplyVal = 0;

  String searchText = '';
  int rarityFilter = -1; // -1 = todas

  final Map<int, String> rarityNames = {
    1: 'Normal',
    2: 'Especial',
    3: 'Epica',
    4: 'Mitica',
  };

  final Map<int, String> buffTypeNames = {
    0: 'None',
    1: 'MaxLife',
    2: 'MaxMana',
    3: 'Attack',
    4: 'Speed',
    5: 'Defense',
    6: 'HealCurrentLife',
    7: 'RestoreCurrentMana',
    8: 'BonusLifeRegenPerFloor',
    9: 'BonusManaRegenPerFloor',
    10: 'CriticalChance',
    11: 'Evasion',
  };

  final Map<int, String> stateNames = {
    0: 'None',
    1: 'Veneno',
    2: 'Radiación',
    3: 'Quemadura',
    4: 'Hemorragia',
    5: 'Vitalidad',
    6: 'Lucidez',
    7: 'Prisa',
    8: 'Certeza',
    9: 'Coraza',
    10: 'Furia',
    11: 'Espejismo',
    12: 'Sifón',
    13: 'Baluarte',
    14: 'Fractura',
    15: 'Pesadez',
    16: 'Ceguera',
    17: 'Fragilidad',
    18: 'Fatiga',
    19: 'Silencio',
    20: 'Sueño',
    21: 'Escarcha',
    22: 'Cepo',
  };

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    amountCtrl.dispose();
    stateDurationCtrl.dispose();
    stateIntensityCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchCards() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        cards = data.map((json) => CardModel.fromJson(json)).toList();

        cards.sort((a, b) {
          if (b.rarity != a.rarity) return b.rarity.compareTo(a.rarity);
          return a.description.compareTo(b.description);
        });

        applyFilters();
      } else {
        showSnackbar(
          'Error al cargar cartas (${response.statusCode})',
          isError: true,
        );
      }
    } catch (e) {
      showSnackbar('Error de conexión al cargar cartas: $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    filteredCards = cards.where((card) {
      final matchesSearch = card.description.toLowerCase().contains(
        searchText.toLowerCase(),
      );
      final matchesRarity = rarityFilter == -1 || card.rarity == rarityFilter;
      return matchesSearch && matchesRarity;
    }).toList();

    if (mounted) setState(() {});
  }

  Future<void> saveCard() async {
    final safeDescription = descriptionCtrl.text.trim().isEmpty
        ? 'Carta sin descripción'
        : descriptionCtrl.text.trim();

    final card = CardModel(
      id: currentId,
      rarity: rarityVal,
      description: safeDescription,
      buffType: buffTypeVal,
      amount: double.tryParse(amountCtrl.text) ?? 0,
      appliesState: appliesStateVal,
      stateToApply: appliesStateVal ? stateToApplyVal : 0,
      stateDuration: appliesStateVal
          ? (int.tryParse(stateDurationCtrl.text) ?? 0)
          : 0,
      stateIntensity: appliesStateVal
          ? (int.tryParse(stateIntensityCtrl.text) ?? 0).clamp(0, 999)
          : 0,
    );

    try {
      final isNew = currentId == 0;
      final method = isNew ? http.post : http.put;
      final url = isNew ? Uri.parse(apiUrl) : Uri.parse('$apiUrl/$currentId');

      final response = await method(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(card.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showSnackbar(
          isNew ? '✨ Carta creada con éxito' : '✨ Carta actualizada con éxito',
        );
        clearForm();
        fetchCards();
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        showSnackbar(
          'Error del servidor (${response.statusCode}): ${response.body}',
          isError: true,
        );
      }
    } catch (e) {
      showSnackbar('Error de conexión al guardar carta: $e', isError: true);
    }
  }

  Future<void> deleteCard(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        showSnackbar('🗑️ Carta eliminada');
        fetchCards();
      } else {
        showSnackbar('Error al borrar (${response.statusCode})', isError: true);
      }
    } catch (e) {
      showSnackbar('Error de conexión al borrar carta', isError: true);
    }
  }

  void loadIntoForm(CardModel card) {
    currentId = card.id;
    rarityVal = rarityNames.containsKey(card.rarity) ? card.rarity : 1;
    descriptionCtrl.text = card.description;
    buffTypeVal = buffTypeNames.containsKey(card.buffType) ? card.buffType : 0;
    amountCtrl.text = card.amount.toString();
    appliesStateVal = card.appliesState;
    stateToApplyVal = stateNames.containsKey(card.stateToApply)
        ? card.stateToApply
        : 0;
    stateDurationCtrl.text = card.stateDuration.toString();
    stateIntensityCtrl.text = card.stateIntensity.toString();
    setState(() {});
  }

  void clearForm() {
    currentId = 0;
    rarityVal = 1;
    descriptionCtrl.clear();
    buffTypeVal = 0;
    amountCtrl.text = '0';
    appliesStateVal = false;
    stateToApplyVal = 0;
    stateDurationCtrl.text = '0';
    stateIntensityCtrl.text = '0';
    setState(() {});
  }

  void showCreateOrEditSheet({CardModel? card}) {
    if (card != null) {
      loadIntoForm(card);
    } else {
      clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void syncState(VoidCallback fn) {
              setState(fn);
              setModalState(fn);
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Expanded(child: buildForm(syncState)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void confirmDelete(CardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          '¿Borrar carta?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Estás a punto de borrar "${card.description}".',
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              deleteCard(card.id);
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  Color rarityColor(int rarity) {
    switch (rarity) {
      case 1:
        return const Color(0xFF94A3B8);
      case 2:
        return const Color(0xFF22D3EE);
      case 3:
        return const Color(0xFF8B5CF6);
      case 4:
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  IconData buffIcon(int buffType) {
    switch (buffType) {
      case 0:
        return Icons.gpp_bad_rounded;
      case 1:
        return Icons.favorite_rounded;
      case 2:
        return Icons.water_drop_rounded;
      case 3:
        return Icons.shield_rounded;
      case 4:
        return Icons.bolt_rounded;
      case 5:
        return Icons.crisis_alert_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'FORJA DE CARTAS',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: const Color(0xFFEDE9FE),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchCards,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090E1A), Color(0xFF10172A), Color(0xFF16112B)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141B2D).withOpacity(0.96),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.style_rounded,
                        color: Color(0xFFF59E0B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biblioteca de cartas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crea, ajusta y elimina cartas del sistema.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      searchText = value;
                      applyFilters();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec(
                      'Buscar por descripción',
                      Icons.search_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip('Todas', -1),
                        _filterChip('Normal', 1),
                        _filterChip('Especial', 2),
                        _filterChip('Epica', 3),
                        _filterChip('Mitica', 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCards.isEmpty
                  ? Center(
                      child: Text(
                        'No hay cartas disponibles',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.60),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchCards,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];
                            final color = rarityColor(card.rarity);

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 380),
                              child: SlideAnimation(
                                verticalOffset: 26,
                                child: FadeInAnimation(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF141B2D,
                                      ).withOpacity(0.96),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: color.withOpacity(0.24),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(22),
                                        onTap: () =>
                                            showCreateOrEditSheet(card: card),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 58,
                                                height: 58,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  color: color.withOpacity(
                                                    0.12,
                                                  ),
                                                  border: Border.all(
                                                    color: color.withOpacity(
                                                      0.25,
                                                    ),
                                                  ),
                                                ),
                                                child: Icon(
                                                  buffIcon(card.buffType),
                                                  color: color,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 5,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: color
                                                                .withOpacity(
                                                                  0.10,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  999,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            rarityNames[card
                                                                    .rarity] ??
                                                                'Desconocida',
                                                            style: TextStyle(
                                                              color: color,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      card.description,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 6,
                                                      children: [
                                                        _statChip(
                                                          '${buffTypeNames[card.buffType] ?? 'Buff'}',
                                                          color,
                                                        ),
                                                        _statChip(
                                                          'Valor ${card.amount}',
                                                          const Color(
                                                            0xFF22D3EE,
                                                          ),
                                                        ),
                                                        if (card.appliesState)
                                                          _statChip(
                                                            stateNames[card
                                                                    .stateToApply] ??
                                                                'Estado',
                                                            const Color(
                                                              0xFF8B5CF6,
                                                            ),
                                                          ),
                                                        if (card.appliesState)
                                                          _statChip(
                                                            '${card.stateDuration} turnos',
                                                            const Color(
                                                              0xFF34D399,
                                                            ),
                                                          ),
                                                        if (card.appliesState)
                                                          _statChip(
                                                            'Int ${card.stateIntensity}',
                                                            const Color(
                                                              0xFFF472B6,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () =>
                                                    confirmDelete(card),
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        onPressed: () => showCreateOrEditSheet(),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text(
          'Nueva carta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _filterChip(String label, int value) {
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
        selectedColor: const Color(0xFF8B5CF6).withOpacity(0.22),
        backgroundColor: const Color(0xFF141B2D),
        labelStyle: TextStyle(
          color: isSelected
              ? const Color(0xFFC4B5FD)
              : Colors.white.withOpacity(0.70),
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF8B5CF6).withOpacity(0.40)
              : Colors.white.withOpacity(0.08),
        ),
      ),
    );
  }

  Widget _statChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget buildForm(void Function(VoidCallback) stateSetter) {
    final previewColor = rarityColor(rarityVal);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentId == 0
                      ? '✨ Nueva carta'
                      : '✏️ Editando carta #$currentId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141B2D),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: previewColor.withOpacity(0.24)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: previewColor.withOpacity(0.12),
                      ),
                      child: Icon(
                        buffIcon(buffTypeVal),
                        color: previewColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            descriptionCtrl.text.trim().isEmpty
                                ? 'Carta sin descripción'
                                : descriptionCtrl.text.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${rarityNames[rarityVal]} · ${buffTypeNames[buffTypeVal]} · Valor ${amountCtrl.text} · ${appliesStateVal ? ' · Int ${stateIntensityCtrl.text}' : ''}',

                            style: TextStyle(
                              color: Colors.white.withOpacity(0.62),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('INFORMACIÓN GENERAL'),
              TextField(
                controller: descriptionCtrl,
                onChanged: (_) => stateSetter(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Descripción', Icons.description_rounded),
                maxLines: 2,
              ),             
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: rarityVal,
                dropdownColor: const Color(0xFF141B2D),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec(
                  'Rareza',
                  Icons.workspace_premium_rounded,
                ),
                items: rarityNames.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => stateSetter(() => rarityVal = v ?? 1),
              ),

              const SizedBox(height: 24),
              _sectionTitle('EFECTO PRINCIPAL'),
              DropdownButtonFormField<int>(
                value: buffTypeVal,
                dropdownColor: const Color(0xFF141B2D),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec(
                  'Tipo de buff',
                  Icons.auto_awesome_rounded,
                ),
                items: buffTypeNames.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => stateSetter(() => buffTypeVal = v ?? 0),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                onChanged: (_) => stateSetter(() {}),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Cantidad / valor', Icons.tune_rounded),
              ),

              const SizedBox(height: 24),
              _sectionTitle('ESTADO ADICIONAL'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Aplica estado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: appliesStateVal,
                activeColor: const Color(0xFF8B5CF6),
                onChanged: (v) => stateSetter(() => appliesStateVal = v),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: !appliesStateVal
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          const SizedBox(height: 8),

                          DropdownButtonFormField<int>(
                            value: stateToApplyVal,
                            dropdownColor: const Color(0xFF141B2D),
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(
                              'Estado a aplicar',
                              Icons.bubble_chart_rounded,
                            ),                            
                            items: stateNames.entries
                                .where((e) => e.key != 0)
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                stateSetter(() => stateToApplyVal = v ?? 1),
                          ),

                         const SizedBox(height: 14),
                          TextField(
                            controller: stateIntensityCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(
                              'Intensidad del estado',
                              Icons.flash_on_rounded,
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextField(
                            controller: stateDurationCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDec(
                              'Duración en turnos',
                              Icons.timelapse_rounded,
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141B2D),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [previewColor, previewColor.withOpacity(0.70)],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: saveCard,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  currentId == 0 ? 'CREAR CARTA' : 'GUARDAR CAMBIOS',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFC4B5FD),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.70),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF22D3EE).withOpacity(0.9),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFF0F1525),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.8),
      ),
    );
  }
}
