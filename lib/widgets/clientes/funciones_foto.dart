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
    final nombreArchivo = 'cliente_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final pathDestino = p.join(appDir.path, nombreArchivo);

    final File nuevaFoto = await fotoTomada.copy(pathDestino);

    return nuevaFoto.path;
  }
}

