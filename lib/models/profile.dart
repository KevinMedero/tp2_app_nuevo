import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Perfil simulado (login falso) + datos guardados localmente => 100% offline.
class Profile extends ChangeNotifier {
  final String user = 'Sofi_123';
  int diamonds = 10, best = 0;
  bool pro = false, dark = false;
  late SharedPreferences _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    diamonds = _p.getInt('d') ?? 10;
    best = _p.getInt('b') ?? 0;
    pro = _p.getBool('p') ?? false;
    dark = _p.getBool('k') ?? false;
  }

  void _save() {
    _p.setInt('d', diamonds);
    _p.setInt('b', best);
    _p.setBool('p', pro);
    _p.setBool('k', dark);
    notifyListeners();
  }

  void addDiamonds(int n) {
    diamonds += n;
    _save();
  }

  bool spend(int n) {
    if (diamonds < n) return false;
    diamonds -= n;
    _save();
    return true;
  }

  void setBest(int s) {
    if (s > best) {
      best = s;
      _save();
    }
  }

  void setPro() {
    pro = true;
    _save();
  }

  void toggleDark() {
    dark = !dark;
    _save();
  }
}