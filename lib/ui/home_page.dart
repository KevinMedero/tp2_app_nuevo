import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/catch_game.dart';
import '../models/profile.dart';
import 'dialogs/ad_dialog.dart';
import 'widgets/controls_widget.dart';
import 'widgets/header_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.profile, {super.key});
  final Profile profile;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final game = CatchGame();
  Profile get p => widget.profile;

  @override
  void initState() {
    super.initState();
    game.onGem = () => p.addDiamonds(1);
    game.onGameOver = _gameOver;
  }

  Future<void> _restart() async {
    game.pause();
    await _showAd();
    if (mounted) game.start();
  }

  Future<void> _showAd() async {
    if (p.pro) return;
    await showDialog(
        context: context, barrierDismissible: false, builder: (_) => const AdDialog());
  }

  void _gameOver() {
    p.setBest(game.score.value);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Game over! 😢'),
        content: Text('Puntos: ${game.score.value}\nRécord: ${p.best}'),
        actions: [
          if (p.diamonds >= 5)
            TextButton(
              onPressed: () {
                if (p.spend(5)) {
                  Navigator.pop(ctx);
                  game.revive();
                }
              },
              child: const Text('❤️ Revivir (5 💎)'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restart();
            },
            child: const Text('Jugar otra vez'),
          ),
        ],
      ),
    );
  }

  Future<void> _pay(String label, VoidCallback onOk) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(child: Text('Procesando pago...')),
        ]),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.pop(context);
    onOk();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('✅ Compra exitosa: $label')));
  }

  void _openShop() {
    game.pause();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        Widget pack(int n, String price) => ListTile(
              leading: const Text('💎', style: TextStyle(fontSize: 28)),
              title: Text('$n diamantes'),
              trailing: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _pay('$n 💎', () => p.addDiamonds(n));
                },
                child: Text(price),
              ),
            );
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('🛒 Tienda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            pack(10, '\$0.99'),
            pack(50, '\$3.99'),
            pack(120, '\$7.99'),
            const Divider(),
            ListTile(
              leading: const Text('👑', style: TextStyle(fontSize: 28)),
              title: const Text('Cuenta PRO (sin anuncios)'),
              trailing: p.pro
                  ? const Text('¡Activa!')
                  : FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _pay('Cuenta PRO', p.setPro);
                      },
                      child: const Text('\$4.99'),
                    ),
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            HeaderWidget(
              profile: p,
              game: game,
              onOpenShop: _openShop,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: GameWidget(game: game),
              ),
            ),
            const SizedBox(height: 10),
            ControlsWidget(
              game: game,
              onRestart: _restart,
            ),
          ]),
        ),
      ),
    );
  }
}