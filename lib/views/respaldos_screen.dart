import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class RespaldosScreen extends StatefulWidget {
  const RespaldosScreen({super.key});

  @override
  State<RespaldosScreen> createState() => _RespaldosScreenState();
}

class _RespaldosScreenState extends State<RespaldosScreen> {
  /// Ruta de la base de datos local
  Future<String> getDbPath() async {
    final dbFolder = await getDatabasesPath();
    return join(dbFolder, "mygym.db"); // 👈 usa tu nombre real de DB
  }

  /// Exportar la DB y compartir
  Future<void> exportDb() async {
    final dbPath = await getDbPath();
    final dbFile = File(dbPath);

    if (await dbFile.exists()) {
      await Share.shareXFiles(
        [XFile(dbPath)],
        text: 'Respaldo de base de datos',
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('No se encontró la base de datos')),
        );
      }
    }
  }

  /// Importar DB desde archivo seleccionado
  Future<void> importDb() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final dbPath = await getDbPath();

      // Copiamos sobre la db actual
      await pickedFile.copy(dbPath);

      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Base de datos restaurada')),
        );
      }
      Provider.of<ClienteProvider>(this.context, listen: false).cargarClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Respaldos")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: exportDb,
              icon: const Icon(Icons.upload_file),
              label: const Text("Exportar y compartir DB"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: importDb,
              icon: const Icon(Icons.download),
              label: const Text("Importar y restaurar DB"),
            ),
          ],
        ),
      ),
    );
  }
}

