import 'package:intl/intl.dart';

String mensajeElegido(String? opcionSeleccionada, DateTime proximoPago) {
  String proximaFechaPago = DateFormat('dd-MM-yyyy').format(proximoPago!);

  if (opcionSeleccionada == null || opcionSeleccionada.isEmpty) {
    return "";
  }

  switch (opcionSeleccionada) {
    case "Recordar pago":
      return "Hola, te recordamos amablemente que tu próxima fecha de pago es el ${proximaFechaPago}. ¡Gracias por ser parte de nuestro equipo!";
    case "Promoción":
      return "¡Hola! Tenemos una promoción especial para ti: ";
    case "Otro mensaje":
      return "";
    default:
      return "Mensaje no reconocido.";
  }
}