import 'dart:io';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/views/cambiar_imagen_screen.dart';
import 'package:mygym/views/gestion_contraseñas.dart';
import 'package:mygym/views/gestion_disciplinas.dart';
import 'package:mygym/views/reportes_screen.dart';
import 'package:mygym/views/respaldos_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ClientesDrawer extends StatelessWidget {
  const ClientesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    
    Future<void> exportarTodosLosQrsYCompartir(BuildContext context, List<ClienteModel> clientes) async {
      final tempDir = await getTemporaryDirectory();
      final archive = Archive();

      for (final cliente in clientes) {
        try {
          final painter = QrPainter(
            data: "${cliente.nombres} ${cliente.apellidos}",
            version: QrVersions.auto,
            gapless: false,
            emptyColor: const Color(0xFFFFFFFF),
            
          );
          final image = await painter.toImage(400);
          final byteData = await image.toByteData(format: ImageByteFormat.png);
          final pngBytes = byteData!.buffer.asUint8List();

          final fileName = "qr_${cliente.id}_${cliente.nombres}_${cliente.apellidos}"
            .replaceAll(RegExp(r'[^\w\d_]'), '_')
            .toLowerCase() + ".png";

          archive.addFile(ArchiveFile(fileName, pngBytes.length, pngBytes));
          print('Archivo agregado al archive: $fileName');
        } catch (e) {
          print("Error al generar o guardar el QR de ${cliente.nombres} ${cliente.apellidos}: $e");
        }
      }

      final zipPath = '${tempDir.path}/qrs_${DateTime.now().millisecondsSinceEpoch}.zip';
      final zipFile = File(zipPath);
      zipFile.writeAsBytesSync(ZipEncoder().encode(archive)!);

      print('ZIP generado: ${zipFile.path}, tamaño: ${await zipFile.length()} bytes');
      await Share.shareXFiles([XFile(zipPath)], text: "QRs de todos los clientes");
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.chartSimple, color: Colors.black),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReportesScreen()));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.dumbbell, color: Colors.black),
            title: const Text('Gestionar disciplinas'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GestionDisciplinasScreen()));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.image, color: Colors.black),
            title: const Text('Cambiar imagen de inicio'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CambiarImagenScreen()));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.black),
            title: const Text('Respaldos'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RespaldosScreen()));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.key, color: Colors.black),
            title: const Text('Gestionar contraseña'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GestionContrasenasScreen()));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.qrcode, color: Colors.black),
            title: const Text('Exportar QR´s'),
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false, // Evita cerrar el diálogo mientras procesa
                builder: (context) => AlertDialog(
                  title: const Text("Exportar todos los QR"),
                  content: const Text("Esto generará un archivo ZIP con los códigos de todos los clientes registrados."),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text("Exportar"),
                      onPressed: () async {
                        // 5. FLUJO DE EJECUCIÓN MEJORADO
                        final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
                        await clienteProvider.cargarClientes();
                        final clientes = clienteProvider.clientes;

                        // Ejecutamos la función pesada
                        await exportarTodosLosQrsYCompartir(context, clientes);
                        
                        // Cerramos el diálogo después de compartir
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}