import 'package:flutter/material.dart';
import 'package:mygym/data/models/cliente_disciplina_model.dart';
import 'package:mygym/data/repositories/cliente_disciplina_repository.dart';

class ClienteDisciplinaProvider extends ChangeNotifier {
  final ClienteDisciplinaRepository repo;

  List<ClienteDisciplinaModel> _clienteDisciplinas = [];
  List<ClienteDisciplinaModel> get clienteDisciplinas => _clienteDisciplinas;

  ClienteDisciplinaProvider(this.repo);

  Future<void> cargarPorCliente(int idCliente) async {
    _clienteDisciplinas = await repo.getClienteDisciplinasPorCliente(idCliente);
    notifyListeners();
  }

  Future<void> agregarClienteDisciplina(ClienteDisciplinaModel cd) async {
    await repo.insertClienteDisciplina(cd);
    await cargarPorCliente(cd.idCliente);
  }

  Future<void> eliminarClienteDisciplina(int id) async {
    await repo.deleteClienteDisciplina(id);
    // Opcional: recargar lista si tienes el idCliente
    // await cargarPorCliente(idCliente);
    notifyListeners();
  }

  Future<void> eliminarPorCliente(int idCliente) async {
  await repo.eliminarPorCliente(idCliente);
  await cargarPorCliente(idCliente);
  notifyListeners();
}
}