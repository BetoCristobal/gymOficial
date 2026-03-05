import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/data/repositories/cliente_repository.dart';
import 'package:mygym/views/ver_fotos.dart';

enum Opciones {todos, vencidos, urgentes, proximos, corrientes}

class ClienteProvider extends ChangeNotifier{
  //Inyección de Dependencias:
  //Requiere que se pase una instancia de ClienteRepository al crear el Provider.
  final ClienteRepository clienteRepo;

  List<ClienteModel> _clientes = [];
  List<ClienteModel> _clientesFiltrados = [];
  String _busqueda = "";
  

  ClienteProvider(this.clienteRepo) {
    cargarClientes();
  }

  List<ClienteModel> get clientes => _clientes;
  List<ClienteModel> get clientesFiltrados => _clientesFiltrados;
  String get busqueda => _busqueda;

  set clientesFiltrados(List<ClienteModel> value) {
    _clientesFiltrados = value;
    notifyListeners();
  }

  Future<void> cargarClientes() async {    
    try{      
      _clientes = await clienteRepo.getClientesOrdenadosById();
      aplicarFiltro();
      notifyListeners();  
    } catch(e){
      print("❌ Error al cargar clientes: $e");
    }            
  }

  Future<int?> agregarCliente(
    String nombres, 
    String apellidos, 
    String telefono, 
    String? fotoPath, 
    String telefonoEmergencia, 
    String nombreEmergencia, 
    String correo, 
    String observaciones) async {
    try {
      final nuevoCliente = ClienteModel(
      nombres: nombres, 
      apellidos: apellidos, 
      telefono: telefono, 
      estatus: "vencido",
      fotoPath: fotoPath, //Ruta de la foto del cliente
      //Estatus: corriente, vencido, urgente, proximo.
      telefonoEmergencia: telefonoEmergencia, 
      nombreEmergencia: nombreEmergencia,
      correo: correo,
      observaciones: observaciones
      );
      final id = await clienteRepo.insertCliente(nuevoCliente);
      print("Se agrego cliente a la BD ${nuevoCliente}");
      await cargarClientes();
      return id;

    }catch(e) {
      print("❌ Error al agregar cliente: $e");
    }
  }

  Future<void> actualizarCliente(
    int id, 
    String nombres, 
    String apellidos, 
    String telefono, 
    String estatus, 
    String? fotoPath, 
    String telefonoEmergencia, 
    String nombreEmergencia, 
    String correo, 
    String observaciones) async {
    try {
      final clienteActualizado = ClienteModel(
        id: id,
        nombres: nombres, 
        apellidos: apellidos, 
        telefono: telefono, 
        estatus: estatus,
        fotoPath: fotoPath, //Ruta de la foto del cliente
        telefonoEmergencia: telefonoEmergencia, 
        nombreEmergencia: nombreEmergencia,
        correo: correo,
        observaciones: observaciones
      );
      await clienteRepo.updateCliente(clienteActualizado);      
      //notifyListeners();
      await cargarClientes();
    } catch(e) {
      print("❌ Error al actualizar cliente: $e");
    }
  }

  Future<void> actualizarEstatusCliente(int id, String estatus) async {
    try{
      await clienteRepo.updateEstatusCliente(id, estatus);
      //notifyListeners();
      await cargarClientes();
    } catch(e){
      print("❌ Error al actualizar ESTATUS: $e");
    }
  }

  Future<void> desactivarCliente(int id) async {
    try{
      await clienteRepo.desactivarCliente(id);
      await cargarClientes();
    } catch(e) {
      print("❌ Error al desactivar cliente: $e");
    }
  }

  
  Opciones opcionesView = Opciones.todos;
  List<bool> isSelected = [true, false, false, false, false];

  void toggleButton(int index){
    for(int i = 0; i < isSelected.length; i++){
      isSelected[i] = (i == index);
    }
    opcionesView = Opciones.values[index];
    cargarClientes();
    notifyListeners();
  }

  void aplicarFiltro() {
    switch(opcionesView) {
      case Opciones.todos:
        _clientesFiltrados = _clientes.where((c) => c.activo == 1).toList();
      break;

      case Opciones.vencidos:
        _clientesFiltrados = _clientes.where((c) => c.activo == 1 && c.estatus == "Pago vencido").toList();
      break;

      case Opciones.urgentes:
        _clientesFiltrados = _clientes.where((c) => c.activo == 1 && c.estatus == "Pago urgente").toList();
      break;

      case Opciones.proximos:
        _clientesFiltrados = _clientes.where((c) => c.activo == 1 && c.estatus == "Próximo a pagar").toList();
      break;

      case Opciones.corrientes:
        _clientesFiltrados = _clientes.where((c) => c.activo == 1 && c.estatus == "Pago al corriente").toList();
      break;
    }
    notifyListeners();
  }

  String normalizar(String texto) {
    final withTilde = texto.toLowerCase();
    const acentos = 'áéíóúüñ';
    const sinAcentos = 'aeiouun';

    String result = '';
    for (int i = 0; i < withTilde.length; i++) {
      int index = acentos.indexOf(withTilde[i]);
      result += (index >= 0) ? sinAcentos[index] : withTilde[i];
    }
    return result;
  }

  void filtrarClientesPorNombresApellidos(String query) {
    _busqueda = query;
    if(query.isEmpty) {
      aplicarFiltro();
    } else {
      // En búsqueda, mostrar todos (activos e inactivos) que coincidan
      final listaBase = _clientes;
      _clientesFiltrados = listaBase.where((cliente) {
        final nombreCompleto = normalizar('${cliente.nombres} ${cliente.apellidos}');
        final consulta = normalizar(query);
        return nombreCompleto.contains(consulta);
      }).toList();
      notifyListeners();
    }
  }

  ClienteModel? filtrarClientesPorIds(List<int> idsClientes) {
    _clientesFiltrados = _clientes.where((cliente) => idsClientes.contains(cliente.id)).toList();
    notifyListeners();
  }

  Future<void> reactivarCliente(int id) async {
    try{
      await clienteRepo.reactivarCliente(id);
      await cargarClientes();
    } catch(e) {
      print("❌ Error al reactivar cliente: $e");
    }
  }

  // Future<ClienteModel?> consultarPorNombreYApellidos(String query) async {
  //   if (query.isEmpty) return null;
  //   final consulta = normalizar(query);
  //   for (final cliente in _clientes) {
  //     if (normalizar('${cliente.nombres} ${cliente.apellidos}') == consulta) {
  //       return cliente;
  //     }
  //   }
  //   return null;
  // }
}