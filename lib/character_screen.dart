import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. MODELO DE DATOS DE HABILIDAD (Replicado de tu API)
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

  Ability({
    required this.id, required this.ownerCharacter, required this.nombre, required this.descripcion,
    required this.damage, required this.healAmount, required this.manaCost,
    required this.shape, required this.range, required this.targetsAllies,
    required this.aplicaEstado, required this.tipoEstado, required this.duracionEstado,
    required this.potenciaEstado,
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
    );
  }
}

// ==========================================
// 2. MODELO DE DATOS DEL PERSONAJE Y LORE
// ==========================================
class CharacterInfo {
  final String name;
  final String dbName; // El nombre exacto que usas en la base de datos (sin tildes)
  final String origin;
  final String lore;
  final String imagePath;
  final int hp;
  final int mp;
  final int atk;
  final int spd;
  final String def;
  final String crit;
  final String eva;

  CharacterInfo({
    required this.name, required this.dbName, required this.origin, required this.lore,
    required this.imagePath, required this.hp, required this.mp, required this.atk,
    required this.spd, required this.def, required this.crit, required this.eva,
  });
}

final List<CharacterInfo> yarniaRoster = [
  CharacterInfo(
    name: "Alan Gomez", dbName: "Alan", origin: "Tercer Continente", imagePath: "assets/characters/Alan.png",
    lore: "Ex-soldado en múltiples conflictos que terminaron arrebatándole cualquier propósito. Vagó sin rumbo hasta que Mérida le habló de Yarnia. Al entrar, el mana reaccionó con su lanza de mercurio, permitiéndole envenenar enemigos. Es frío, reservado, y en el fondo, espera encontrar una razón para volver a sentirse vivo.",
    hp: 140, mp: 70, atk: 25, spd: 80, def: "10%", crit: "10%", eva: "15%",
  ),
  CharacterInfo(
    name: "Mérida Garcia", dbName: "Merida", origin: "Tercer Continente", imagePath: "assets/characters/Merida.png",
    lore: "Historiadora y exploradora obsesionada con la Blighted Property. Decidió liderar la expedición a Yarnia, pero cuanto más descubre, más parece ocultar sus intenciones. El mana le dio una sensibilidad anormal a las corrientes mágicas. Busca desesperadamente llenar un vacío que lleva años ocultando.",
    hp: 80, mp: 120, atk: 35, spd: 90, def: "5%", crit: "10%", eva: "20%",
  ),
  CharacterInfo(
    name: "Luka Smith", dbName: "Luka", origin: "Primer Continente", imagePath: "assets/characters/Luka.png",
    lore: "Ex-espía y asesino. Descubrió secretos tan peligrosos sobre Yarnia que su propia nación intentó silenciarlo. El mana alteró sus reflejos hasta niveles sobrehumanos, convirtiéndolo en un depredador. Busca respuestas sobre los secretos que arruinaron su vida.",
    hp: 70, mp: 80, atk: 50, spd: 130, def: "5%", crit: "30%", eva: "30%",
  ),
  CharacterInfo(
    name: "Chloe Petit", dbName: "Chloe", origin: "Tercer Continente", imagePath: "assets/characters/Chloe.png",
    lore: "Artista obsesionada con capturar 'la imagen perfecta'. Las leyendas de Yarnia la atrajeron, y el mana comenzó a influir en sus obras, permitiéndole manipular percepciones ajenas mediante ilusiones. Busca en Yarnia aquello que complete su obra maestra inalcanzable.",
    hp: 85, mp: 150, atk: 30, spd: 100, def: "5%", crit: "5%", eva: "15%",
  ),
  CharacterInfo(
    name: "Sofia Jones", dbName: "Sofia", origin: "Cuarto Continente", imagePath: "assets/characters/Sofia.png",
    lore: "Joven músico callejera que tocaba su flauta en puertos marítimos. Impulsada por la curiosidad, entró a Yarnia y descubrió que su música, alterada por el mana, podía sanar y alterar emociones. Teme que las voces del mana terminen consumiendo su mente.",
    hp: 70, mp: 160, atk: 15, spd: 80, def: "10%", crit: "5%", eva: "5%",
  ),
  CharacterInfo(
    name: "Rodrigo Gonzalez", dbName: "Rodrigo", origin: "Quinto Continente", imagePath: "assets/characters/Rodrigo.png",
    lore: "Cazarrecompensas crecido entre violencia y apuestas. Su precisión con el revólver es letal. En Yarnia, el mana se fusionó con sus armas y balas, permitiéndole realizar disparos imposibles. Está obsesionado con descubrir el verdadero poder del fruto prohibido.",
    hp: 70, mp: 90, atk: 70, spd: 70, def: "10%", crit: "30%", eva: "15%",
  ),
  CharacterInfo(
    name: "Kayla Ivanov", dbName: "Kayla", origin: "Primer Continente (Regiones Orientales)", imagePath: "assets/characters/Kayla.png",
    lore: "Agente entrenada en espionaje y combate dual. Viajó a Yarnia tras descubrir información clasificada. El mana alteró su percepción del tiempo, permitiéndole moverse a velocidades absurdas. Teme que este poder termine transformándola en algo irreconocible.",
    hp: 50, mp: 70, atk: 50, spd: 150, def: "0%", crit: "25%", eva: "40%",
  ),
  CharacterInfo(
    name: "Sukehiro Masuhara", dbName: "Sukehiro", origin: "Primer Continente", imagePath: "assets/characters/Sukehiro.png",
    lore: "Espadachín de familia de forjadores de katanas. Tras el asesinato de su familia por la Yakuza, viaja a Yarnia buscando un deseo. Sobrevivió a una tormenta de mana que hizo que su cuerpo libere fuego y electricidad. Intenta descubrir qué despertó en él antes de perder el control.",
    hp: 100, mp: 100, atk: 35, spd: 100, def: "10%", crit: "20%", eva: "20%",
  ),
];

