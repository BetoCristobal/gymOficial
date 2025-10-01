import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class SuscripcionScreen extends StatefulWidget {
  const SuscripcionScreen({super.key});

  @override
  State<SuscripcionScreen> createState() => _SuscripcionScreenState();
}

class _SuscripcionScreenState extends State<SuscripcionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _loading = true;
  late Stream<List<PurchaseDetails>> _purchaseStream;
  bool _suscripcionActiva = false;

  static const String _suscripcionId = 'suscripcion_gym'; // Cambia por tu ID real

  @override
  void initState() {
    super.initState();
    _purchaseStream = _iap.purchaseStream;
    _loadProducts();
    _purchaseStream.listen(_onPurchaseUpdated);
  }

  Future<void> _loadProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }
    const Set<String> ids = {_suscripcionId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
      _loading = false;
    });
  }

  void _comprar(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.productID == _suscripcionId && purchase.status == PurchaseStatus.purchased) {
        setState(() {
          _suscripcionActiva = true;
        });
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.restored) {
        setState(() {
          _suscripcionActiva = true;
        });
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error en la compra')),
        );
      }
    }
  }

  void _restaurarCompras() {
    _iap.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suscripción')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_suscripcionActiva)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('✅ Suscripción activa', style: TextStyle(fontSize: 18, color: Colors.green)),
                  ),
                Expanded(
                  child: _products.isEmpty
                      ? Center(child: Text('No hay productos disponibles'))
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Card(
                              child: ListTile(
                                title: Text(product.title),
                                subtitle: Text(product.description),
                                trailing: Text(product.price),
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
                    child: Text('Restaurar compras'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      // Reemplaza con tu URL real
                      launchUrl(Uri.parse('https://tusitio.com/politica-privacidad'));
                    },
                    child: Text('Política de privacidad'),
                  ),
                ),
              ],
            ),
    );
  }
}