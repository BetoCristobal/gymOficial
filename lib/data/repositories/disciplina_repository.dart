import 'package:mygym/data/db/database_helper.dart';
import 'package:mygym/data/models/disciplina_model.dart';

class DisciplinaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertDisciplina(DisciplinaModel disciplina) async {
    final db = await _dbHelper.database;
    await db.insert('disciplinas', disciplina.toMap());
  }

  Future<List<DisciplinaModel>> getAllDisciplinas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('disciplinas');
    return maps.map((map) => DisciplinaModel.fromMap(map)).toList();
  }

  Future<void> deleteDisciplina(int id) async {
    final db = await _dbHelper.database;
    await db.delete('disciplinas', where: 'id = ?', whereArgs: [id]);
  }
}