// ==========================================
// 3. PANTALLA PRINCIPAL DE PERSONAJES
// ==========================================
class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090E1A),
        elevation: 0,
        title: Text(
          "Expedición a Yarnia",
          style: GoogleFonts.pressStart2p(
            fontSize: 13,
            color: const Color(0xFF34D399), // Verde coraje para los humanos
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850), // Diseño ancho tipo Dossier
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: yarniaRoster.length,
              itemBuilder: (context, index) {
                final character = yarniaRoster[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _CharacterDossierCard(character: character),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterDossierCard extends StatelessWidget {
  final CharacterInfo character;

  const _CharacterDossierCard({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CharacterDetailScreen(character: character)),
            );
          },
          child: Stack(
            children: [
              // Imagen alineada a la derecha con un gradiente que la funde con el fondo negro
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 200,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                  child: Hero(
                    tag: 'char_img_${character.name}',
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.transparent, Colors.black],
                          stops: [0.0, 0.4],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        character.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0F172A)),
                      ),
                    ),
                  ),
                ),
              ),
              // Información del personaje a la izquierda
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      character.name.toUpperCase(),
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.5)),
                      ),
                      child: Text(
                        character.origin,
                        style: const TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _MiniStat(icon: Icons.favorite, value: character.hp.toString(), color: Colors.greenAccent),
                        const SizedBox(width: 12),
                        _MiniStat(icon: Icons.sports_martial_arts, value: character.atk.toString(), color: Colors.redAccent),
                        const SizedBox(width: 12),
                        _MiniStat(icon: Icons.speed, value: character.spd.toString(), color: Colors.amberAccent),
                      ],
                    )
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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

