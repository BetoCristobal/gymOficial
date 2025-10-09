import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SuscripcionProvider extends ChangeNotifier {
  static const _kKey = 'suscripcion_activa';
  static const _productId = 'suscripcion_gym'; // tu ID real

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

  Future<void> refrescarDesdeBilling() async {
    try {
      final iap = InAppPurchase.instance;
      final addition = iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await addition.queryPastPurchases(); // compras vigentes
      final active = response.pastPurchases.any(
        (p) => p.productID == _productId && p.status == PurchaseStatus.purchased,
      );
      await setActiva(active);
    } catch (_) {
      // Fallback: intentar restaurar (si no hay compras, no cambia el estado)
      await InAppPurchase.instance.restorePurchases();
    }
  }
}