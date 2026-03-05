import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {

  static Database? _database;

  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await _initDatabase();
    print("✅BASE DE DATOS OBTENIDA CON EXITO");
    return _database!;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null; // <-- Esto es clave
    }
  }

  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'mygym.db');

      return await openDatabase(
        path,
        version: 2,
        onConfigure: (db) async {
          // Habilita llaves foráneas
          await db.execute("PRAGMA foreign_keys = ON;");
        },
        onCreate: (db, version) async {
          // CLIENTES: ahora con borrado lógico (activo INTEGER)
          await db.execute('''
            CREATE TABLE clientes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombres TEXT NOT NULL,
              apellidos TEXT NOT NULL,
              telefono TEXT NOT NULL,
              telefono_emergencia TEXT NOT NULL,
              nombre_emergencia TEXT NOT NULL,
              correo TEXT,
              observaciones TEXT NOT NULL,
              estatus TEXT NOT NULL,
              fotoPath TEXT,
              activo INTEGER DEFAULT 1 -- 1=activo, 0=inactivo (borrado lógico)
            )
          ''');
          // PAGOS: sin ON DELETE CASCADE, mantiene pagos aunque el cliente se borre/inactive
          await db.execute('''
            CREATE TABLE pagos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_cliente INTEGER NOT NULL,
              monto_pago REAL NOT NULL,
              fecha_pago TEXT NOT NULL,
              proxima_fecha_pago TEXT NOT NULL,
              tipo_pago TEXT NOT NULL,
              nombre_disciplina TEXT,
              FOREIGN KEY (id_cliente) REFERENCES clientes(id)
            )
          ''');
          // DISCIPLINAS
          await db.execute('''
            CREATE TABLE disciplinas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              descripcion TEXT,
              activa INTEGER DEFAULT 1
            )
          ''');
          // RELACIÓN CLIENTE-DISCIPLINA
          await db.execute('''
            CREATE TABLE cliente_disciplinas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_cliente INTEGER NOT NULL,
              id_disciplina INTEGER NOT NULL,
              FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE CASCADE,
              FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id) ON DELETE CASCADE
            )
          ''');
          // CONTRASEÑAS: con columna tipo y dos usuarios por defecto
          await db.execute('''
            CREATE TABLE contraseñas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              password TEXT NOT NULL,
              palabra_clave TEXT NOT NULL,
              tipo TEXT NOT NULL -- 'administrador' o 'maestro'
            )
          ''');
          await db.insert('contraseñas', {
            'password': '12345',
            'palabra_clave': 'gimnasio',
            'tipo': 'administrador'
          });
          await db.insert('contraseñas', {
            'password': 'maestro123',
            'palabra_clave': 'gimnasio',
            'tipo': 'maestro'
          });
          // Disciplina por defecto
          int idGeneral = await db.insert("disciplinas", {
            "nombre": "General",
            "descripcion": "Disciplina asignada por defecto",
            "activa": 1
          });
          // Listo: todas las tablas quedan en su estado final, sin migraciones ni reparaciones necesarias.
          print("✅ BASE DE DATOS CREADA CON EXITO");
        },
      );
    }
    catch(e){
      print("❌ ERROR al crear la base de datos: $e");
      rethrow;
    }    
  }

  /// Repara la base de datos para que tenga la estructura consolidada final.
  /// - Agrega columna activo a clientes si no existe.
  /// - Asegura que la FK de pagos a clientes NO tenga ON DELETE CASCADE.
  /// - Agrega columna activa a disciplinas si no existe.
  /// - Asegura que contraseñas tenga columna tipo y ambos usuarios.
  Future<List<String>> repararBD() async {
    final db = await database;
    List<String> acciones = [];
    // 1. Agregar columna activo a clientes si no existe
    final clientesCols = await db.rawQuery("PRAGMA table_info(clientes);");
    final hasActivo = clientesCols.any((col) => col['name'] == 'activo');
    if (!hasActivo) {
      await db.execute("ALTER TABLE clientes ADD COLUMN activo INTEGER DEFAULT 1;");
      acciones.add('Se agregó la columna "activo" a la tabla clientes.');
    } else {
      acciones.add('La columna "activo" ya existía en la tabla clientes.');
    }
    // 2. Asegurar que la FK de pagos a clientes NO tenga ON DELETE CASCADE
    final pagosInfo = await db.rawQuery("PRAGMA foreign_key_list(pagos);");
    final fk = pagosInfo.firstWhere((row) => row['table'] == 'clientes', orElse: () => {});
    if (fk != null && (fk['on_delete']?.toString().toUpperCase() == 'CASCADE')) {
      await db.execute('''
        CREATE TABLE pagos_temp (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_cliente INTEGER NOT NULL,
          monto_pago REAL NOT NULL,
          fecha_pago TEXT NOT NULL,
          proxima_fecha_pago TEXT NOT NULL,
          tipo_pago TEXT NOT NULL,
          nombre_disciplina TEXT,
          FOREIGN KEY (id_cliente) REFERENCES clientes(id)
        );
      ''');
      await db.execute('''
        INSERT INTO pagos_temp (id, id_cliente, monto_pago, fecha_pago, proxima_fecha_pago, tipo_pago, nombre_disciplina)
        SELECT id, id_cliente, monto_pago, fecha_pago, proxima_fecha_pago, tipo_pago, nombre_disciplina FROM pagos;
      ''');
      await db.execute('DROP TABLE pagos;');
      await db.execute('ALTER TABLE pagos_temp RENAME TO pagos;');
      acciones.add('Se recreó la tabla pagos para eliminar ON DELETE CASCADE en la FK a clientes.');
    } else {
      acciones.add('La FK de pagos a clientes ya estaba correcta (sin ON DELETE CASCADE).');
    }
    // 3. Agregar columna activa a disciplinas si no existe
    final discCols = await db.rawQuery("PRAGMA table_info(disciplinas);");
    final hasDiscActiva = discCols.any((col) => col['name'] == 'activa');
    if (!hasDiscActiva) {
      await db.execute("ALTER TABLE disciplinas ADD COLUMN activa INTEGER DEFAULT 1;");
      acciones.add('Se agregó la columna "activa" a la tabla disciplinas.');
    } else {
      acciones.add('La columna "activa" ya existía en la tabla disciplinas.');
    }
    // 4. Reparar contraseñas
    final columns = await db.rawQuery("PRAGMA table_info(contraseñas);");
    final hasTipo = columns.any((col) => col['name'] == 'tipo');
    if (!hasTipo) {
      await db.execute("ALTER TABLE contraseñas ADD COLUMN tipo TEXT;");
      acciones.add('Se agregó la columna "tipo" a la tabla contraseñas.');
    } else {
      acciones.add('La columna "tipo" ya existía en la tabla contraseñas.');
    }
    int updated = await db.update('contraseñas', {'tipo': 'administrador'}, where: "id = 1 AND (tipo IS NULL OR tipo = '')");
    if (updated > 0) {
      acciones.add('Se actualizó el tipo de la contraseña de administrador.');
    }
    final admin = await db.query('contraseñas', where: 'id = 1');
    final palabraClaveAdmin = admin.isNotEmpty ? admin.first['palabra_clave'] : 'gimnasio';
    final maestro = await db.query('contraseñas', where: "tipo = 'maestro'");
    if (maestro.isEmpty) {
      await db.insert('contraseñas', {
        'password': 'maestro123',
        'palabra_clave': palabraClaveAdmin,
        'tipo': 'maestro'
      });
      acciones.add('Se insertó la contraseña de maestro por defecto.');
    }
    return acciones;
  }
}