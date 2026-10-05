import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Publicidad simulada (modal con cuenta regresiva).
class AdDialog extends StatefulWidget {
  const AdDialog({super.key});
  @override
  State<AdDialog> createState() => _AdDialogState();
}

class _AdDialogState extends State<AdDialog> {
  late final VideoPlayerController vc;
  bool ready = false;
  int s = 5;
  Timer? t;

  @override
  void initState() {
    super.initState();
    vc = VideoPlayerController.asset('assets/video/ad.mp4');
    vc.initialize().then((_) {
      if (!mounted) return;
      setState(() => ready = true);
      vc.play();
    }).catchError((_) {}); // si falla, se ve el anuncio de texto

    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (s > 0) setState(() => s--);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    vc.dispose(); // importante: libera el video
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,  // PopScope bloquea el gesto de retroceso o botón "Atrás" de Android para obligar a interactuar con los botones
        child: AlertDialog(
          title: const Text('📺 Publicidad'),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ready
                ? AspectRatio(
                    aspectRatio: vc.value.aspectRatio,
                    child: VideoPlayer(vc),
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.orange,
                    child: const Text(
                      '🥤 ¡Super Jugo Mágico!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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