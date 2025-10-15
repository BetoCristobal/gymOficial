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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuscripcionProvider>().refrescarDesdeBilling();
    });
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
    unawaited(_iap.restorePurchases());
  }

  void _comprar(ProductDetails product) {
    final activa = context.read<SuscripcionProvider>().activa;
    if (activa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Ya cuentas con una suscripción activa')),
      );
      return;
    }
    final param = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: param);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.productID == _suscripcionId &&
          (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored)) {
        context.read<SuscripcionProvider>().setActiva(true);
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Suscripción activada'),
              duration: const Duration(seconds: 2),              
            ),
          );
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error en la compra'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _restaurarCompras() {
    _iap.restorePurchases();
  }

  Future<void> _abrirPolitica() async {
    final uri = Uri.parse('https://pexel.com.mx/terminos-y-condiciones-my-gym');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final activa = context.watch<SuscripcionProvider>().activa;

    final product = _products.isNotEmpty ? _products.first : null;
    // Precio fijo si quieres forzarlo; si product != null puedes usar product.price
    final displayPrice = product?.price ?? '\$180/mes';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (activa)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('✅ Suscripción activa', style: TextStyle(fontSize: 18, color: Colors.green)),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '❌ Suscripción no activa. Suscríbete para desbloquear la app y ver todas las funciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Botón principal (estado según suscripción)
                  SizedBox(
                    width: double.infinity,
                    child: activa
                        ? ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Ya estás suscrito, \$180/mes', style: TextStyle(fontSize: 16)),
                          )
                        : ElevatedButton(
                            onPressed: product != null ? () => _comprar(product) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple, // morado
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Suscribirse por $displayPrice', style: const TextStyle(fontSize: 16)),
                          ),
                  ),
                  const SizedBox(height: 24),
                  // Información adicional o lista de producto (opcional)
                  // Expanded(
                  //   child: product == null
                  //       ? const Center(child: Text('No hay productos disponibles', textAlign: TextAlign.center))
                  //       : Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const SizedBox(height: 12),
                  //             Text(product.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  //             const SizedBox(height: 8),
                  //             Text(product.description),
                  //             const SizedBox(height: 8),
                  //             Text('Precio en tienda: ${product.price}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  //           ],
                  //         ),
                  // ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          ' Beneficios de la suscripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.menu, color: Colors.deepPurple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Acceso al menú de administrador: configura disciplinas, precios y gestiona tu negocio.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.person_add, color: Colors.deepPurple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Registra clientes ilimitados: sin restricciones en la cantidad de registros.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.search, color: Colors.deepPurple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Busca y filtra clientes: encuentra rápidamente a cualquier cliente por nombre, estado o disciplina.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.filter_list, color: Colors.deepPurple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Filtra por disciplinas: organiza y visualiza tus clientes por cada disciplina que ofreces.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Reportes y PDF: genera y descarga reportes detallados de tus clientes y pagos en formato PDF.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // if (!activa)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 8.0),
                  //     child: TextButton(
                  //       onPressed: _restaurarCompras,
                  //       child: const Text('Restaurar compras'),
                  //     ),
                  //   ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextButton(
                      onPressed: _abrirPolitica,
                      child: const Text('Política de privacidad'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}