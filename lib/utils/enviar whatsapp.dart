import 'package:url_launcher/url_launcher.dart';


enviarWhatsapp(String telefonoString, String mensaje) async {
  
  final url = 
    'https://wa.me/521$telefonoString?text=${Uri.encodeComponent("${mensaje}")}';

  try {
    print("Intentando lanzar: $url");
    final Uri uri = Uri.parse(url);
    if(await launchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("No se pudo abrir whatsApp");
    }
  } catch (e) {
    print("Error $e");
  }
}