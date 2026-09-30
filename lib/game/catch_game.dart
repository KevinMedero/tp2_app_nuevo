import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/faller.dart';

enum GameStatus { idle, playing, paused, over }

enum Kind { fruit, gem, bomb }

/// Juego hecho con Flame. Todo se controla externamente con Flutter.
class CatchGame extends FlameGame with DragCallbacks {
  final score = ValueNotifier<int>(0);
  final lives = ValueNotifier<int>(3);
  final status = ValueNotifier<GameStatus>(GameStatus.idle);

  VoidCallback? onGem; // +1 diamante
  VoidCallback? onGameOver;

  final _rnd = Random();
  double _spawnTimer = 0;

  final basket = TextComponent(
    text: '🧺',
    anchor: Anchor.center,
    textRenderer: TextPaint(style: const TextStyle(fontSize: 64)),
  );

  @override
  Future<void> onLoad() async => add(basket);

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
    if (status.value != GameStatus.playing) return;
    super.update(dt);
    _spawnTimer += dt;
    final interval = max(0.35, 1.0 - score.value * 0.01);
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
      case Kind.gem:
        score.value += 5;
        onGem?.call();
      case Kind.bomb:
        lives.value -= 1;
        if (lives.value <= 0) {
          status.value = GameStatus.over;
          onGameOver?.call();
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