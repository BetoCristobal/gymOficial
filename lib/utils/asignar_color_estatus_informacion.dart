import 'package:flutter/material.dart';

Color asignarColorEstatusInformacion(String estatus) {
  late Color colorFondo = Colors.white;

  switch(estatus) {
    case 'Pago vencido':
      colorFondo = Color.fromARGB(255, 168, 168, 168);
      break;

    case 'Pago urgente':
      colorFondo = Color.fromRGBO(255, 111, 111, 1);
      break;

    case 'Próximo a pagar':
      colorFondo = Color.fromARGB(255, 255, 175, 25);
      break;

    case 'Pago al corriente':
      colorFondo = Color.fromARGB(255, 102, 230, 119);
      break;
  }  
  
  return colorFondo;
}