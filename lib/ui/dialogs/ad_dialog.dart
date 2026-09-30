import 'dart:async';
import 'package:flutter/material.dart';

/// Publicidad simulada (modal con cuenta regresiva).
class AdDialog extends StatefulWidget {
  const AdDialog({super.key});
  @override
  State<AdDialog> createState() => _AdDialogState();
}

class _AdDialogState extends State<AdDialog> {
  int s = 5;
  Timer? t;

  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (s > 0) setState(() => s--);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('📺 Publicidad'),
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orange, Colors.pink]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '🥤 ¡Super Jugo Mágico!\nEl favorito de los campeones.\n(anuncio de mentira)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            TextButton(
              onPressed: s == 0 ? () => Navigator.pop(context) : null,
              child: Text(s == 0 ? 'Cerrar ✖' : 'Cerrar en $s'),
            ),
          ],
        ),
      );
}