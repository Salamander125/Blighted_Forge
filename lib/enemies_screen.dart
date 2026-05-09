import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. MODELO DE DATOS Y BESTIARIO
// ==========================================
class EnemyInfo {
  final String name;
  final String lore;
  final String biome;
  final String imagePath;
  final int hp;
  final int mp;
  final int atk;
  final int spd;
  final String def;
  final String crit;
  final String eva;

  EnemyInfo({
    required this.name,
    required this.lore,
    required this.biome,
    required this.imagePath,
    required this.hp,
    required this.mp,
    required this.atk,
    required this.spd,
    required this.def,
    required this.crit,
    required this.eva,
  });
}

final List<EnemyInfo> yarniaBestiary = [
  EnemyInfo(
    name: "Radaz",
    biome: "Dunas Doradas",
    imagePath: "assets/enemies/Radaz.png", // Reemplaza con tu ruta
    lore: "Las Radaz son criaturas que permanecen enterradas bajo las Dunas Doradas durante días enteros, esperando sentir vibraciones sobre la arena antes de atacar. Se cree que originalmente eran simples escorpiones del desierto, pero el mana de Yarnia deformó sus cuerpos hasta convertirlos en depredadores monstruosos cubiertos por un caparazón casi imposible de atravesar. Su veneno no solo destruye el cuerpo, también altera lentamente la mente, provocando alucinaciones y paranoia en quienes sobreviven a sus ataques.",
    hp: 75, mp: 0, atk: 20, spd: 60, def: "25%", crit: "10%", eva: "5%",
  ),
  EnemyInfo(
    name: "Velocipastor",
    biome: "Dunas Doradas",
    imagePath: "assets/enemies/Velocipastor.png",
    lore: "Los Velocipastor recorren las Dunas Doradas en manadas pequeñas, moviéndose entre tormentas de arena y oasis abandonados. A diferencia de otras criaturas de Yarnia, poseen una inteligencia anormal y son capaces de rodear presas antes de atacar coordinadamente. El mana de Yarnia fortaleció sus músculos y sentidos, permitiéndoles detectar movimiento incluso bajo la arena.",
    hp: 40, mp: 0, atk: 35, spd: 130, def: "0%", crit: "15%", eva: "25%",
  ),
  EnemyInfo(
    name: "Espíritu Desértico",
    biome: "Dunas Doradas",
    imagePath: "assets/enemies/Espiritu Desertico.png",
    lore: "Antiguos exploradores que perdieron la cordura vagando por las Dunas Doradas. Incapaces de abandonar Yarnia incluso después de la muerte, terminaron fusionándose con el mana del desierto hasta convertirse en entidades vacías y silenciosas. Deambulan cerca de ruinas intentando advertir a los viajeros antes de atacarlos inevitablemente, consumidos por el mana.",
    hp: 120, mp: 0, atk: 25, spd: 90, def: "20%", crit: "5%", eva: "15%",
  ),
  EnemyInfo(
    name: "Pochink Desértico",
    biome: "Dunas Doradas",
    imagePath: "assets/enemies/Pochink Desertico.png",
    lore: "Estas extrañas entidades con forma de bulbo parecen ser una manifestación física del mana del desierto protegiendo un núcleo de cristal puro. Se desplazan rodando o flotando a ras de suelo. Actúan como 'señuelos' en las dunas; su brillo atrae a los sedientos, quienes descubren demasiado tarde que la criatura drena su humedad.",
    hp: 60, mp: 0, atk: 15, spd: 50, def: "50%", crit: "5%", eva: "5%",
  ),
  EnemyInfo(
    name: "Exzatyl",
    biome: "Cuevas Cristalinas",
    imagePath: "assets/enemies/Exzatyl.png",
    lore: "Pequeños pero extremadamente resistentes, estos seres han reemplazado su pelaje por una coraza de cristales púrpuras y azulados. Se esconden bajo el suelo de las cuevas, simulando ser simples formaciones geológicas hasta que una presa camina sobre ellos. Son el principal peligro para los pies de los expedicionarios.",
    hp: 65, mp: 0, atk: 30, spd: 90, def: "50%", crit: "20%", eva: "5%",
  ),
  EnemyInfo(
    name: "Arkano del Prisma",
    biome: "Cuevas Cristalinas",
    imagePath: "assets/enemies/Arkano del Prisma.png",
    lore: "El destino final de los expedicionarios que sucumbieron totalmente a las Cuevas Cristalinas. Sus cuerpos han sido revestidos por túnicas de mana sólido y sus brazos se han transformado en lanzas de cristal puro. Actúan como los líderes de las hordas de servidores, coordinando ataques con magia de corto alcance.",
    hp: 130, mp: 0, atk: 35, spd: 90, def: "15%", crit: "5%", eva: "20%",
  ),
  EnemyInfo(
    name: "Monrocks",
    biome: "Cuevas Cristalinas",
    imagePath: "assets/enemies/Monrocks.png",
    lore: "Antiguos primates que buscaron refugio en las cuevas y fueron consumidos por el mana. Los cristales han brotado directamente de su columna vertebral, sumiéndolos en un estado de dolor y furia constante. Funcionan como los guardianes territoriales de los túneles más amplios.",
    hp: 80, mp: 0, atk: 40, spd: 0, def: "40%", crit: "5%", eva: "0%",
  ),
  EnemyInfo(
    name: "Verminita Esmeralda",
    biome: "Cuevas Cristalinas",
    imagePath: "assets/enemies/Verminita Esmeralda.png",
    lore: "Criaturas que se arrastran por las paredes de las cuevas, filtrando el mana del aire a través de sus placas de cristal verde. Son los responsables de excavar los túneles, dejando un rastro de energía corrosiva. No poseen ojos y detectan las vibraciones de la sangre humana.",
    hp: 45, mp: 0, atk: 20, spd: 120, def: "15%", crit: "10%", eva: "15%",
  ),
];

