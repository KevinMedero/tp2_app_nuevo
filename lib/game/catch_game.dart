import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'components/faller.dart';

enum GameStatus { idle, playing, paused, over }

enum Kind { fruit, gem, bomb }

/// Juego hecho con Flame. Todo se controla externamente con Flutter.
class CatchGame extends FlameGame with DragCallbacks {
  final score = ValueNotifier<int>(0);
  final lives = ValueNotifier<int>(3);
  final status = ValueNotifier<GameStatus>(GameStatus.idle);

  VoidCallback? onGem; // Se atrapó una gema -> +1 diamante
  VoidCallback? onGameOver;

  final _rnd = Random();
  double _spawnTimer = 0;

  final basket = Basket();

  bool soundOn = true;

  void _sfx(String file) {
    if (!soundOn) return;
    try {
      FlameAudio.play(file);
    } catch (_) {} // Si el audio falla, el juego continúa normalmente
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(basket);
    try {
      await FlameAudio.audioCache
          .loadAll(['fruit.wav', 'gem.wav', 'bomb.wav', 'gameover.wav']);
    } catch (_) {}
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final x = basket.x == 0 ? size.x / 2 : basket.x.clamp(32.0, size.x - 32);
    basket.position = Vector2(x.toDouble(), size.y - 50);
  }

  @override
  void render(Canvas canvas) {
    final r = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6DD5FA), Color(0xFFFFF1A8)],
        ).createShader(r),
    );
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (status.value != GameStatus.playing) return; // pausa = no se actualiza
    super.update(dt);
    _spawnTimer += dt;
    final interval = max(0.35, 1.0 - score.value * 0.01); // dificultad creciente
    if (_spawnTimer >= interval) {
      _spawnTimer = 0;
      _spawn();
    }
  }

  void _spawn() {
    final r = _rnd.nextDouble();
    final kind = r < 0.15 ? Kind.bomb : (r < 0.30 ? Kind.gem : Kind.fruit);
    final emoji = switch (kind) {
      Kind.bomb => '💣',
      Kind.gem => '💎',
      Kind.fruit => const ['🍎', '🍌', '🍇', '🍓', '🍉'][_rnd.nextInt(5)],
    };
    final speed = 140 + score.value * 2.0 + _rnd.nextDouble() * 80;
    add(Faller(kind, emoji, speed)
      ..position = Vector2(30 + _rnd.nextDouble() * (size.x - 60), -30));
  }

  void caught(Kind k) {
    switch (k) {
      case Kind.fruit:
        score.value += 1;
        _sfx('fruit.wav');
      case Kind.gem:
        score.value += 5;
        _sfx('gem.wav');
        onGem?.call();
      case Kind.bomb:
        lives.value -= 1;
        if (lives.value <= 0) {
          status.value = GameStatus.over;
          _sfx('gameover.wav');
          onGameOver?.call();
        } else {
          _sfx('bomb.wav');
        }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (status.value != GameStatus.playing) return;
    basket.x = (basket.x + event.canvasDelta.x).clamp(32.0, size.x - 32).toDouble();
  }

  // Controles externos
  void _clear() =>
      children.whereType<Faller>().toList().forEach((f) => f.removeFromParent());

  void start() {
    _clear();
    score.value = 0;
    lives.value = 3;
    _spawnTimer = 0;
    status.value = GameStatus.playing;
  }

  void pause() {
    if (status.value == GameStatus.playing) status.value = GameStatus.paused;
  }

  void togglePause() {
    if (status.value == GameStatus.playing) {
      status.value = GameStatus.paused;
    } else if (status.value == GameStatus.paused) {
      status.value = GameStatus.playing;
    }
  }

  void reset() {
    _clear();
    score.value = 0;
    lives.value = 3;
    status.value = GameStatus.idle;
  }

  void revive() {
    _clear();
    lives.value = 1;
    status.value = GameStatus.playing;
  }
}

/// Canasta dibujada con formas (no depende de la fuente de emojis).
class Basket extends PositionComponent {
  Basket() : super(size: Vector2(84, 56), anchor: Anchor.center);
 
  @override
  void render(Canvas canvas) {
    // cuerpo
    final body = RRect.fromRectAndCorners(
      const Rect.fromLTWH(6, 16, 72, 40),
      bottomLeft: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFD9954B));
 
    // trenzado
    final weave = Paint()
      ..color = const Color(0xFF9C6226)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (double x = 20; x < 78; x += 16) {
      canvas.drawLine(Offset(x, 20), Offset(x, 54), weave);
    }
    canvas.drawLine(const Offset(8, 34), const Offset(76, 34), weave);
    canvas.drawLine(const Offset(12, 46), const Offset(72, 46), weave);
 
    // borde superior
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 8, 84, 14), const Radius.circular(7)),
      Paint()..color = const Color(0xFF8D5524),
    );
  }
}