import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mygym/providers/reportes_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:mygym/utils/pdf_utils_maestros.dart';
import 'package:mygym/utils/seleccionar_fecha.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class FormFiltrosMaestro extends StatefulWidget {
  const FormFiltrosMaestro({super.key});

  @override
  State<FormFiltrosMaestro> createState() => _FormFiltrosMaestroState();
}

class _FormFiltrosMaestroState extends State<FormFiltrosMaestro> {
  final GlobalKey<FormState> formFiltro = GlobalKey<FormState>();

  final List<String> options = ['Todos', 'Efectivo', 'Tarjeta', 'Transferencia'];
  String? valorDropDownButton;

  DateTime? fechaInicio;
  String txtFechaInicio = "Seleccionar";
  DateTime? fechaFin;
  String txtFechaFin = "Seleccionar";

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: formFiltro,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("Enviar reporte:", style: TextStyles.tituloShowModal,  ),
                ),
            
                //LISTA DROPDOWN
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),                
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 0, 132, 255),  
                  ),
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10),
                    dropdownColor: const Color.fromARGB(255, 0, 132, 255),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white,),                  
                    hint: Text("Elige una forma de pago", style: TextStyle(color: Colors.white),),
                    value: valorDropDownButton,
                    items: options.map((String option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: TextStyle(color: Colors.white),)
                      );
                    }).toList(), 
                    onChanged: (String? newValue) {
                      setState(() {
                        valorDropDownButton = newValue;
                      });
                    }
                  ),
                ),
            
                //FECHAS
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //FECHA INICIO
                      Column(
                        children: [
                          Text("Fecha inicio:"),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 132, 255)
                            ),
                            onPressed: () async {
                              fechaInicio = await seleccionarFecha(context);
                              if(fechaInicio != null) {
                                setState(() {
                                  txtFechaInicio = DateFormat('dd-MM-yyyy').format(fechaInicio!);
                                });
                              }
                            }, 
                            child: Text(txtFechaInicio, style: TextStyle(color: Colors.white),)
                          )
                        ],
                      ),
            
                      //FECHA FIN
                      Column(
                        children: [
                          Text("Fecha fin:"),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 132, 255)
                            ),
                            onPressed: () async {
                              fechaFin = await seleccionarFecha(context);
                              if(fechaFin != null) {
                                setState(() {
                                  txtFechaFin = DateFormat('dd-MM-yyyy').format(fechaFin!);
                                });
                              }
                            },
                            child: Text(txtFechaFin, style: TextStyle(color: Colors.white),)
                          )
                        ],
                      )
                    ],
                  ),
                ),
            
                //------------------------------------------------------------BOTON COMPARTIR
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: ElevatedButton.icon(
                    icon: Icon(FontAwesomeIcons.paperPlane, color: Colors.white,),
                    label: Text("Compartir", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 173, 33)
                    ),
                    onPressed: () async {
                      if (fechaInicio != null && fechaFin != null && valorDropDownButton != null) {
                        if (fechaFin!.isBefore(fechaInicio!)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Advertencia"),
                                content: Text("La fecha fin debe ser igual o posterior a la fecha inicio."),
                              );
                            }
                          );
                          return;
                        }

                        // Aplica el filtro según tu lógica actual...
                        if (fechaInicio == fechaFin) {
                          if (valorDropDownButton == "Todos") {
                            Provider.of<ReportesProvider>(context, listen: false)
                                .cargarReportesFiltradosTodosPorFecha(fechaInicio!, fechaFin!);
                          } else {
                            Provider.of<ReportesProvider>(context, listen: false)
                                .cargarReportesFiltrados(valorDropDownButton!, fechaInicio!, fechaFin!);
                          }
                        } else {
                          if (valorDropDownButton == "Todos") {
                            Provider.of<ReportesProvider>(context, listen: false)
                                .cargarReportesFiltradosTodosPorFecha(fechaInicio!, fechaFin!);
                          } else {
                            Provider.of<ReportesProvider>(context, listen: false)
                                .cargarReportesFiltrados(valorDropDownButton!, fechaInicio!, fechaFin!);
                          }
                        }

                        // Espera a que los datos se carguen si es necesario
                        await Future.delayed(Duration(milliseconds: 500));

                        // Genera el PDF y comparte
                        final reportesProvider = Provider.of<ReportesProvider>(context, listen: false);
                        final pdfPath = await exportarReportePDFParaCompartir(reportesProvider);
                        await Share.shareXFiles([XFile(pdfPath)], text: "Reporte de pagos");

                        Navigator.pop(context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Advertencia"),
                              content: Text("Debe seleccionar los campos para aplicar filtro."),
                            );
                          }
                        );
                      }
                    }, 
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}