import 'package:mygym/data/db/database_helper.dart';
import 'package:mygym/data/models/cliente_disciplina_model.dart';

class ClienteDisciplinaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertClienteDisciplina(ClienteDisciplinaModel cd) async {
    final db = await _dbHelper.database;
    await db.insert('cliente_disciplinas', cd.toMap());
  }

  Future<List<int>> getDisciplinasPorCliente(int idCliente) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cliente_disciplinas',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
    );
    return maps.map((map) => map['id_disciplina'] as int).toList();
  }

  Future<List<ClienteDisciplinaModel>> getClienteDisciplinasPorCliente(int idCliente) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cliente_disciplinas',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
    );
    return maps.map((map) => ClienteDisciplinaModel.fromMap(map)).toList();
  }

  Future<void> deleteClienteDisciplina(int id) async {
    final db = await _dbHelper.database;
    await db.delete('cliente_disciplinas', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarPorCliente(int idCliente) async {
  final db = await _dbHelper.database;
  await db.delete('cliente_disciplinas', where: 'id_cliente = ?', whereArgs: [idCliente]);
}



  Future<List<String>> getNombresDisciplinasPorCliente(int idCliente) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT d.nombre
      FROM cliente_disciplinas cd
      JOIN disciplinas d ON cd.id_disciplina = d.id
      WHERE cd.id_cliente = ?
      ''',
      [idCliente],
    );
    return maps.map((map) => map['nombre'] as String).toList();
  }

  
}