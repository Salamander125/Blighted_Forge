import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// ==========================================
// 1. MODELO DE DATOS Y LORE DE EFECTOS
// ==========================================
class EffectInfo {
  final String name;
  final String category;
  final String lore;
  final Color auraColor;

  EffectInfo({
    required this.name,
    required this.category,
    required this.lore,
    required this.auraColor,
  });

  String get imagePath => 'assets/effects/$name.png';
}

final List<EffectInfo> yarniaEffects = [
  // --- DAÑO CONTINUO ---
  EffectInfo(name: "Veneno", category: "Daño Continuo", auraColor: const Color(0xFF8B5CF6), lore: "El mana corrompido pudre la sangre desde adentro. Causa daño directo y constante al inicio de cada turno."),
  EffectInfo(name: "Radiacion", category: "Daño Continuo", auraColor: const Color(0xFF34D399), lore: "Una energía antinatural y nociva que quema lentamente. Además de causar daño continuo, corroe permanentemente la estructura del objetivo, reduciendo su Defensa base con el tiempo."),
  EffectInfo(name: "Quemadura", category: "Daño Continuo", auraColor: const Color(0xFFF97316), lore: "Fuego inestable nacido de las anomalías de Yarnia. Consume al objetivo sin piedad, infligiendo daño constante cada turno."),
  EffectInfo(name: "Hemorragia", category: "Daño Continuo", auraColor: const Color(0xFFEF4444), lore: "Heridas abiertas que la niebla del abismo impide sanar. Causa daño continuo y es extremadamente letal a largo plazo, ya que la pérdida de vitalidad empeora cada vez más si no es tratada."),
  
  // --- REGENERACIÓN ---
  EffectInfo(name: "Vitalidad", category: "Regeneración", auraColor: const Color(0xFF10B981), lore: "El mana del entorno es canalizado para tejer la carne y cerrar heridas. Restaura puntos de Vida gradualmente al inicio de cada turno."),
  EffectInfo(name: "Lucidez", category: "Regeneración", auraColor: const Color(0xFF3B82F6), lore: "Un estado de claridad mental que rechaza la corrupción del entorno. Regenera la reserva de Maná con cada instante que pasa, disipando la bruma mental."),
  
  // --- MEJORAS (BUFFS) ---
  EffectInfo(name: "Prisa", category: "Bendiciones", auraColor: const Color.fromARGB(255, 244, 251, 36), lore: "El flujo del tiempo parece alterarse alrededor del individuo. Aumenta drásticamente la Velocidad de movimiento y otorga un ligero incremento a los reflejos (Evasión)."),
  EffectInfo(name: "Certeza", category: "Bendiciones", auraColor: const Color.fromARGB(255, 168, 114, 156), lore: "Los sentidos se agudizan hasta rozar la clarividencia. Aumenta significativamente la probabilidad de asestar impactos críticos letales."),
  EffectInfo(name: "Coraza", category: "Bendiciones", auraColor: const Color(0xFF9CA3AF), lore: "El mana se solidifica creando una densa capa protectora. Aumenta la Defensa general del objetivo contra los ataques físicos y mágicos."),
  EffectInfo(name: "Furia", category: "Bendiciones", auraColor: const Color(0xFFDC2626), lore: "Un estado de frenesí ciego e instinto asesino. Aumenta el Ataque de forma abrumadora, pero vuelve al atacante temerario y descuidado, reduciendo su Defensa a la mitad."),
  EffectInfo(name: "Espejismo", category: "Bendiciones", auraColor: const Color(0xFF06B6D4), lore: "La luz y el mana se curvan, creando una ilusión. Vuelve al usuario momentáneamente intocable, permitiéndole esquivar el próximo impacto con total seguridad antes de desvanecerse."),
  EffectInfo(name: "Sifon", category: "Bendiciones", auraColor: const Color.fromARGB(255, 123, 162, 125), lore: "Un vínculo parasitario forjado con magia antigua. El atacante devora la esencia vital de su enemigo, curándose a sí mismo en proporción al daño real que logra infligir con sus golpes."),
  EffectInfo(name: "Baluarte", category: "Bendiciones", auraColor: const Color.fromARGB(255, 157, 129, 165), lore: "Una barrera absoluta de cristal puro. Bloquea por completo el próximo ataque recibido, absorbiendo todo el impacto antes de hacerse añicos."),

  // --- PENALIZACIONES (DEBUFFS) ---
  EffectInfo(name: "Fractura", category: "Maldiciones", auraColor: const Color.fromARGB(255, 165, 184, 148), lore: "Las protecciones son quebradas por el peso de la corrupción. Reduce severamente la Defensa, dejando al objetivo expuesto a sufrir heridas mucho más graves."),
  EffectInfo(name: "Pesadez", category: "Maldiciones", auraColor: const Color.fromARGB(255, 200, 199, 199), lore: "Una fuerza gravitacional opresiva paraliza los músculos. Reduce drásticamente la Velocidad y la capacidad de Evasión del afectado, volviéndolo un blanco lento y predecible."),
  EffectInfo(name: "Ceguera", category: "Maldiciones", auraColor: const Color.fromARGB(255, 255, 255, 255), lore: "La oscuridad o el brillo extremo del cristal nublan la visión. Disminuye severamente la capacidad del objetivo para encontrar puntos débiles y asestar golpes certeros (Críticos)."),
  EffectInfo(name: "Fragilidad", category: "Maldiciones", auraColor: const Color.fromARGB(255, 181, 162, 122), lore: "La esencia del afectado se vuelve tan frágil como el cristal agrietado. El próximo ataque que reciba será un Golpe Crítico garantizado, haciendo trizas la maldición tras el impacto."),
  EffectInfo(name: "Fatiga", category: "Maldiciones", auraColor: const Color.fromARGB(255, 125, 86, 167), lore: "El ambiente de Yarnia y el cansancio extremo drenan la voluntad. Invocar cualquier poder requiere un esfuerzo agónico, haciendo que todas las habilidades cuesten un 30% más de Maná mientras dure."),
  EffectInfo(name: "Silencio", category: "Maldiciones", auraColor: const Color.fromARGB(255, 149, 83, 154), lore: "Un vacío antinatural que ahoga la voz y desconecta el flujo de energía. Impide por completo el uso de cualquier habilidad mágica o técnica, obligando a depender solo de ataques básicos."),

  // --- CONTROL DE MASAS ---
  EffectInfo(name: "Sueno", category: "Control de Masas", auraColor: const Color(0xFF818CF8), lore: "Una pesadilla inducida por los ecos olvidados de Yarnia. El objetivo cae en un trance profundo, saltándose su turno y quedando indefenso hasta que el dolor de un ataque lo despierte de golpe."),
  EffectInfo(name: "Escarcha", category: "Control de Masas", auraColor: const Color(0xFF7DD3FC), lore: "Cristales de hielo corrupto recubren y paralizan al objetivo. Al recibir el siguiente impacto físico, el hielo estalla en pedazos, infligiendo un estallido de daño extra devastador."),
];