// ==========================================
// 4. PANTALLA DE DETALLE Y CONSULTA DE API
// ==========================================
class CharacterDetailScreen extends StatefulWidget {
  final CharacterInfo character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  List<Ability> characterAbilities = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCharacterAbilities();
  }

  Future<void> _fetchCharacterAbilities() async {
    try {
      final response = await http.get(Uri.parse('http://blightedproperty.somee.com/api/abilities'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Filtramos las habilidades asegurándonos de coincidir con el nombre de DB del personaje
        final allAbilities = data.map((json) => Ability.fromJson(json)).toList();
        final filtered = allAbilities.where((a) => 
          a.ownerCharacter.toLowerCase().trim() == widget.character.dbName.toLowerCase().trim()
        ).toList();

        setState(() {
          characterAbilities = filtered;
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; hasError = true; });
      }
    } catch (e) {
      setState(() { isLoading = false; hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Ancho máximo para PC
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'char_img_${widget.character.name}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.character.imagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0F172A)),
                        ),
                        // Gradiente muy oscuro abajo para que los textos sean legibles
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, const Color(0xFF090E1A).withOpacity(0.8), const Color(0xFF090E1A)],
                              stops: const [0.5, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.character.name,
                        style: GoogleFonts.merriweather(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Procedencia: ${widget.character.origin}",
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle("LA CORRUPCIÓN DEL MANA"),
                      Text(
                        widget.character.lore,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 16,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      _buildSectionTitle("ESTADÍSTICAS DEL ALMA"),
                      _buildStatsGrid(widget.character),
                      
                      const SizedBox(height: 40),
                      _buildSectionTitle("PODERES DESPERTADOS"),
                      _buildAbilitiesSection(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: const Color(0xFF34D399)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesSection() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(color: Color(0xFF34D399)),
        ),
      );
    }
    
    if (hasError) {
      return const Center(
        child: Text("Las distorsiones de Yarnia impiden leer sus poderes.", style: TextStyle(color: Colors.redAccent)),
      );
    }

    if (characterAbilities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF141B2D), borderRadius: BorderRadius.circular(16)),
        child: const Text("Este expedicionario aún no ha despertado sus habilidades o el mana no ha sido registrado.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: characterAbilities.length,
        itemBuilder: (context, index) {
          final ability = characterAbilities[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 20.0,
              child: FadeInAnimation(
                child: _AbilityCard(ability: ability),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(CharacterInfo char) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatValue("Vida", char.hp.toString(), Icons.favorite, Colors.greenAccent)),
              Expanded(child: _StatValue("Maná", char.mp.toString(), Icons.water_drop, Colors.blueAccent)),
              Expanded(child: _StatValue("Vel", char.spd.toString(), Icons.speed, Colors.amberAccent)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatValue("Atk", char.atk.toString(), Icons.sports_martial_arts, Colors.redAccent)),
              Expanded(child: _StatValue("Def", char.def, Icons.shield, Colors.grey)),
              Expanded(child: _StatValue("Crit", char.crit, Icons.flash_on, Colors.purpleAccent)),
              Expanded(child: _StatValue("Eva", char.eva, Icons.air, Colors.cyanAccent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatValue(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AbilityCard extends StatelessWidget {
  final Ability ability;

  const _AbilityCard({required this.ability});

  @override
  Widget build(BuildContext context) {
    final bool isHeal = ability.healAmount > 0;
    final bool isSupport = ability.targetsAllies && !isHeal;
    final Color mainColor = isHeal ? const Color(0xFF34D399) : (isSupport ? const Color(0xFF22D3EE) : Colors.redAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1525),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainColor.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ability.nombre,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, size: 14, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Text(ability.manaCost.toString(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ability.descripcion,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ability.damage > 0) _buildTag('Daño: ${ability.damage}', Colors.redAccent, Icons.local_fire_department),
              if (ability.healAmount > 0) _buildTag('Cura: ${ability.healAmount}', const Color(0xFF34D399), Icons.favorite),
              if (!ability.targetsAllies) _buildTag('Rango: ${ability.range}', Colors.amberAccent, Icons.straighten),
              if (!ability.targetsAllies) _buildTag('Forma: ${ability.shape}', Colors.white70, Icons.grid_on),
              if (ability.aplicaEstado && ability.tipoEstado != 'None') 
                _buildTag('${ability.tipoEstado} (${ability.duracionEstado}T)', const Color(0xFFC4B5FD), Icons.coronavirus),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}