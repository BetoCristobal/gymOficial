import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mygym/providers/suscripcion_provider.dart';

class SuscripcionScreen extends StatefulWidget {
  const SuscripcionScreen({super.key});

  @override
  State<SuscripcionScreen> createState() => _SuscripcionScreenState();
}

class _SuscripcionScreenState extends State<SuscripcionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late Stream<List<PurchaseDetails>> _purchaseStream;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  List<ProductDetails> _products = [];
  bool _loading = true;

  static const String _suscripcionId = 'suscripcion_gym'; // Tu ID real

  @override
  void initState() {
    super.initState();
    _purchaseStream = _iap.purchaseStream;
    _loadProducts();
    _sub = _purchaseStream.listen(_onPurchaseUpdated, onDone: () => _sub?.cancel(), onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }
    const ids = <String>{_suscripcionId};
    final response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
    // Opcional: intenta restaurar para reflejar estado previo
    unawaited(_iap.restorePurchases());
  }

  void _comprar(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: param); // Para suscripciones también aplica
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.productID == _suscripcionId && purchase.status == PurchaseStatus.purchased) {
        context.read<SuscripcionProvider>().setActiva(true);
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Suscripción activada')),
        );
      } else if (purchase.status == PurchaseStatus.restored) {
        context.read<SuscripcionProvider>().setActiva(true);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error en la compra')),
        );
      }
    }
  }

  void _restaurarCompras() {
    _iap.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final activa = context.watch<SuscripcionProvider>().activa;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (activa)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('✅ Suscripción activa', style: TextStyle(fontSize: 18, color: Colors.green)),
                  ),
                Expanded(
                  child: _products.isEmpty
                      ? const Center(child: Text('No hay productos disponibles'))
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Card(
                              color: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              child: ListTile(
                                title: Text(product.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                subtitle: Text(product.description, style: const TextStyle(color: Colors.white70)),
                                trailing: Text(product.price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                iconColor: Colors.white,
                                onTap: () => _comprar(product),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _restaurarCompras,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                    child: const Text('Restaurar compras'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton(
                    onPressed: () => launchUrl(Uri.parse('https://pexel.com.mx/terminos-y-condiciones-my-gym')),
                    child: const Text('Política de privacidad'),
                  ),
                ),
              ],
            ),
    );
  }
}