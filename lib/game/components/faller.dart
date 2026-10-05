import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../catch_game.dart';

/// Componente que representa a cada elemento que cae (fruta, gema o bomba)
class Faller extends TextComponent with HasGameReference<CatchGame> {
  Faller(this.kind, String emoji, this.speed)
      : super(
          text: emoji,
          anchor: Anchor.center,
          textRenderer: TextPaint(style: const TextStyle(fontSize: 40)),
        );

  final Kind kind;    // Tipo de elemento (fruit, gem, bomb)
  final double speed; // Velocidad de caída en píxeles por segundo

  @override
  void update(double dt) {
    super.update(dt);
    // Mueve el objeto hacia abajo según el tiempo transcurrido (dt) y su velocidad
    y += speed * dt;
    final b = game.basket;
    // Detecta la colisión mediante la distancia entre el objeto y la canasta
    if ((x - b.x).abs() < 45 && (y - b.y).abs() < 40) {
      game.caught(kind);
      removeFromParent();
    } else if (y > game.size.y + 40) {  // Si sobrepasa el borde inferior de la pantalla sin ser atrapado, se destruye
      removeFromParent();
    }
  }
}