// ==========================================
// 2. PANTALLA PRINCIPAL (GRID)
// ==========================================
class EnemiesScreen extends StatelessWidget {
  const EnemiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090E1A),
        elevation: 0,
        title: Text(
          "Bestiario de Yarnia",
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: const Color(0xFFC4B5FD),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF090E1A), Color(0xFF141B2D)],
          ),
        ),
        // 1. Centramos y limitamos el ancho máximo para PC
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                // 2. Las tarjetas no se estirarán al infinito, se adaptarán creando más columnas
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260, // Ancho máximo por tarjeta
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: yarniaBestiary.length,
                itemBuilder: (context, index) {
                  final enemy = yarniaBestiary[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: _EnemyCard(enemy: enemy),
                      ),
                    ),
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

class _EnemyCard extends StatelessWidget {
  final EnemyInfo enemy;

  const _EnemyCard({required this.enemy});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => EnemyDetailScreen(enemy: enemy),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1E293B).withOpacity(0.8),
          border: Border.all(color: const Color(0xFF334155)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'enemy_img_${enemy.name}',
                child: Image.asset(
                  enemy.imagePath,
                  fit: BoxFit.cover, // En la tarjeta pequeña sigue siendo cover para llenar el espacio
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF0F172A),
                    child: const Icon(Icons.pest_control, size: 50, color: Colors.white24),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enemy.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enemy.biome,
                      style: TextStyle(
                        color: const Color(0xFF22D3EE).withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

// ==========================================
// 3. PANTALLA DE DETALLE (WIKI LORE) - RESPONSIVA
// ==========================================
class EnemyDetailScreen extends StatelessWidget {
  final EnemyInfo enemy;

  const EnemyDetailScreen({super.key, required this.enemy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      // 3. Centramos toda la vista de detalle
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Ancho máximo tipo modal en PC
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400, // Un poco más alto para acomodar imágenes cuadradas
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'enemy_img_${enemy.name}',
                    child: Container(
                      color: const Color(0xFF090E1A), // Fondo oscuro detrás de la imagen
                      child: Image.asset(
                        enemy.imagePath,
                        fit: BoxFit.contain, // 4. "contain" asegura que la imagen cuadrada no se corte NUNCA
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF0F172A),
                          child: const Icon(Icons.image_not_supported, size: 80, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF090E1A),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              enemy.name,
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                            ),
                            child: Text(
                              enemy.biome,
                              style: const TextStyle(
                                color: Color(0xFFC4B5FD),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Registros de Expedición",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        enemy.lore,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 15,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        "Atributos de Combate",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsGrid(),
                      const SizedBox(height: 40),
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

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatBadge(label: "Vida", value: enemy.hp.toString(), icon: Icons.favorite, color: Colors.greenAccent)),
              const SizedBox(width: 12),
              Expanded(child: _StatBadge(label: "Mana", value: enemy.mp.toString(), icon: Icons.water_drop, color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatBadge(label: "Ataque", value: enemy.atk.toString(), icon: Icons.sports_martial_arts, color: Colors.redAccent)),
              const SizedBox(width: 12),
              Expanded(child: _StatBadge(label: "Velocidad", value: enemy.spd.toString(), icon: Icons.speed, color: Colors.amberAccent)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatBadge(label: "Defensa", value: enemy.def, icon: Icons.shield, color: Colors.grey)),
              const SizedBox(width: 12),
              Expanded(child: _StatBadge(label: "Crítico", value: enemy.crit, icon: Icons.flash_on, color: Colors.purpleAccent)),
              const SizedBox(width: 12),
              Expanded(child: _StatBadge(label: "Evasión", value: enemy.eva, icon: Icons.air, color: Colors.cyanAccent)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1525),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}