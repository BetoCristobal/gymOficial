import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class CambiarImagenScreen extends StatefulWidget {
  const CambiarImagenScreen({super.key});

  @override
  State<CambiarImagenScreen> createState() => _CambiarImagenScreenState();
}

class _CambiarImagenScreenState extends State<CambiarImagenScreen> {
  File? _imagen;
  String? _rutaImagen;

  @override
  void initState() {
    super.initState();
    _cargarImagen();
  }

  Future<void> _cargarImagen() async {
    final prefs = await SharedPreferences.getInstance();
    final ruta = prefs.getString('ruta_imagen_login');
    if (ruta != null && await File(ruta).exists()) {
      setState(() {
        _imagen = File(ruta);
        _rutaImagen = ruta;
      });
    } else {
      setState(() {
        _imagen = null;
        _rutaImagen = null;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Copiar la imagen a la carpeta interna de la app
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ruta_imagen_login', savedImage.path);

      setState(() {
        _imagen = savedImage;
        _rutaImagen = savedImage.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Imagen guardada')),
      );
    }
  }

  Future<void> _eliminarImagen() async {
    final prefs = await SharedPreferences.getInstance();
    final ruta = prefs.getString('ruta_imagen_login');
    if (ruta != null) {
      final file = File(ruta);
      if (await file.exists()) {
        await file.delete();
      }
      await prefs.remove('ruta_imagen_login');
    }
    setState(() {
      _imagen = null;
      _rutaImagen = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Imagen eliminada, se muestra la imagen por defecto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imagenWidget;
    if (_imagen != null && _rutaImagen != null) {
      imagenWidget = Image.file(
        _imagen!,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      imagenWidget = Image.asset(
        'assets/logo.png',
        width: 250,
        height: 250,
        fit: BoxFit.contain,
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: Text('Cambiar imagen de inicio'),
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(fontSize: 23, color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagenWidget,
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _seleccionarImagen,
              child: Text('Seleccionar imagen'),
            ),
            SizedBox(height: 12),
            if (_imagen != null && _rutaImagen != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _eliminarImagen,
                child: Text('Eliminar imagen'),
              ),
          ],
        ),
      ),
    );
  }
}