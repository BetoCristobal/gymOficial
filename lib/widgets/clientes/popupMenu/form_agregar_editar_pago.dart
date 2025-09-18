import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mygym/data/models/pago_model.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:mygym/utils/asignar_estatus.dart';
import 'package:mygym/utils/calcular_dias_restantes.dart';
import 'package:mygym/utils/seleccionar_fecha.dart';
import 'package:provider/provider.dart';

class FormAgregarEditarPago extends StatefulWidget {
  final int idCliente;
  final PagoModel? pagoEditar;
  final bool estaEditando;

  const FormAgregarEditarPago({super.key, required this.idCliente, required this.estaEditando, this.pagoEditar});

  @override
  State<FormAgregarEditarPago> createState() => _FormAgregarEditarPagoState();
}

class _FormAgregarEditarPagoState extends State<FormAgregarEditarPago> {

  final GlobalKey<FormState> formKeyPagos = GlobalKey<FormState>();
  TextEditingController montoController = TextEditingController();

  DateTime? fechaPago;
  String txtFechaPago = "Seleccionar"; 
  DateTime? fechaProximoPago;
  String txtFechaProximoPago = 'Seleccionar';

  final List<String> options = ['Efectivo', 'Tarjeta', 'Transferencia'];
  String? valorDropDownButton;

  @override
  void initState() {
    super.initState();
    if(widget.estaEditando == true) {
      montoController = TextEditingController(text: widget.pagoEditar!.montoPago.toString());

      valorDropDownButton = widget.pagoEditar!.tipoPago;

      fechaPago = widget.pagoEditar!.fechaPago;
      fechaProximoPago = widget.pagoEditar!.proximaFechaPago;

      txtFechaPago = DateFormat("dd-MM-yyyy").format(fechaPago!);
      txtFechaProximoPago = DateFormat("dd-MM-yyyy").format(fechaProximoPago!);
    }
  }
  @override
  Widget build(BuildContext context) {

final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);


    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: formKeyPagos,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(widget.estaEditando == false 
                  ? "Realizar pago:" 
                  : "Actualizar último pago:", style: TextStyles.tituloShowModal, ),
                ),
            
                //CAMPO MONTO
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Monto \$\$\$",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    validator: (value) =>
                      value == null || value.isEmpty ? "Ingrese monto" : null,
                  ),
                ),
            
                //LISTA DROPDOWN TIPO PAGO
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 0, 132, 255),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      underline: SizedBox(), // Elimina la línea debajo del texto
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 132, 255),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                      hint: const Text(
                        "Elige una forma de pago",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: valorDropDownButton,
                      items: options.map((String option) {
                        return DropdownMenuItem<String>(
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
                ),
            
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //FECHA PAGO
                      Column(
                        children: [
                          const Text("Fecha de pago:", style: TextStyle(color: Colors.black87),),                          
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 132, 255)
                            ),
                            onPressed: () async {
                              fechaPago = await seleccionarFecha(context);
                              if(fechaPago != null){
                                setState(() {
                                  txtFechaPago = DateFormat("dd-MM-yyyy").format(fechaPago!);
                                });
                              }
                            }, 
                            child: Text(txtFechaPago, style: TextStyle(color: Colors.white),)
                          ),  
                        ],
                      ),
                              
                      //FECHA PROXIMO PAGO
                      Column(
                        children: [
                          const Text("Próximo pago:", style: TextStyle(color: Colors.black87),),                              
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 132, 255)
                            ),
                            onPressed: () async {
                              fechaProximoPago = await seleccionarFecha(context);
                              if(fechaProximoPago != null && fechaProximoPago!.isAfter(fechaPago!)) {
                                setState(() {
                                  txtFechaProximoPago = DateFormat('dd-MM-yyyy').format(fechaProximoPago!);
                                });
                              } else {
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Advertencia:"),
                                      content: const Text("La fecha de próximo pago debe ser posterior a la fecha de pago.",)
                                    );
                                  }
                                );
                              }
                            }, 
                            child: Text(txtFechaProximoPago, style: TextStyle(color: Colors.white),)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: ElevatedButton.icon(
                    icon: Icon(FontAwesomeIcons.sackDollar, color: Colors.white,),
                    label: Text(widget.estaEditando == false ? "Guardar pago" : "Actualizar pago", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 173, 33)
                    ),
                    onPressed: () async {                                            

                      if(formKeyPagos.currentState!.validate() && fechaPago != null && fechaProximoPago != null && valorDropDownButton != null) {
                        final pagoProvider = Provider.of<PagoProvider>(context, listen: false);
                        int diasRestantes = calcularDiasRestantes(fechaProximoPago!);
                        String estatus = asignarEstatus(diasRestantes, widget.idCliente);
                      
                        if(widget.estaEditando == false) {
                          await pagoProvider.agregarPago(
                            widget.idCliente, 
                            double.parse(montoController.text), 
                            fechaPago!, 
                            fechaProximoPago!, 
                            valorDropDownButton!
                          );
                          await clienteProvider.actualizarEstatusCliente(widget.idCliente, estatus);
                          Navigator.pop(context);
                        } else if(widget.estaEditando == true) {
                          await pagoProvider.actualizarPago(
                            widget.pagoEditar!.id!, 
                            widget.pagoEditar!.idCliente, 
                            double.parse(montoController.text), 
                            fechaPago!, 
                            fechaProximoPago!, 
                            valorDropDownButton!
                          );
                          await clienteProvider.actualizarEstatusCliente(widget.idCliente, estatus);
                          Navigator.pop(context);
                        }
                      } else {
                        showDialog(
                          context: context, 
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Advertencia:"),
                              content: const Text("Debe ingresar monto, tipo de pago y fechas.")
                            );
                          }
                        );
                      }
                    }, 
                    //child: Text(widget.estaEditando == false ? "Guardar pago" : "Actualizar pago", style: TextStyle(color: Colors.white),)
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}