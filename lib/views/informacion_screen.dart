import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/data/models/pago_model.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:mygym/utils/asignar_color_estatus_informacion.dart';
import 'package:mygym/widgets/clientes/form_agregar_editar_cliente.dart';
import 'package:mygym/widgets/clientes/popupMenu/alert_dialog_eliminar_cliente.dart';
import 'package:mygym/widgets/clientes/popupMenu/alert_dialog_eliminar_pago.dart';
import 'package:mygym/widgets/clientes/popupMenu/form_agregar_editar_pago.dart';
import 'package:mygym/widgets/informacion/alert_dialog_whatsapp.dart';
import 'package:provider/provider.dart';

class InformacionScreen extends StatefulWidget {

  final int clienteId;
  final PagoModel ultimoPago;

  const InformacionScreen({super.key, required this.clienteId, int? cliente, required this.ultimoPago});

  @override
  State<InformacionScreen> createState() => _InformacionScreenState();
}

class _InformacionScreenState extends State<InformacionScreen> {

  @override
  void initState() {
    super.initState();
    Provider.of<PagoProvider>(context, listen: false)
          .cargarPagosClientePorId(widget.clienteId);  }

  @override
  Widget build(BuildContext context) {

    final clienteProvider = Provider.of<ClienteProvider>(context);
    ClienteModel cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere((c) => c.id == widget.clienteId);
    } catch (e) {
      Future.microtask(() {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(); // Pantalla vacía temporalmente
    }  

    return Scaffold(
      appBar: AppBar(
        title: const Text("Información"),
        titleTextStyle: TextStyle(fontSize: 23, color: Colors.white),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: asignarColorEstatusInformacion(cliente.estatus)
            ),
            child: Text(
              "${cliente.estatus}",
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold), 
              textAlign: TextAlign.center,
            )
          ),
        ],
      ),
      body: Column(
        children: [       
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 0,),
            child: Consumer<ClienteProvider>(
              builder: (context, clienteProvider, _) {
                return Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      //----------------------------------------------------NOMBRE
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                            "${cliente.nombres} ${cliente.apellidos}", 
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),

                      Row(
                        children: [                                  
                          Column(
                            children: [
                              
                              //--------------------------------------------------FOTO
                              cliente.fotoPath != null && cliente.fotoPath!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  File(cliente.fotoPath!),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  ),
                              )
                              : const Icon(Icons.person, size: 150),
                            ],
                          ),
                                  
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [                    
                                //---------------------------------------------------------BOTON WHATSAPP
                                ElevatedButton.icon(
                                  icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green[900]),
                                  onPressed: () {
                                    alertDialogWhatsApp(context, widget.ultimoPago.proximaFechaPago, cliente.telefono);
                                    //enviarWhatsapp(widget.ultimoPago.proximaFechaPago, cliente.telefono);
                                  }, 
                                  label: Text("WhatsApp"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[200],
                                    foregroundColor: Colors.green[900],
                                  ),
                                ),
                      
                                //---------------------------------------------------------BOTON AGREGAR PAGO
                                ElevatedButton.icon(
                                  icon: Icon(FontAwesomeIcons.circleDollarToSlot, color: Colors.purple[900]),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context, 
                                      builder: (BuildContext context) {
                                        return FormAgregarEditarPago(idCliente: cliente.id!, estaEditando: false,);
                                      }
                                    );
                                  }, 
                                  label: Text("Agregar pago"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[200],
                                    foregroundColor: Colors.purple[900],
                                  ),
                                ),
                      
                                //---------------------------------------------------------BOTON EDITAR CLIENTE
                                ElevatedButton.icon(
                                  icon: Icon(FontAwesomeIcons.userPen, color: Colors.blue[900]),
                                  onPressed: () {
                                    showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context, 
                                    builder: (BuildContext context) {
                                      return FormAgregarEditarCliente(estaEditando: true, cliente: cliente,);
                                    }
                                  );
                                  }, 
                                  label: Text("Editar cliente"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[200],
                                    foregroundColor: Colors.blue[900],
                                  ),
                                ),
                      
                                //---------------------------------------------------------BOTON ELIMINAR CLIENTE
                                ElevatedButton.icon(
                                  icon: Icon(FontAwesomeIcons.xmark, color: Colors.red[900]),
                                  onPressed: () async {
                                      final resultado = await AlertDialogEliminarCliente(context, cliente.id!);
                                      if(resultado == true) {
                                        await clienteProvider.eliminarCliente(cliente.id!);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("❌Cliente eliminado")),
                                        ); 
                                      }
                                    }, 
                                  label: Text("Eliminar cliente"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[200],
                                    foregroundColor: Colors.red[900],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],              
                      ),
                    ],
                  ),
                ),
              );
              },            
            ),
          ),
          //---------------------------------------------------------TEXTO INFORMACION ADICIONAL
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text("Pagos", style: TextStyles.tituloShowModal,),
          ),
          Expanded(
            child: Consumer<PagoProvider>(
              builder: (context, pagoProvider, _) {
                
                if(pagoProvider.pagosPorCliente.isEmpty) {
                  Center(child: Text("No hay pagos registrados"),);
                }

                return DataTable2(
                columnSpacing: 10,
                horizontalMargin: 10,
                minWidth: 450,
                columns: [
                  DataColumn2(label: Text("Fecha \nde pago:"),),
                  DataColumn2(label: Text("Próximo \npago:"),),
                  DataColumn2(label: Text("Monto:"),),
                  DataColumn2(label: Text("Tipo:"),),
                  DataColumn2(label: Text("Editar:"),),
                  DataColumn2(label: Text("Eliminar:"),),
                ], 
                rows: pagoProvider.pagosPorCliente.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reporte = entry.value;

                  final pago = pagoProvider.pagosPorCliente[index];

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        // Alternar colores claros para mejorar la legibilidad
                        return index % 2 == 0 ? Colors.grey.shade200 : Colors.white;
                      },
                    ),
                    cells: [
                      DataCell(Text(DateFormat("dd-MM-yy").format(reporte.fechaPago))),
                      DataCell(Text(DateFormat("dd-MM-yy").format(reporte.proximaFechaPago))),
                      DataCell(Text("\$${reporte.montoPago}")),
                      DataCell(Text(reporte.tipoPago)),
                      DataCell(IconButton(
                        icon: Icon(FontAwesomeIcons.penToSquare, color: Colors.blue[900]),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context, 
                            builder: (BuildContext context) {
                              return FormAgregarEditarPago(
                                idCliente: cliente.id!, 
                                estaEditando: true, 
                                pagoEditar: reporte,
                              );
                            }
                          );
                        },
                      )),
                      DataCell(IconButton(
                        icon: Icon(FontAwesomeIcons.trash, color: Colors.red[400]),
                        onPressed: () {
                          AlertDialogEliminarPago(context, pago.id!, reporte.idCliente);
                        },
                      )),
                    ]
                  );
                }).toList()
              );
              }              
            )
          )
        ],
      ),
    );
  }
}

