

import 'package:flutter/material.dart';

//--------------------------------------------SELECCIONAR FECHA FORM
Future<DateTime?> seleccionarFecha(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020), 
    lastDate: DateTime(2100)
  );
  return picked;
}



