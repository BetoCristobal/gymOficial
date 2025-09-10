import 'package:flutter/material.dart';
import 'package:mygym/data/models/disciplina_model.dart';
import 'package:mygym/data/repositories/disciplina_repository.dart';

class DisciplinaProvider extends ChangeNotifier {
  final DisciplinaRepository disciplinaRepo;

  List<DisciplinaModel> _disciplinas = [];
  List<DisciplinaModel> get disciplinas => _disciplinas;

  DisciplinaProvider(this.disciplinaRepo);

  Future<void> cargarDisciplinas() async {
    _disciplinas = await disciplinaRepo.getAllDisciplinas();
    notifyListeners();
  }

  Future<void> agregarDisciplina(DisciplinaModel disciplina) async {
    await disciplinaRepo.insertDisciplina(disciplina);
    await cargarDisciplinas();
  }

  Future<void> eliminarDisciplina(int id) async {
    await disciplinaRepo.deleteDisciplina(id);
    await cargarDisciplinas();
  }
}