import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/data/models/pago_model.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/utils/calcular_dias_restantes.dart';
import 'package:mygym/utils/asignar_estatus.dart';
import 'package:mygym/utils/asignar_emoji.dart';
import 'package:mygym/utils/asignar_color_fondo_card_cliente.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EstatusClientesScreen extends StatefulWidget {
  const EstatusClientesScreen({super.key});

  @override
  State<EstatusClientesScreen> createState() => _EstatusClientesScreenState();
}

class _EstatusClientesScreenState extends State<EstatusClientesScreen> {
    bool escaneoActivo = true;
  MobileScannerController cameraController = MobileScannerController();
  String? qrResult;
  String? _rutaImagen;
  int _tapCount = 0;
  DateTime? _lastTap;
  String? nombreCompleto;
  int? idCliente;
  String? fechaPago;
  String? proximaFechaPago;
  int? diasRestantes;
  String? estatus;

  @override
  void initState() {
    super.initState();
    _cargarLogo();
    cameraController.start().then((_) {
      cameraController.switchCamera();
    });
  }

  Future<void> buscarClienteYUltimoPago(String qr) async {
    // El QR contiene nombres y apellidos juntos
    final qrTexto = qr.trim().toLowerCase();
    try {
      final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
      final pagoProvider = Provider.of<PagoProvider>(context, listen: false);
      // Esperar a que los clientes estén cargados si la lista está vacía
      int intentos = 0;
      while (clienteProvider.clientes.isEmpty && intentos < 20) {
        await Future.delayed(Duration(milliseconds: 100));
        intentos++;
      }
      final cliente = clienteProvider.clientes.firstWhere(
        (c) => ('${c.nombres} ${c.apellidos}').trim().toLowerCase() == qrTexto,
        orElse: () => ClienteModel(nombres: "", apellidos: "", telefono: "", estatus: ""),
      );
      if (cliente.nombres.isNotEmpty && cliente.apellidos.isNotEmpty) {
        String? fecha;
        String? proxima;
        if (cliente.id != null) {
          final pago = await pagoProvider.obtenerUltimoPagoCliente(cliente.id!);
          if (pago?.fechaPago != null) {
            fecha = DateFormat('dd-MM-yyyy').format(pago!.fechaPago);
          }
          if (pago?.proximaFechaPago != null) {
            proxima = DateFormat('dd-MM-yyyy').format(pago!.proximaFechaPago);
            diasRestantes = calcularDiasRestantes(pago.proximaFechaPago);
          }
        }
        String nuevoEstatus = asignarEstatus(diasRestantes ?? -999, cliente.id ?? 0);
        setState(() {
          nombreCompleto = '${cliente.nombres} ${cliente.apellidos}';
          idCliente = cliente.id;
          fechaPago = fecha;
          proximaFechaPago = proxima;
          estatus = nuevoEstatus;
        });
      } else {
        setState(() {
          nombreCompleto = null;
          idCliente = null;
          fechaPago = null;
          proximaFechaPago = null;
        });
      }
    } catch (e) {
      setState(() {
        nombreCompleto = null;
        idCliente = null;
        fechaPago = null;
        proximaFechaPago = null;
      });
    }
  }

  Future<void> _cargarLogo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rutaImagen = prefs.getString('ruta_imagen_login');
    });
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              final now = DateTime.now();
              if (_lastTap == null || now.difference(_lastTap!) > Duration(seconds: 1)) {
                _tapCount = 1;
              } else {
                _tapCount++;
              }
              _lastTap = now;
              if (_tapCount >= 4) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                _tapCount = 0;
              }
            },
            child: _rutaImagen != null && File(_rutaImagen!).existsSync()
                ? Image.file(
                    File(_rutaImagen!),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: escaneoActivo
                    ? MobileScanner(
                        controller: cameraController,
                        onDetect: (capture) async {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            debugPrint('¡QR encontrado!: ${barcode.rawValue}');
                            if (barcode.rawValue != null) {
                              setState(() {
                                qrResult = barcode.rawValue;
                                escaneoActivo = false;
                              });
                              cameraController.stop();
                              await buscarClienteYUltimoPago(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      )
                    : Center(
                        child: Icon(Icons.qr_code_2, color: Colors.white38, size: 80),
                      ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () => cameraController.toggleTorch(),
                  tooltip: 'Flash',
                ),
                SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: () => cameraController.switchCamera(),
                  tooltip: 'Cambiar cámara',
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          if (!escaneoActivo)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 43, 103, 214)),
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text('Reiniciar escaneo', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                setState(() {
                  qrResult = null;
                  nombreCompleto = null;
                  idCliente = null;
                  fechaPago = null;
                  proximaFechaPago = null;
                  escaneoActivo = true;
                  cameraController.dispose();
                  cameraController = MobileScannerController();
                  estatus = null;
                });
              },
            ),
          SizedBox(height: 24),
          if (nombreCompleto != null && idCliente != null)
            Builder(
              builder: (context) {
                final emoji = asignarEmoji(estatus ?? "");
                final gradient = asignarColorFondoCardCliente(estatus ?? "");
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(emoji, style: TextStyle(fontSize: 32)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              nombreCompleto ?? '',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.white, height: 8),
                      SizedBox(height: 10),
                      if (fechaPago != null && proximaFechaPago != null) ...[
                        Text('Último pago: $fechaPago', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Próximo pago: $proximaFechaPago', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Días restantes: $diasRestantes', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estatus ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text('No hay pagos registrados', style: TextStyle(fontSize: 18, color: Colors.yellow)),
                      ]
                    ],
                  ),
                );
              },
            )
          else if (qrResult != null)
            Text('Cliente no encontrado', style: TextStyle(fontSize: 18, color: Colors.red))
          else
            Text('Escanea un código QR', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}