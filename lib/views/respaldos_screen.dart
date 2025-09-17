import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:mygym/data/db/database_helper.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    return join(dbFolder, "mygym.db");
  }

  /// Ruta de la carpeta de documentos de la app
  Future<Directory> getAppDir() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Exportar la DB y la subcarpeta fotos_usuarios en un ZIP y compartir
  Future<void> exportarBackup() async {
    final dbPath = await getDbPath();
    final appDir = await getAppDir();
    final fotosDir = Directory(join(appDir.path, 'fotos_usuarios'));
    final tempDir = await getTemporaryDirectory();
    final zipPath = join(tempDir.path, "respaldo_mygym.zip");

    // 🔹 Garantizar que exista la carpeta fotos_usuarios
    if (!await fotosDir.exists()) {
      await fotosDir.create(recursive: true);
      print("📁 Carpeta fotos_usuarios creada en: ${fotosDir.path}");
    }

    // 🔹 Garantizar que exista la base de datos
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      // Crea un archivo vacío para asegurar que esté en el respaldo
      await dbFile.writeAsBytes([]);
      print("📄 Base de datos creada vacía en: $dbPath");
    }

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    // Agregar la base de datos
    if (await dbFile.exists()) {
      encoder.addFile(dbFile);
      print("✅ Base de datos agregada al ZIP: $dbPath");
    }

    // Agregar la carpeta fotos_usuarios
    if (await fotosDir.exists()) {
      encoder.addDirectory(fotosDir);
      print("✅ Carpeta fotos_usuarios agregada al ZIP: ${fotosDir.path}");
    }

    // 🔹 Garantizar que el ZIP no quede vacío
    final readmeFile = File(join(tempDir.path, "LEEME.txt"));
    await readmeFile.writeAsString("Este es un respaldo generado por MyGym.\nIncluye base de datos y fotos_usuarios.");
    encoder.addFile(readmeFile);

    encoder.close();

    await Share.shareXFiles([XFile(zipPath)], text: 'Respaldo completo de MyGym');
  }

  /// Importar ZIP y restaurar DB y la subcarpeta fotos_usuarios
  Future<void> importarBackup() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final zipFile = File(result.files.single.path!);
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(join(tempDir.path, "import_temp"));

      // 🔹 Aseguramos directorio temporal limpio
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create();

      // 🔹 Descomprimir ZIP
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        final outPath = join(extractDir.path, filename);
        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }

      // 🔹 Restaurar base de datos
      final dbPath = await getDbPath();
      final dbBackup = File(join(extractDir.path, "mygym.db"));
      if (await dbBackup.exists()) {
        final dbHelper = DatabaseHelper();
        await dbHelper.closeDatabase(); // Cerramos conexión de verdad
        final dbFile = File(dbPath);
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        await dbBackup.copy(dbPath);
        print("✅ Base de datos restaurada en: $dbPath");
      }

      // 🔹 Restaurar la subcarpeta fotos_usuarios
      final appDir = await getAppDir();
      final fotosDir = Directory(join(appDir.path, 'fotos_usuarios'));
      final fotosBackupDir = Directory(join(extractDir.path, 'fotos_usuarios'));

      if (await fotosDir.exists()) {
        await fotosDir.delete(recursive: true);
      }
      if (await fotosBackupDir.exists()) {
        await _copyDirectory(fotosBackupDir, fotosDir);
        print("✅ Carpeta fotos_usuarios restaurada en: ${fotosDir.path}");
      }

      // 🔹 Limpieza
      await extractDir.delete(recursive: true);

      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Respaldo restaurado correctamente CHIDO')),
        );
      }

      
      Provider.of<ClienteProvider>(this.context, listen: false).cargarClientes();
    }
  }

  /// Función auxiliar para copiar directorios recursivamente
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(join(destination.path, basename(entity.path)));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(join(destination.path, basename(entity.path)));
      }
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
              onPressed: exportarBackup,
              icon: const Icon(Icons.upload_file),
              label: const Text("Exportar y compartir respaldo (DB + Fotos)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: importarBackup,
              icon: const Icon(Icons.download),
              label: const Text("Importar y restaurar respaldo (ZIP)"),
            ),
          ],
        ),
      ),
    );
  }
}