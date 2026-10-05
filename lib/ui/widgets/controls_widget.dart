import 'package:flutter/material.dart';
import '../../game/catch_game.dart';

/// Barra de controles inferiores para manejar el flujo del juego (Inicio, Pausa, Reiniciar, Nueva Partida)
class ControlsWidget extends StatelessWidget {
  final CatchGame game;
  final VoidCallback onRestart;

  const ControlsWidget({
    super.key,
    required this.game,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    // Escucha activamente el estado del juego (idle, playing, paused, over) para habilitar o deshabilitar botones
    return ValueListenableBuilder<GameStatus>(
      valueListenable: game.status,
      builder: (_, st, _) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // Botón para arrancar el juego por primera vez (solo activo en estado IDLE)
          FilledButton.icon(
            onPressed: st == GameStatus.idle ? game.start : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('INICIO'),
          ),
          // Botón dinámico para alternar entre Pausa y Reanudar (activo durante la partida)
          FilledButton.tonalIcon(
            onPressed: (st == GameStatus.playing || st == GameStatus.paused)
                ? game.togglePause
                : null,
            icon: Icon(st == GameStatus.paused ? Icons.play_circle : Icons.pause),
            label: Text(st == GameStatus.paused ? 'REANUDAR' : 'PAUSA'),
          ),
          // Botón para reiniciar la partida actual (deshabilitado si el juego está en reposo)
          FilledButton.tonalIcon(
            onPressed: st == GameStatus.idle ? null : onRestart,
            icon: const Icon(Icons.replay),
            label: const Text('REINICIAR'),
          ),
          // Botón para limpiar la pantalla y regresar al estado inicial (IDLE)
          OutlinedButton.icon(
            onPressed: game.reset,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('NUEVA PARTIDA'),
          ),
        ],
      ),
    );
  }
}