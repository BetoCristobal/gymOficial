import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/utils/enviar%20whatsapp.dart';
import 'package:mygym/widgets/informacion/mensaje_elegido.dart';

void alertDialogWhatsApp(BuildContext context, DateTime proximoPago, String telefono) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController mensajeController = TextEditingController();

      List<String> opciones = ["Recordar pago", "Promoción", "Otro mensaje"];
      String? opcionSeleccionada;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Elige un mensaje:"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //------------------------------------------------CHIPS
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: opciones.map((opcion) {
                      return ChoiceChip(
                        label: Text(opcion, style: TextStyle(color: Colors.green[800]),),
                        selected: opcionSeleccionada == opcion,
                        checkmarkColor: Colors.green[800],
                        selectedColor: Colors.green[100],
                        onSelected: (bool selected) {
                          
                          setState(() {
                            if (opcion == "Recordar pago" && proximoPago.isBefore(DateTime(1901, 1, 1))) {                         
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  content: Text("Aún no tiene pagos registrados"),
                                ),
                              );                            
                            }else {
                              opcionSeleccionada = selected ? opcion : null;
                              mensajeController.text = mensajeElegido(opcionSeleccionada, proximoPago);
                            }
              
                            
                          });
                        },
                      );
                    }).toList(),
                  ),
                        
                  //------------------------------------------------TEXTO PERSONALIZADO
                  TextField(
                    controller: mensajeController,
                    minLines: 6,
                    maxLines: 10,
                    decoration: InputDecoration(
                      // filled: true,
                      // fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey
                        )
                      ),
                    ),
                  ),
                        
                  //------------------------------------------------BOTON WHATSAPP
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(FontAwesomeIcons.paperPlane, color: Colors.green[900],),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[200]
                      ),
                      onPressed: () {
                        enviarWhatsapp(telefono, mensajeController.text);
                      }, 
                      label: Text("Enviar", style: TextStyle(color: Colors.green[900]),)
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}