// ==========================================
// 2. PANTALLA PRINCIPAL (DICCIONARIO DE EFECTOS)
// ==========================================
class EffectsScreen extends StatelessWidget {
  const EffectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Agrupamos los efectos por categoría para dibujarlos en secciones
    final Map<String, List<EffectInfo>> groupedEffects = {};
    for (var effect in yarniaEffects) {
      if (!groupedEffects.containsKey(effect.category)) {
        groupedEffects[effect.category] = [];
      }
      groupedEffects[effect.category]!.add(effect);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090E1A),
        elevation: 0,
        title: Text(
          "Anomalías del Mana",
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Diseño responsivo tipo Dossier
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: groupedEffects.entries.map((entry) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // El índice 0 es el título de la categoría
                      if (index == 0) {
                        return _CategoryHeader(title: entry.key);
                      }
                      // Los siguientes son las tarjetas
                      final effect = entry.value[index - 1];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 20,
                          child: FadeInAnimation(
                            child: _EffectCard(effect: effect),
                          ),
                        ),
                      );
                    },
                    childCount: entry.value.length + 1, // +1 por el header
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. WIDGETS DE UI
// ==========================================
class _CategoryHeader extends StatelessWidget {
  final String title;

  const _CategoryHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF34D399),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectCard extends StatelessWidget {
  final EffectInfo effect;

  const _EffectCard({required this.effect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono con Aura (Glow effect)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF090E1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: effect.auraColor.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: effect.auraColor.withOpacity(0.25),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                effect.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.auto_awesome,
                  color: effect.auraColor.withOpacity(0.5),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effect.name,
                  style: TextStyle(
                    color: effect.auraColor, // El nombre toma el color de su aura
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  effect.lore,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1), // Color gris azulado para lectura cómoda
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}