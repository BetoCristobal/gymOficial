import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/data/models/cliente_disciplina_model.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/providers/cliente_disciplina_provider.dart';
import 'package:mygym/providers/disciplina_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:mygym/widgets/clientes/funciones_foto.dart';
import 'package:provider/provider.dart';
import '../../providers/cliente_provider.dart';

class FormAgregarEditarCliente extends StatefulWidget {
  final ClienteModel? cliente;
  final bool estaEditando;

  const FormAgregarEditarCliente({super.key, this.cliente, required this.estaEditando});

  @override
  State<FormAgregarEditarCliente> createState() => _FormAgregarEditarClienteState();
}

class _FormAgregarEditarClienteState extends State<FormAgregarEditarCliente> {

  List<int> disciplinasSeleccionadas = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nombresController;
  late TextEditingController apellidosController;
  late TextEditingController telefonoController;
  late TextEditingController telefonoEmergenciaController;
  late TextEditingController nombreEmergenciaController;
  late TextEditingController correoController;
  late TextEditingController observacionesController;

  String? _fotoPath;
  File? fotoTemporal;

  @override
  void initState() {
    super.initState();
    _fotoPath = widget.estaEditando == true ? widget.cliente?.fotoPath : null;
    nombresController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.nombres : ""
    );
    apellidosController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.apellidos : ""
    );
    telefonoController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.telefono : ""
    );
    telefonoEmergenciaController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.telefonoEmergencia : ""
    );
    nombreEmergenciaController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.nombreEmergencia : ""
    );
    correoController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.correo : ""
    );
    observacionesController = TextEditingController(
      text: widget.estaEditando == true ? widget.cliente?.observaciones : ""
    );

    // Cargar disciplinas si no están cargadas
    final disciplinaProvider = Provider.of<DisciplinaProvider>(context, listen: false);
    if (disciplinaProvider.disciplinas.isEmpty) {
      disciplinaProvider.cargarDisciplinas();
    }

    // Cargar disciplinas seleccionadas si está editando
    if (widget.estaEditando == true && widget.cliente?.id != null) {
      Future.microtask(() async {
        final clienteDisciplinaProvider = Provider.of<ClienteDisciplinaProvider>(context, listen: false);
        await clienteDisciplinaProvider.cargarPorCliente(widget.cliente!.id!);
        setState(() {
          disciplinasSeleccionadas = clienteDisciplinaProvider.clienteDisciplinas
              .where((cd) => cd.idCliente == widget.cliente!.id)
              .map((cd) => cd.idDisciplina)
              .toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final disciplinas = Provider.of<DisciplinaProvider>(context).disciplinas;

    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: formKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // TITULO
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(widget.estaEditando == false 
                  ? "Agregar cliente" 
                  : "Editar cliente", style: TextStyles.tituloShowModal, ),
                ),
          
                //BOTON TOMAR FOTO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
          
                        //BOTON TOMAR FOTO-------------------------------------------------------------                       
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              iconColor: Color.fromARGB(255, 255, 255, 255),
                            ),
                            onPressed: () async {
                              fotoTemporal = await FuncionesFoto.tomarFotoTemporal();
                        
                              if(fotoTemporal != null) {                                
                                setState(() {
                                  
                                });
                              }
                              print(_fotoPath);
                            }, 
                            child: Icon(Icons.camera_alt, size: 35),
                          ),
                        ),
          
                        // BOTON ELIMINAR FOTO----------------------------------------------------------
                        if(fotoTemporal != null || _fotoPath != null) 
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              iconColor: Color.fromARGB(255, 255, 255, 255),
                            ),
                            onPressed: () async {
                              
                              setState(() {
                                fotoTemporal = null;
                                _fotoPath = null;
                              });
                            }, 
                            child: Icon(Icons.delete_forever_rounded, size: 35),
                          ),
                        ),
                      ],
                    ),
                    // IMAGEN FOTO ----------------------------------------------------------------------
                    fotoTemporal != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.file(fotoTemporal!, width: 150, height: 150, fit: BoxFit.cover,))
                      : (_fotoPath != null && File(_fotoPath!).existsSync()
                        ? ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.file(File(_fotoPath!), width: 150, height:  150, fit: BoxFit.cover,))
                        : const Icon(Icons.person, size: 150,)
                      )
                  ],
                ),
          
                // CAMPO NOMBRES
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: nombresController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Nombres (obligatorio)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),
                    validator: (value) => 
                      value == null || value.isEmpty ? "Ingrese nombres" : null,
                  ),
                ),
            
                // CAMPO APELLIDOS
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: apellidosController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Apellidos (obligatorio)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),
                    validator: (value) => 
                      value == null || value.isEmpty ? "Ingrese apellidos" : null,
                  ),
                ),
            
                // CAMPO TELEFONO PERSONAL
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Teléfono personal (obligatorio)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      if(value == null || value.isEmpty) {
                        return "Ingrese teléfono personal";
                      } else if(value.length != 10) {
                        return "Ingrese un numero con 10 dígitos";
                      }
                      return null;
                    }
                  ),
                ),
                
                // CAMPO TELEFONO EMERGENCIA
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: telefonoEmergenciaController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Teléfono de emergencia",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    // validator: (value) {
                    //   if(value == null || value.isEmpty) {
                    //     return "Ingrese teléfono de emergencia";
                    //   } else if(value.length != 10) {
                    //     return "Ingrese un numero con 10 dígitos";
                    //   }
                    //   return null;
                    // }
                  ),
                ),  
                
                // CAMPO NOMBRE EMERGENCIA
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: nombreEmergenciaController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Nombre de contacto de emergencia",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),                      
                    // validator: (value) => 
                    //   value == null || value.isEmpty ? "Ingrese nombre de contacto de emergencia" : null,
                  ),
                ),
                
                // CAMPO CORREO
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),                      
                    // validator: (value) => 
                    //   value == null || value.isEmpty ? "Ingrese correo electrónico" : null,
                  ),
                ),
                
                // CAMPO OBSERVACIONES
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: TextFormField(
                    controller: observacionesController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: "Observaciones",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 1)
                      )
                    ),                      
                    // validator: (value) => 
                    //   value == null || value.isEmpty ? "Ingrese observaciones a considerar" : null,
                  ),
                ),
                
                //-------------------------------------------SELECT DISCIPLINAS
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Disciplinas", style: TextStyle(fontWeight: FontWeight.bold)),
                      if (disciplinas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "No hay disciplinas registradas",
                            style: TextStyle(color: Colors.grey,),
                          ),
                        ),
                      if (disciplinas.isNotEmpty)
                        ...disciplinas.map((disciplina) => CheckboxListTile(
                              title: Text(disciplina.nombre),
                              value: disciplinasSeleccionadas.contains(disciplina.id),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    disciplinasSeleccionadas.add(disciplina.id!);
                                  } else {
                                    disciplinasSeleccionadas.remove(disciplina.id);
                                  }
                                });
                              },
                            )),
                    ],
                  ),
                ),            
            
                // BOTON GUARDAR
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(                        
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.cancel, color: Colors.white,),
                            onPressed: () {
                              Navigator.pop(context);
                            }, 
                            label: Text("Cancelar", style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red
                            ),
                          )
                        ),
                      ),
                  
                      SizedBox(width: 10,),
                  
                      Expanded(
                        child: Container(
                          child: ElevatedButton.icon(
                            icon: Icon(FontAwesomeIcons.floppyDisk, color: Colors.white,),
                            label: Text(widget.estaEditando == false ? "Guardar" : "Actualizar", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 29, 173, 33)
                            ),
                            onPressed: () async {
                              if(formKey.currentState!.validate()) {
                                //OBTENEMOS PROVIDER
                                final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
                                    
                                if (fotoTemporal != null) {
                                  _fotoPath = await FuncionesFoto.guardarFoto(fotoTemporal!);
                                }
                                
                                // SI NO ESTA EDITANDO, OSEA SI SE ESTA AGREGANDO NUEVO CLIENTE
                                if(widget.estaEditando == false) {
                                  final nuevoClienteId = await clienteProvider.agregarCliente(
                                    nombresController.text, 
                                    apellidosController.text, 
                                    telefonoController.text,
                                    _fotoPath,
                                    telefonoEmergenciaController.text,
                                    nombreEmergenciaController.text,
                                    correoController.text,
                                    observacionesController.text                            
                                  );
                  
                                  // Guarda las disciplinas seleccionadas
                                  for (final idDisciplina in disciplinasSeleccionadas) {
                                    await Provider.of<ClienteDisciplinaProvider>(context, listen: false)
                                        .agregarClienteDisciplina(ClienteDisciplinaModel(
                                          idCliente: nuevoClienteId!, // el id del cliente recién creado
                                          idDisciplina: idDisciplina,
                                        ));
                                  }
                                    
                                  Navigator.pop(context);
                                } else if(widget.estaEditando == true) {
                                  int? id = widget.cliente?.id;
                                    
                                  //VERIFICAMOS SI HAY UNA FOTO ANTERIOR, SI SI HAY LA BORRAMOS
                                  if(_fotoPath != null && widget.cliente?.fotoPath != null) {
                                    if(_fotoPath != widget.cliente!.fotoPath) {
                                      final fotoAnterior = File(widget.cliente!.fotoPath!);
                                      if(await fotoAnterior.exists()) {
                                        await fotoAnterior.delete();
                                        print("❌ Foto anterior eliminada: ${widget.cliente!.fotoPath}");
                                      } 
                                    }
                                  } else if (_fotoPath == null && widget.cliente?.fotoPath != null) {
                                    final fotoAnterior = File(widget.cliente!.fotoPath!);
                                    if(await fotoAnterior.exists()) {
                                      await fotoAnterior.delete();
                                      print("❌ Foto anterior eliminada: ${widget.cliente!.fotoPath}");
                                    }
                                  }
                                    
                                  await clienteProvider.actualizarCliente(
                                    id!,
                                    nombresController.text, 
                                    apellidosController.text, 
                                    telefonoController.text,
                                    widget.cliente!.estatus,
                                    _fotoPath, // Si se actualiza la foto, se pasa la nueva ruta
                                    telefonoEmergenciaController.text,
                                    nombreEmergenciaController.text,
                                    correoController.text,
                                    observacionesController.text
                                  );
                  
                                  // ACTUALIZA DISCIPLINAS DEL CLIENTE
                                  final clienteDisciplinaProvider = Provider.of<ClienteDisciplinaProvider>(context, listen: false);
                                  // Elimina todas las disciplinas actuales del cliente
                                  await clienteDisciplinaProvider.eliminarPorCliente(id);
                  
                                  // Agrega las disciplinas seleccionadas
                                  for (final idDisciplina in disciplinasSeleccionadas) {
                                    await clienteDisciplinaProvider.agregarClienteDisciplina(
                                      ClienteDisciplinaModel(
                                        idCliente: id,
                                        idDisciplina: idDisciplina,
                                      ),
                                    );
                                  }
                  
                                  Navigator.pop(context);                                  
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(widget.estaEditando == false ? "👌Cliente guardado" : "👌Cliente actualizado")),
                                );
                              }
                            }, 
                          ),
                        ),
                      ),                      
                    ],
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