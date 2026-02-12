import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/data/models/pago_model.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:mygym/utils/asignar_color_fondo_card_cliente.dart';
import 'package:mygym/utils/asignar_emoji.dart';
import 'package:mygym/utils/asignar_estatus.dart';
import 'package:mygym/utils/calcular_dias_restantes.dart';
import 'package:mygym/views/informacion_screen.dart';
import 'package:mygym/widgets/clientes/popupMenu/form_agregar_editar_pago.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ClienteCard extends StatelessWidget {
  final List<String> disciplinas;
  final ClienteModel cliente;
  final PagoModel ultimoPago;

  const ClienteCard({super.key, required this.cliente, required this.ultimoPago, required this.disciplinas});  

  @override
  Widget build(BuildContext context) { 

    //CONTROLADOR PARA CAPTURAR EL QR GENERADO Y GUARDARLO EN LA GALERIA DEL DISPOSITIVO
    final ScreenshotController screenshotController = ScreenshotController();  

    //Funcion para guardar el QR en la galeria del dispositivo
    Future<void> _exportQr() async {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        // Guarda la imagen en un archivo temporal
        final tempDir = await getTemporaryDirectory();
        final fileName = "QR_${cliente.nombres}_${cliente.apellidos}".replaceAll(" ", "_") + ".png";
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(image);

        // Comparte la imagen usando share_plus
        await Share.shareXFiles([XFile(file.path)], text: "QR de ${cliente.nombres} ${cliente.apellidos}");
      }
    }

    String txtFechaPago;
    String txtProximaFechaPago;
    if(ultimoPago.idCliente != 100000) {
      txtFechaPago = DateFormat("dd-MM-yyyy").format(ultimoPago.fechaPago);
      txtProximaFechaPago = DateFormat("dd-MM-yyyy").format(ultimoPago.proximaFechaPago);
    }else {
      txtFechaPago ="Falta pago";
      txtProximaFechaPago ="Falta pago";
    }

    int diasRestantes = calcularDiasRestantes(ultimoPago.proximaFechaPago);
    String estatus = asignarEstatus(diasRestantes, cliente.id!);

    if(cliente.estatus != estatus)  {
      final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
      clienteProvider.actualizarEstatusCliente(cliente.id!, estatus);
    }
    
    LinearGradient fondoCard = asignarColorFondoCardCliente(estatus);
    String emoji = asignarEmoji(estatus);
    
    return Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                gradient: fondoCard
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(emoji),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Text("${cliente.nombres} ${cliente.apellidos}", 
                            style: TextStyles.textoCardCliente,
                            softWrap: true,
                            maxLines: 2,                            
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code, color: Colors.white),
                          tooltip: "Mostrar QR",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Código QR"),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("${cliente.nombres} ${cliente.apellidos}"),
                                      //SizedBox(height: 10),
                                      SizedBox(
                                        width: 180,
                                        height: 180,
                                        child: Screenshot(
                                          controller: screenshotController,
                                          child: Container(
                                            color: Colors.white,
                                            child: QrImageView(
                                              data: "${cliente.nombres} ${cliente.apellidos}",
                                              version: QrVersions.auto,
                                              size: 180,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Exportar"),
                                    onPressed: () async {
                                      await _exportQr();
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Cerrar"),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),                    
                                
                    Divider(color: Colors.white, height: 5,),                    
                                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pago: $txtFechaPago", style: TextStyles.textoCardCliente),
                            Text("Prox. pago: $txtProximaFechaPago", style: TextStyles.textoCardCliente),
                            Visibility(visible: ultimoPago.idCliente == 100000 ? false : true, 
                              child: Text('Días restantes: $diasRestantes', style: TextStyles.textoCardCliente)),                             
                          ],
                        ),

                        PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) async {
                        switch(value) {
                          case 'ver_informacion':
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => InformacionScreen(clienteId: cliente.id!, ultimoPago: ultimoPago,)));                            
                            break;  
                  
                          case 'realizar_pago':
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context, 
                              builder: (BuildContext context) {
                                return FormAgregarEditarPago(
                                  idCliente: cliente.id!, 
                                  estaEditando: false,
                                  disciplinas: disciplinas,);
                              }
                            );
                            break;                  
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: "ver_informacion",
                            child: Text("Ver información")
                          ),
                          PopupMenuItem(
                            value: "realizar_pago",
                            child: Text("Realizar pago")
                          ),                          
                        ];
                      }
                    ),

                    
                      ],
                    ), 
                    if (disciplinas.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 6,
                          children: disciplinas.map((nombre) => Chip(label: Text(nombre))).toList(),
                        ),
                      ),
                    if (disciplinas.isEmpty)
                      Text("Sin disciplinas", style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
                  ],
                ),
              ),
            ),
          );
  }
}