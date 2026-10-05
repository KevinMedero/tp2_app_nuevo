import 'package:flutter/material.dart';
import '../../game/catch_game.dart';
import '../../models/profile.dart';

/// Encabezado superior de la interfaz que muestra datos del usuario, puntajes y accesos rápidos
class HeaderWidget extends StatelessWidget {
  final Profile profile;
  final CatchGame game;
  final VoidCallback onOpenShop;

  const HeaderWidget({
    super.key,
    required this.profile,
    required this.game,
    required this.onOpenShop,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // ListenableBuilder escucha cambios en el Profile (tema, diamantes, estado PRO) para redibujarse automáticamente
    return ListenableBuilder(
      listenable: profile,
      builder: (_, _) => Card(
        color: cs.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            // Fila superior: Avatar, nombre, insignia de cuenta y botones de acción
            Row(children: [
              const CircleAvatar(child: Text('🦊')),
              const SizedBox(width: 8),
              Text(profile.user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              // Indicador visual según el tipo de suscripción (PRO o BASIC)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(profile.pro ? '👑 PRO' : 'BASIC'),
              ),
              const Spacer(),
              // Alternador de tema (modo claro / modo oscuro)
              IconButton(
                tooltip: 'Modo claro/oscuro',
                icon: Icon(profile.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: profile.toggleDark,
              ),
              // Botón de acceso directo a la tienda
              IconButton(
                tooltip: 'Tienda',
                icon: const Icon(Icons.storefront),
                onPressed: onOpenShop,
              ),
            ]),
            // Fila inferior: Indicadores reactivos del juego (puntos, récord, vidas, diamantes)
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              // Puntaje en tiempo real de la partida actual
              ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (_, s, _) => Text('⭐ $s', style: const TextStyle(fontSize: 18)),
              ),
              // Máximo récord histórico alcanzado (usando ícono vectorial dorado)
              //Text('🏆 ${profile.best}', style: const TextStyle(fontSize: 18)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                  const SizedBox(width: 4),
                  Text('${profile.best}', style: const TextStyle(fontSize: 18)),
                ],
              ),
              // Vidas restantes en la partida actual
              ValueListenableBuilder<int>(
                valueListenable: game.lives,
                builder: (_, l, _) =>
                    Text('❤️' * l.clamp(0, 3), style: const TextStyle(fontSize: 18)),
              ),
              // Saldo total de diamantes del jugador
              Text('💎 ${profile.diamonds}', style: const TextStyle(fontSize: 18)),
            ]),
          ]),
        ),
      ),
    );
  }
}