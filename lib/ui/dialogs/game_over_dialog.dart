import 'package:flutter/material.dart';
import '../../game/catch_game.dart';
import '../../models/profile.dart';

/// Diálogo modal que se muestra al perder la partida
class GameOverDialog extends StatelessWidget {
  final CatchGame game;
  final Profile profile;
  final int score;
  final bool isRecord;
  final VoidCallback onRestart;

  const GameOverDialog({
    super.key,
    required this.game,
    required this.profile,
    required this.score,
    required this.isRecord,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    // PopScope bloquea el gesto de retroceso o botón "Atrás" de Android para obligar a interactuar con los botones
    return PopScope(
      canPop: false, // evita cerrarlo con el botón "atrás"
      child: AlertDialog(
        title: const Text('¡Game over! 😢'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PUNTOS',
              style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold),
            ),
            // Anima el conteo numérico de los puntos desde 0 hasta la puntuación final alcanzada
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: score),
              duration: const Duration(milliseconds: 900),
              builder: (_, v, _) => Text(
                '$v',
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            // Muestra un distintivo destacado si superó el récord anterior o el récord actual en caso contrario
            if (isRecord)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 20, color: Colors.black87),
                    SizedBox(width: 6),
                    Text(
                      '¡NUEVO RÉCORD!',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 20),
                  const SizedBox(width: 6),
                  Text('Récord: ${profile.best}', style: const TextStyle(fontSize: 16)),
                ],
              ),
          ],
        ),
        actions: [
          // Opción condicional: permite revivir si el jugador tiene suficiente saldo de diamantes
          if (profile.diamonds >= 5)
            TextButton(
              onPressed: () {
                if (profile.spend(5)) {
                  Navigator.pop(context);
                  game.revive();
                }
              },
              child: const Text('❤️ Revivir (5 💎)'),
            ),
          // Botón principal para reiniciar la partida desde cero
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onRestart();
            },
            child: const Text('Jugar otra vez'),
          ),
        ],
      ),
    );
  }
}