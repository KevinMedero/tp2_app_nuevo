import 'package:flutter/material.dart';
import '../../game/catch_game.dart';
import '../../models/profile.dart';

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
    return ListenableBuilder(
      listenable: profile,
      builder: (_, __) => Card(
        color: cs.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              const CircleAvatar(child: Text('🦊')),
              const SizedBox(width: 8),
              Text(profile.user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(profile.pro ? '👑 PRO' : 'BASIC'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Modo claro/oscuro',
                icon: Icon(profile.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: profile.toggleDark,
              ),
              IconButton(
                tooltip: 'Tienda',
                icon: const Icon(Icons.storefront),
                onPressed: onOpenShop,
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (_, s, __) => Text('⭐ $s', style: const TextStyle(fontSize: 18)),
              ),
              Text('🏆 ${profile.best}', style: const TextStyle(fontSize: 18)),
              ValueListenableBuilder<int>(
                valueListenable: game.lives,
                builder: (_, l, __) =>
                    Text('❤️' * l.clamp(0, 3), style: const TextStyle(fontSize: 18)),
              ),
              Text('💎 ${profile.diamonds}', style: const TextStyle(fontSize: 18)),
            ]),
          ]),
        ),
      ),
    );
  }
}