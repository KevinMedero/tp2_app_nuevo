import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/catch_game.dart';
import '../models/profile.dart';
import 'dialogs/ad_dialog.dart';
import 'dialogs/game_over_dialog.dart';
import 'dialogs/shop_modal.dart';
import 'widgets/controls_widget.dart';
import 'widgets/header_widget.dart';

/// Pantalla principal que integra la interfaz de usuario de Flutter con el motor de juego Flame
class HomePage extends StatefulWidget {
  const HomePage(this.profile, {super.key});
  final Profile profile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final game = CatchGame();        // Instancia única del motor del juego
  Profile get p => widget.profile; // Getter auxiliar para acceder más fácil al perfil del usuario

  @override
  void initState() {
    super.initState();
    // Suscripción a eventos del juego para actualizar datos del perfil y mostrar modales
    game.onGem = () => p.addDiamonds(1);
    game.onGameOver = _gameOver;
  }

  // Detiene la partida actual, muestra un anuncio publicitario y reinicia el juego
  Future<void> _restart() async {
    game.pause();
    await _showAd();
    if (mounted) game.start();
  }

  // Muestra el diálogo de publicidad solo si el usuario no tiene cuenta PRO
  Future<void> _showAd() async {
    if (p.pro) return;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AdDialog());
  }

  // Despliega el diálogo modal de fin de juego y evalúa si se superó el récord
  void _gameOver() {
    final score = game.score.value;
    final isRecord = score > p.best; // Determina si es un nuevo récord antes de actualizar el perfil
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

  // Simula el procesamiento de una compra en la tienda con una espera de red ficticia
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
    onOk(); // Ejecuta la acción de la compra (sumar diamantes o activar PRO)
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('✅ Compra exitosa: $label')));
  }

  // Pausa el juego y abre el modal desplegable de la tienda
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
            // Encabezado con datos del jugador y marcadores en tiempo real
            HeaderWidget(
              profile: p,
              game: game,
              onOpenShop: _openShop,
            ),
            const SizedBox(height: 10),
            // Contenedor principal donde se renderiza el canvas del juego Flame
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: GameWidget(game: game),
              ),
            ),
            const SizedBox(height: 10),
            // Panel inferior con los botones de control de la partida
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