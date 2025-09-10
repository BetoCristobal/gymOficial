import 'package:flutter/material.dart';

LinearGradient asignarColorFondoCardCliente(String estatus) {  
  late Color color1 = Colors.white;
  late Color color2 = Colors.white;

  switch(estatus) {
    case 'Pago vencido':
      color1 = Color.fromARGB(255, 73, 73, 73);
      color2 = Color.fromARGB(255, 168, 168, 168);
      break;

    case 'Pago urgente':
      color1 = Color.fromARGB(255, 194, 29, 29);
      color2 = Color.fromRGBO(255, 111, 111, 1);
      break;

    case 'Próximo a pagar':
      color1 = Color.fromARGB(255, 206, 134, 0);
      color2 = Color.fromARGB(255, 255, 199, 126);
      break;

    case 'Pago al corriente':
      color1 = Color.fromARGB(255, 20, 124, 20);
      color2 = Color.fromARGB(255, 0, 253, 42);
      break;
  } 

  
  return LinearGradient(
    colors: [color1, color2],
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight
  );
}