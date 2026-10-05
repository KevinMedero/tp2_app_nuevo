import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestión de estado del perfil de usuario y datos guardados localmente (offline)
class Profile extends ChangeNotifier {
  // Datos estáticos del usuario
  final String user = 'Sofi_123';
  int diamonds = 10, best = 0;
  bool pro = false, dark = false;
  late SharedPreferences _p;

  // Carga los datos guardados en el almacenamiento local al iniciar
  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    diamonds = _p.getInt('d') ?? 10;
    best = _p.getInt('b') ?? 0;
    pro = _p.getBool('p') ?? false;
    dark = _p.getBool('k') ?? false;
  }

  // Guarda los valores actuales en SharedPreferences y notifica a los widgets
  void _save() {
    _p.setInt('d', diamonds);
    _p.setInt('b', best);
    _p.setBool('p', pro);
    _p.setBool('k', dark);
    notifyListeners();  // Actualiza la UI reactivamente
  }

  // Aumenta la cantidad de diamantes y guarda cambios
  void addDiamonds(int n) {
    diamonds += n;
    _save();
  }

  // Descuenta diamantes si el saldo es suficiente; retorna false si no alcanza
  bool spend(int n) {
    if (diamonds < n) return false;
    diamonds -= n;
    _save();
    return true;
  }

  // Actualiza y guarda el puntaje máximo solo si supera el récord actual
  void setBest(int s) {
    if (s > best) {
      best = s;
      _save();
    }
  }

  // Activa el estado de cuenta PRO
  void setPro() {
    pro = true;
    _save();
  }

  // Alterna entre el tema claro y oscuro
  void toggleDark() {
    dark = !dark;
    _save();
  }
}