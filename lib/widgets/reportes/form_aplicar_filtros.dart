import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mygym/providers/disciplina_provider.dart';
import 'package:mygym/providers/reportes_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:mygym/utils/seleccionar_fecha.dart';
import 'package:provider/provider.dart';

class FormAplicarFiltros extends StatefulWidget {
  const FormAplicarFiltros({super.key});

  @override
  State<FormAplicarFiltros> createState() => _FormAplicarFiltrosState();
}

class _FormAplicarFiltrosState extends State<FormAplicarFiltros> {

  final GlobalKey<FormState> formFiltro = GlobalKey<FormState>();

  final List<String> options = ['Todos', 'Efectivo', 'Tarjeta', 'Transferencia'];
  String? valorDropDownButton;

  String? valorDropDownDisciplina;

  DateTime? fechaInicio;
  String txtFechaInicio = "Seleccionar";
  DateTime? fechaFin;
  String txtFechaFin = "Seleccionar";

  @override
  Widget build(BuildContext context) {

    final todasDisciplinas = Provider.of<DisciplinaProvider>(context).disciplinas;

    final List<String> optionDisciplinas = ['Todas', ...todasDisciplinas.map((d) => d.nombre)];
    

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
                  child: Text("Aplicar filtro:", style: TextStyles.tituloShowModal,  ),
                ),
            
                //LISTA DROPDOWN DISCIPLINAS  
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),                
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 0, 132, 255),  
                  ),
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    underline: SizedBox(),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 132, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 132, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    ),
                    hint: Text("Elige una disciplina", style: TextStyle(color: Colors.white)),
                    value: valorDropDownDisciplina,
                    items: optionDisciplinas.map((String option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        valorDropDownDisciplina = newValue;
                      });
                    },
                  ),
                ),
                //LISTA DROPDOWN FORMA DE PAGO
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),                
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 0, 132, 255),  
                  ),
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    underline: SizedBox(),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 132, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 132, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    ),
                    hint: Text("Elige una forma de pago", style: TextStyle(color: Colors.white)),
                    value: valorDropDownButton,
                    items: options.map((String option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        valorDropDownButton = newValue;
                      });
                    },
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
                              if (fechaFin != null && fechaInicio != null &&
                                  (fechaFin!.isAfter(fechaInicio!) || fechaFin!.isAtSameMomentAs(fechaInicio!))) {
                                setState(() {
                                  txtFechaFin = DateFormat('dd-MM-yyyy').format(fechaFin!);
                                });
                              } else {
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Advertencia"),
                                      content: Text("La fecha fin debe ser igual o posterior a la fecha inicio."),
                                    );
                                  }
                                );
                              }
                            },
                            child: Text(txtFechaFin, style: TextStyle(color: Colors.white),)
                          )
                        ],
                      )
                    ],
                  ),
                ),
            
                //BOTON APLICAR
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: ElevatedButton.icon(
                    icon: Icon(FontAwesomeIcons.check, color: Colors.white,),
                    label: Text("Aplicar", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 173, 33)
                    ),
                    onPressed: () {
                      if (valorDropDownDisciplina == null ||
                          valorDropDownButton == null ||
                          fechaInicio == null ||
                          fechaFin == null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Advertencia"),
                              content: Text("Debe seleccionar disciplina, forma de pago y ambas fechas para aplicar el filtro."),
                            );
                          }
                        );
                        return;
                      }

                      Provider.of<ReportesProvider>(context, listen: false).cargarReportesCombinados(
                        disciplina: valorDropDownDisciplina!,
                        tipoPago: valorDropDownButton!,
                        fechaInicio: fechaInicio!,
                        fechaFin: fechaFin!,
                      );
                      Navigator.pop(context);
                      // if(fechaInicio != null && fechaFin != null && valorDropDownButton != null && valorDropDownDisciplina != null) {
                      //   print("FILTROS APLICADOS");
                      //   if(valorDropDownButton == "Todos") {
                      //     Provider.of<ReportesProvider>(context, listen: false).cargarReportesFiltradosTodosPorFecha(fechaInicio!, fechaFin!);
                      //     Navigator.pop(context);
                      //   } else {
                      //     Provider.of<ReportesProvider>(context, listen: false).cargarReportesFiltrados(valorDropDownButton!, fechaInicio!, fechaFin!);
                      //     Navigator.pop(context);
                      //   }                      
                      // } else {
                      //   showDialog(
                      //     context: context, 
                      //     builder: (BuildContext context) {
                      //       return AlertDialog(
                      //         title: Text("Advertencia"),
                      //         content: Text("Debe seleccionar los campos para aplicar filtro."),
                      //       );
                      //     }
                      //   );
                      // }
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