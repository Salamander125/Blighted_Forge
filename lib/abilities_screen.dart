import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. MODELO DE DATOS
// ==========================================
class Ability {
  int id;
  String ownerCharacter;
  String nombre;
  String descripcion;
  int damage;
  int healAmount;
  int manaCost;
  String shape;
  int range;
  bool targetsAllies;
  bool aplicaEstado;
  String tipoEstado;
  int duracionEstado;
  int potenciaEstado;
  String prefabPath;
  bool prefabPorCasilla;
  
  // --- NUEVOS DATOS AVANZADOS DE UNITY ---
  int moveOffsetX;
  int moveOffsetY;
  double spawnOffsetX;
  double spawnOffsetY;
  double spawnOffsetZ;
  bool secuencial;
  double delayEntreCasillas;
  bool esUnitarget;
  String tipoMovimiento;

  Ability({
    required this.id, required this.ownerCharacter, required this.nombre, required this.descripcion,
    required this.damage, required this.healAmount, required this.manaCost,
    required this.shape, required this.range, required this.targetsAllies,
    required this.aplicaEstado, required this.tipoEstado, required this.duracionEstado,
    required this.potenciaEstado, required this.prefabPath, required this.prefabPorCasilla,
    required this.moveOffsetX, required this.moveOffsetY,
    required this.spawnOffsetX, required this.spawnOffsetY, required this.spawnOffsetZ,
    required this.secuencial, required this.delayEntreCasillas,
    required this.esUnitarget, required this.tipoMovimiento,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      id: json['id'] ?? 0,
      ownerCharacter: json['ownerCharacter'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      damage: json['damage'] ?? 0,
      healAmount: json['healAmount'] ?? 0,
      manaCost: json['manaCost'] ?? 0,
      shape: json['shape'] ?? 'Single',
      range: json['range'] ?? 1,
      targetsAllies: json['targetsAllies'] ?? false,
      aplicaEstado: json['aplicaEstado'] ?? false,
      tipoEstado: json['tipoEstado'] ?? 'None',
      duracionEstado: json['duracionEstado'] ?? 0,
      potenciaEstado: json['potenciaEstado'] ?? 0,
      prefabPath: json['prefabPath'] ?? '',
      prefabPorCasilla: json['prefabPorCasilla'] ?? true,
      
      moveOffsetX: json['moveOffset']?['x'] ?? 0,
      moveOffsetY: json['moveOffset']?['y'] ?? 0,
      spawnOffsetX: (json['spawnOffset']?['x'] ?? 0).toDouble(),
      spawnOffsetY: (json['spawnOffset']?['y'] ?? 0).toDouble(),
      spawnOffsetZ: (json['spawnOffset']?['z'] ?? 0).toDouble(),
      
      secuencial: json['secuencial'] ?? false,
      delayEntreCasillas: (json['delayEntreCasillas'] ?? 0).toDouble(),
      esUnitarget: json['esUnitarget'] ?? false,
      tipoMovimiento: json['tipoMovimiento'] ?? 'Free',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 
    'ownerCharacter': ownerCharacter, 
    'nombre': nombre, 'descripcion': descripcion,
    'damage': damage, 'healAmount': healAmount, 'manaCost': manaCost,
    'shape': shape, 'range': range, 'targetsAllies': targetsAllies,
    'aplicaEstado': aplicaEstado, 'tipoEstado': tipoEstado,
    'duracionEstado': duracionEstado, 'potenciaEstado': potenciaEstado,
    'prefabPath': prefabPath, 'prefabPorCasilla': prefabPorCasilla,
    
    'moveOffset': {'x': moveOffsetX, 'y': moveOffsetY},
    'spawnOffset': {'x': spawnOffsetX, 'y': spawnOffsetY, 'z': spawnOffsetZ},
    'secuencial': secuencial,
    'delayEntreCasillas': delayEntreCasillas,
    'esUnitarget': esUnitarget,
    'tipoMovimiento': tipoMovimiento
  };
}

// ==========================================
// 2. PANTALLA PRINCIPAL
// ==========================================
class AbilitiesAdminScreen extends StatefulWidget {
  const AbilitiesAdminScreen({super.key});
  @override
  State<AbilitiesAdminScreen> createState() => _AbilitiesAdminScreenState();
}

class _AbilitiesAdminScreenState extends State<AbilitiesAdminScreen> {
  final String apiUrl = 'http://blightedproperty.somee.com/api/abilities';
  List<Ability> abilities = [];
  bool isLoading = false;

  int currentId = 0;
  
  // Controladores Básicos
  final ownerCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final dmgCtrl = TextEditingController(text: '0');
  final healCtrl = TextEditingController(text: '0');
  final manaCtrl = TextEditingController(text: '0');
  final rangeCtrl = TextEditingController(text: '1');
  String shapeVal = 'Single';
  bool targetsAlliesVal = false;
  
  // Controladores Estados
  bool aplicaEstadoVal = false;
  String tipoEstadoVal = 'None';
  final duracionEstadoCtrl = TextEditingController(text: '0');
  final potenciaEstadoCtrl = TextEditingController(text: '0');
  
  // Controladores Prefab
  final prefabCtrl = TextEditingController();
  bool prefabCasillaVal = true;

  // Controladores Avanzados
  final moveXCtrl = TextEditingController(text: '0');
  final moveYCtrl = TextEditingController(text: '0');
  final spawnXCtrl = TextEditingController(text: '0.0');
  final spawnYCtrl = TextEditingController(text: '0.0');
  final spawnZCtrl = TextEditingController(text: '0.0');
  bool secuencialVal = false;
  final delayCtrl = TextEditingController(text: '0.0');
  bool unitargetVal = false;
  String tipoMovVal = 'Free';

  final List<String> shapes = ['Single', 'Horizontal', 'Vertical', 'Cross', 'XShape', 'Square'];
  final List<String> movTipos = ['Free', 'LockedAtCenter', 'RowOnly', 'ColumnOnly'];
  final List<String> statesList = [
    'None', 'Veneno', 'Radiacion', 'Quemadura', 'Hemorragia', 
    'Vitalidad', 'Lucidez', 'Prisa', 'Certeza', 'Coraza', 'Furia', 
    'Espejismo', 'Sifon', 'Baluarte', 'Fractura', 'Pesadez', 'Ceguera', 
    'Fragilidad', 'Fatiga', 'Silencio', 'Sueno', 'Escarcha', 'Cepo'
  ];

  @override
  void initState() {
    super.initState();
    fetchAbilities();
  }

  Future<void> fetchAbilities() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          abilities = data.map((json) => Ability.fromJson(json)).toList();
          abilities.sort((a, b) => a.ownerCharacter.compareTo(b.ownerCharacter));
        });
      }
    } catch (e) {
      mostrarSnackbar('Error de conexión al cargar: $e', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveAbility() async {
    String safeOwner = ownerCtrl.text.trim().isEmpty ? 'Desconocido' : ownerCtrl.text.trim();
    String safeNombre = nombreCtrl.text.trim().isEmpty ? 'Sin Nombre' : nombreCtrl.text.trim();

    final ability = Ability(
      id: currentId, 
      ownerCharacter: safeOwner, 
      nombre: safeNombre,
      descripcion: descripcionCtrl.text.trim(),
      damage: int.tryParse(dmgCtrl.text) ?? 0, healAmount: int.tryParse(healCtrl.text) ?? 0,
      manaCost: int.tryParse(manaCtrl.text) ?? 0, shape: shapeVal,
      range: int.tryParse(rangeCtrl.text) ?? 1, targetsAllies: targetsAlliesVal,
      aplicaEstado: aplicaEstadoVal, tipoEstado: tipoEstadoVal,
      duracionEstado: int.tryParse(duracionEstadoCtrl.text) ?? 0,
      potenciaEstado: int.tryParse(potenciaEstadoCtrl.text) ?? 0,
      prefabPath: prefabCtrl.text, prefabPorCasilla: prefabCasillaVal,
      moveOffsetX: int.tryParse(moveXCtrl.text) ?? 0,
      moveOffsetY: int.tryParse(moveYCtrl.text) ?? 0,
      spawnOffsetX: double.tryParse(spawnXCtrl.text) ?? 0.0,
      spawnOffsetY: double.tryParse(spawnYCtrl.text) ?? 0.0,
      spawnOffsetZ: double.tryParse(spawnZCtrl.text) ?? 0.0,
      secuencial: secuencialVal,
      delayEntreCasillas: double.tryParse(delayCtrl.text) ?? 0.0,
      esUnitarget: unitargetVal,
      tipoMovimiento: tipoMovVal,
    );

    try {
      final isNew = currentId == 0;
      final method = isNew ? http.post : http.put;
      final url = isNew ? Uri.parse(apiUrl) : Uri.parse('$apiUrl/$currentId');
      
      Map<String, dynamic> payload = ability.toJson();
      if (isNew) payload['id'] = 0;      
      
      final response = await method(
        url, 
        headers: {'Content-Type': 'application/json'}, 
        body: json.encode(payload)
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        mostrarSnackbar('✨ Habilidad guardada con éxito');
        clearForm();
        fetchAbilities();
        if (!mounted) return;
        if (MediaQuery.of(context).size.width <= 850 && Navigator.canPop(context)) Navigator.pop(context);
      } else {
        mostrarSnackbar('Error del servidor (${response.statusCode}): ${response.body}', isError: true);
      }
    } catch (e) {
      mostrarSnackbar('Error de conexión al guardar: $e', isError: true);
    }
  }

  Future<void> deleteAbility(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        mostrarSnackbar('🗑️ Habilidad eliminada');
        fetchAbilities();
      } else {
        mostrarSnackbar('Error al borrar (${response.statusCode})', isError: true);
      }
    } catch (e) {
      mostrarSnackbar('Error de conexión al borrar', isError: true);
    }
  }

  void mostrarSnackbar(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent.withOpacity(0.9) : const Color(0xFF34D399).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void loadIntoForm(Ability a) {
    setState(() {
      currentId = a.id;
      ownerCtrl.text = a.ownerCharacter; nombreCtrl.text = a.nombre;
      descripcionCtrl.text = a.descripcion;
      dmgCtrl.text = a.damage.toString(); healCtrl.text = a.healAmount.toString();
      manaCtrl.text = a.manaCost.toString(); rangeCtrl.text = a.range.toString();
      shapeVal = shapes.contains(a.shape) ? a.shape : 'Single';
      targetsAlliesVal = a.targetsAllies;
      aplicaEstadoVal = a.aplicaEstado;
      tipoEstadoVal = statesList.contains(a.tipoEstado) ? a.tipoEstado : 'None';
      duracionEstadoCtrl.text = a.duracionEstado.toString();
      potenciaEstadoCtrl.text = a.potenciaEstado.toString();
      prefabCtrl.text = a.prefabPath; prefabCasillaVal = a.prefabPorCasilla;
      
      moveXCtrl.text = a.moveOffsetX.toString();
      moveYCtrl.text = a.moveOffsetY.toString();
      spawnXCtrl.text = a.spawnOffsetX.toString();
      spawnYCtrl.text = a.spawnOffsetY.toString();
      spawnZCtrl.text = a.spawnOffsetZ.toString();
      secuencialVal = a.secuencial;
      delayCtrl.text = a.delayEntreCasillas.toString();
      unitargetVal = a.esUnitarget;
      tipoMovVal = movTipos.contains(a.tipoMovimiento) ? a.tipoMovimiento : 'Free';
    });
  }

  void clearForm() {
    setState(() {
      currentId = 0;
      ownerCtrl.clear(); nombreCtrl.clear(); prefabCtrl.clear();
      descripcionCtrl.clear();
      dmgCtrl.text = '0'; healCtrl.text = '0'; manaCtrl.text = '0'; rangeCtrl.text = '1';
      shapeVal = 'Single'; targetsAlliesVal = false;
      aplicaEstadoVal = false; tipoEstadoVal = 'None';
      duracionEstadoCtrl.text = '0'; potenciaEstadoCtrl.text = '0';
      prefabCasillaVal = true;
      
      moveXCtrl.text = '0'; moveYCtrl.text = '0';
      spawnXCtrl.text = '0.0'; spawnYCtrl.text = '0.0'; spawnZCtrl.text = '0.0';
      secuencialVal = false; delayCtrl.text = '0.0';
      unitargetVal = false; tipoMovVal = 'Free';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 850;

    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'FORJA DE HABILIDADES', 
          style: GoogleFonts.pressStart2p(fontSize: 14, color: const Color(0xFFEDE9FE))
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded), 
            onPressed: fetchAbilities, 
          ),
          const SizedBox(width: 8),
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
        child: Row(
          children: [
            Expanded(child: buildList()),
            if (isDesktop)
              Container(
                width: 450,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border(left: BorderSide(color: Colors.white.withOpacity(0.06))),
                ),
                child: buildForm(isDesktop: true, stateSetter: setState), 
              ),
          ],
        ),
      ),
      floatingActionButton: isDesktop ? null : FloatingActionButton.extended(
        backgroundColor: const Color(0xFF22D3EE),
        foregroundColor: Colors.white,
        onPressed: () {
          clearForm();
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true, 
            backgroundColor: Colors.transparent,
            builder: (_) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.92,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A), 
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28))
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
                      Expanded(
                        child: buildForm(
                          isDesktop: false, 
                          stateSetter: (fn) {
                            setState(fn); 
                            setModalState(fn); 
                          }
                        ),
                      ),
                    ],
                  ),
                );
              }
            )
          );
        },
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Nueva', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildList() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE)));
    if (abilities.isEmpty) return Center(child: Text('No hay habilidades disponibles', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)));

    return RefreshIndicator(
      color: const Color(0xFF22D3EE),
      backgroundColor: const Color(0xFF141B2D),
      onRefresh: fetchAbilities,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: abilities.length,
          itemBuilder: (context, index) {
            final h = abilities[index];
            
            Color colorBorde;
            IconData iconoBase;

            if (h.damage > 0) {
              colorBorde = Colors.redAccent;
              iconoBase = Icons.local_fire_department_rounded;
            } else if (h.healAmount > 0) {
              colorBorde = const Color(0xFF34D399); // Verde
              iconoBase = Icons.favorite_rounded;
            } else if (h.targetsAllies) {
              colorBorde = const Color(0xFF22D3EE); // Cyan
              iconoBase = Icons.shield_rounded; 
            } else {
              colorBorde = const Color(0xFFC4B5FD); // Morado
              iconoBase = Icons.coronavirus_rounded;
            }
            
            bool isFirstOfOwner = index == 0 || h.ownerCharacter != abilities[index - 1].ownerCharacter;

            Widget cardContent = Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D).withOpacity(0.96),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colorBorde.withOpacity(0.24), width: 1.2),
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
                  onTap: () {
                    loadIntoForm(h);
                    if (MediaQuery.of(context).size.width <= 850) {
                      showModalBottomSheet(
                        context: context, 
                        isScrollControlled: true, 
                        backgroundColor: Colors.transparent,
                        builder: (_) => StatefulBuilder(
                          builder: (BuildContext context, StateSetter setModalState) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.92,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F172A), 
                                borderRadius: BorderRadius.vertical(top: Radius.circular(28))
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
                                  Expanded(
                                    child: buildForm(
                                      isDesktop: false,
                                      stateSetter: (fn) {
                                        setState(fn); 
                                        setModalState(fn);
                                      }
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        )
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58, 
                          height: 58,
                          decoration: BoxDecoration(
                            color: colorBorde.withOpacity(0.12), 
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: colorBorde.withOpacity(0.25))
                          ),
                          child: Icon(iconoBase, color: colorBorde, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.nombre.isEmpty ? 'Sin Nombre' : h.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(h.ownerCharacter.isEmpty ? 'Desconocido' : h.ownerCharacter, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (h.damage > 0) _buildTag('🗡️ ${h.damage}', Colors.redAccent),
                                  if (h.healAmount > 0) _buildTag('💚 ${h.healAmount}', const Color(0xFF34D399)),
                                  _buildTag('💧 ${h.manaCost}', const Color(0xFF22D3EE)),
                                  if (h.aplicaEstado && h.tipoEstado != 'None') 
                                    _buildTag('✨ ${h.tipoEstado}', const Color(0xFF8B5CF6)),
                                ],
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey), 
                          onPressed: () => confirmDelete(h.id, h.nombre)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            if (isFirstOfOwner) {
              cardContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12, left: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (h.ownerCharacter.isEmpty ? 'Desconocido' : h.ownerCharacter).toUpperCase(), 
                          style: const TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.white,
                            letterSpacing: 2.0
                          )
                        ),
                      ],
                    ),
                  ),
                  cardContent,
                ],
              );
            }

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 380),
              child: SlideAnimation(
                verticalOffset: 26.0,
                child: FadeInAnimation(
                  child: cardContent,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10), 
        borderRadius: BorderRadius.circular(999), 
        border: Border.all(color: color.withOpacity(0.24))
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }

  void confirmDelete(int id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Borrar Habilidad?', style: TextStyle(color: Colors.white)),
        content: Text('Estás a punto de borrar "${nombre.isEmpty ? 'Habilidad sin nombre' : nombre}".', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () { Navigator.pop(ctx); deleteAbility(id); },
            child: const Text('Borrar'),
          ),
        ],
      )
    );
  }

  // ==========================================
  // FORMULARIO ADAPTADO
  // ==========================================
  Widget buildForm({required bool isDesktop, required void Function(VoidCallback) stateSetter}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentId == 0 ? '✨ Nueva Habilidad' : '✏️ Editando #${currentId}', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)
                ),
              ),
              if (!isDesktop) 
                IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
              if (isDesktop && currentId != 0) 
                TextButton.icon(
                  icon: const Icon(Icons.clear, color: Colors.white54), 
                  label: const Text('Cancelar', style: TextStyle(color: Colors.white54)), 
                  onPressed: clearForm
                )
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              _buildSectionTitle('OBJETIVO DE LA HABILIDAD'),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141B2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06))
                ),
                child: SwitchListTile(
                  title: const Text('¿Aplica sobre Aliado?', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  subtitle: Text('Oculta mecánicas de rango y visuales', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  value: targetsAlliesVal, 
                  activeColor: const Color(0xFF34D399),
                  onChanged: (v) => stateSetter(() => targetsAlliesVal = v),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('INFORMACIÓN GENERAL'),
              TextField(controller: ownerCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Propietario', Icons.person_rounded)),
              const SizedBox(height: 14),
              TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Nombre Habilidad', Icons.auto_awesome_rounded)),
              const SizedBox(height: 14),
              TextField(controller: descripcionCtrl, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: _inputDec('Descripción', Icons.description_rounded)),
              
              const SizedBox(height: 24),
              _buildSectionTitle('ESTADÍSTICAS BÁSICAS'),
              Row(
                children: [
                  Expanded(child: TextField(controller: dmgCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Daño', Icons.local_fire_department_rounded), keyboardType: TextInputType.number)),
                  const SizedBox(width: 14),
                  Expanded(child: TextField(controller: healCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Curación', Icons.favorite_rounded), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 14),
              TextField(controller: manaCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Coste de Maná', Icons.water_drop_rounded), keyboardType: TextInputType.number),
              
              const SizedBox(height: 24),
              _buildSectionTitle('ESTADOS ALTERADOS'),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141B2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06))
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Aplica Estado Mágico', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      value: aplicaEstadoVal, 
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (v) => stateSetter(() => aplicaEstadoVal = v),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: !aplicaEstadoVal ? const SizedBox.shrink() : Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: tipoEstadoVal,
                              dropdownColor: const Color(0xFF141B2D),
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: _inputDec('Tipo de Estado', Icons.bubble_chart_rounded),
                              items: statesList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) => stateSetter(() => tipoEstadoVal = v!),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: TextField(controller: duracionEstadoCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Turnos', Icons.timelapse_rounded), keyboardType: TextInputType.number)),
                                const SizedBox(width: 14),
                                Expanded(child: TextField(controller: potenciaEstadoCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Intensidad', Icons.flash_on_rounded), keyboardType: TextInputType.number)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

               const SizedBox(height: 24),
                _buildSectionTitle('VISUALES (UNITY)'),
                TextField(controller: prefabCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Prefab Path', Icons.folder_rounded)),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141B2D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06))
                  ),
                  child: SwitchListTile(
                    title: const Text('Instanciar por Casilla', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                    value: prefabCasillaVal,
                    activeColor: const Color(0xFF22D3EE),
                    onChanged: (v) => stateSetter(() => prefabCasillaVal = v),
                  ),
                ),        

              if (!targetsAlliesVal) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('MECÁNICAS Y ÁREA'),
                TextField(controller: rangeCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Rango', Icons.straighten_rounded), keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: shapeVal,
                  dropdownColor: const Color(0xFF141B2D),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputDec('Forma de Ataque', Icons.grid_on_rounded),
                  items: shapes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => stateSetter(() => shapeVal = v!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: tipoMovVal,
                  dropdownColor: const Color(0xFF141B2D),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputDec('Tipo de Movimiento', Icons.moving_rounded),
                  items: movTipos.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => stateSetter(() => tipoMovVal = v!),
                ),               

                const SizedBox(height: 14),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141B2D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06))
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      collapsedIconColor: const Color(0xFF22D3EE),
                      iconColor: const Color(0xFF22D3EE),
                      title: const Text('⚙️ CONFIGURACIÓN AVANZADA', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22D3EE), fontSize: 12, letterSpacing: 1.2)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Move Offset (X / Y)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: TextField(controller: moveXCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('X', Icons.compare_arrows_rounded), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 10),
                                  Expanded(child: TextField(controller: moveYCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Y', Icons.swap_vert_rounded), keyboardType: TextInputType.number)),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Text('Spawn Offset Visual (X / Y / Z)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: TextField(controller: spawnXCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('X', Icons.threed_rotation_rounded), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                                  const SizedBox(width: 10),
                                  Expanded(child: TextField(controller: spawnYCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Y', Icons.threed_rotation_rounded), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                                  const SizedBox(width: 10),
                                  Expanded(child: TextField(controller: spawnZCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Z', Icons.threed_rotation_rounded), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                                ],
                              ),
                              const SizedBox(height: 15),
                              TextField(controller: delayCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Delay entre casillas (Seg)', Icons.hourglass_bottom_rounded), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                              const SizedBox(height: 15),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Animación Secuencial', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                subtitle: Text('Casillas detonan una tras otra.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                value: secuencialVal,
                                activeColor: const Color(0xFF34D399),
                                onChanged: (v) => stateSetter(() => secuencialVal = v),
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Es Unitarget', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                subtitle: Text('Afecta solo a la casilla central.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                value: unitargetVal,
                                activeColor: const Color(0xFF34D399),
                                onChanged: (v) => stateSetter(() => unitargetVal = v),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141B2D),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, -6))
            ]
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF22D3EE), Color(0xFF0284C7)],
                ),
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  currentId == 0 ? "CREAR HABILIDAD" : "GUARDAR CAMBIOS", 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.1)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                onPressed: saveAbility,
              ),
            ),
          )
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
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
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF22D3EE),
          width: 1.5,
        ),
      ),
    );
  }
}