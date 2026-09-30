import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../catch_game.dart';

class Faller extends TextComponent with HasGameReference<CatchGame> {
  Faller(this.kind, String emoji, this.speed)
      : super(
          text: emoji,
          anchor: Anchor.center,
          textRenderer: TextPaint(style: const TextStyle(fontSize: 40)),
        );

  final Kind kind;
  final double speed;

  @override
  void update(double dt) {
    super.update(dt);
    y += speed * dt;
    final b = game.basket;
    if ((x - b.x).abs() < 45 && (y - b.y).abs() < 40) {
      game.caught(kind);
      removeFromParent();
    } else if (y > game.size.y + 40) {
      removeFromParent();
    }
  }
}