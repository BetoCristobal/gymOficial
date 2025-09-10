import 'package:mygym/data/db/database_helper.dart';
import 'package:mygym/data/models/pago_model.dart';

class PagoRepository {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertPago(PagoModel pago) async {
    final db = await _dbHelper.database;
    print(pago);
    await db.insert('pagos', pago.toMap());
  }


  Future<List<PagoModel>> getPagosTodosOrdenadosById() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('pagos', orderBy: 'id DESC');
    return maps.map((map) => PagoModel.fromMap(map)).toList();
  }

  Future<List<PagoModel>> getPagosPorIdCliente(int idCliente) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pagos',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
      orderBy: 'id DESC'
    );
    return maps.map((map) => PagoModel.fromMap(map)).toList();
  }


  Future<void> updatePago(PagoModel pago) async {
    final db = await _dbHelper.database;
    await db.update(
      'pagos', 
      pago.toMap(),
      where: 'id = ?',
      whereArgs: [pago.id]
    );
    print("SE ACTUALIZO EL CLIENTE");
  }


  Future<void> deletePago(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'pagos',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<PagoModel> obtenerUltimoPago(int idCliente) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> pagos = await db.query(
      'pagos',
      where: 'id_Cliente = ?',
      whereArgs: [idCliente],
      orderBy: 'id DESC',
      limit: 1
    );
    return PagoModel.fromMap(pagos.first);

    /*if(pagos.isNotEmpty) {
      return PagoModel.fromMap(pagos.first);
    } else {
      return null;
    }*/
  }
}

