import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/catch_game.dart';
import '../models/profile.dart';
import 'dialogs/ad_dialog.dart';
import 'dialogs/game_over_dialog.dart';
import 'dialogs/shop_modal.dart';
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
        context: context,
        barrierDismissible: false,
        builder: (_) => const AdDialog());
  }

  void _gameOver() {
    final score = game.score.value;
    final isRecord = score > p.best; // se calcula antes de guardar el récord
    p.setBest(score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        game: game,
        profile: p,
        score: score,
        isRecord: isRecord,
        onRestart: _restart,
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
      builder: (_) => ShopModal(
        profile: p,
        onPay: _pay,
      ),
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