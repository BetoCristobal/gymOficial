import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuscripcionProvider extends ChangeNotifier {
  static const _kKey = 'suscripcion_activa';

  bool _activa = false;
  bool get activa => _activa;

  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    _activa = prefs.getBool(_kKey) ?? false;
    notifyListeners();
  }

  Future<void> setActiva(bool value) async {
    _activa = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, value);
    notifyListeners();
  }
}