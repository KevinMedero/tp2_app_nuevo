import 'package:flutter/material.dart';
import '../../game/catch_game.dart';

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
    return ValueListenableBuilder<GameStatus>(
      valueListenable: game.status,
      builder: (_, st, _) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: st == GameStatus.idle ? game.start : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('INICIO'),
          ),
          FilledButton.tonalIcon(
            onPressed: (st == GameStatus.playing || st == GameStatus.paused)
                ? game.togglePause
                : null,
            icon: Icon(st == GameStatus.paused ? Icons.play_circle : Icons.pause),
            label: Text(st == GameStatus.paused ? 'REANUDAR' : 'PAUSA'),
          ),
          FilledButton.tonalIcon(
            onPressed: st == GameStatus.idle ? null : onRestart,
            icon: const Icon(Icons.replay),
            label: const Text('REINICIAR'),
          ),
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