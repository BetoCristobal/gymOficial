import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FuncionesFoto {
  
  static Future<File?> tomarFotoTemporal() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 50,
    );

    if(imagen == null) return null;

    final File fotoTomada = File(imagen.path);   

    return fotoTomada;
  }

  static Future<String> guardarFoto(File fotoTomada) async {
    final appDir = await getApplicationDocumentsDirectory();
    // Crea la subcarpeta 'fotos_usuarios' si no existe
    final fotosDir = Directory(p.join(appDir.path, 'fotos_usuarios'));
    if (!await fotosDir.exists()) {
      await fotosDir.create(recursive: true);
    }
    final nombreArchivo = 'cliente_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final pathDestino = p.join(fotosDir.path, nombreArchivo);

    final File nuevaFoto = await fotoTomada.copy(pathDestino);

    return nuevaFoto.path;
  }
}