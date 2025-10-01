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

  Future<void> guardarCredenciales(String password, String palabraClave) async {
    final db = await database;
    await db.insert(
      'contraseñas',
      {
        'password': password,
        'palabra_clave': palabraClave,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'mygym.db');

      return await openDatabase(
        path,
        version: 1,
        onConfigure: (db) async {
          //HABILITAN LLAVES FORANEAS 
          await db.execute("PRAGMA foreign_keys = ON;");
        },
        onCreate: (db, version) async {
          await db.execute(
            '''
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
            fotoPath TEXT
            )
            '''
          );

          await db.execute(
            '''
            CREATE TABLE pagos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_cliente INTEGER NOT NULL,
            monto_pago REAL NOT NULL,
            fecha_pago TEXT NOT NULL,
            proxima_fecha_pago TEXT NOT NULL,
            tipo_pago TEXT NOT NULL,
            FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE CASCADE
            )
            '''
          );

          await db.execute(
            '''
            CREATE TABLE disciplinas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            descripcion TEXT
            )
            '''
          );

          await db.execute(
            '''
            CREATE TABLE cliente_disciplinas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_cliente INTEGER NOT NULL,
            id_disciplina INTEGER NOT NULL,
            FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE CASCADE,
            FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id) ON DELETE CASCADE
            )
            '''
          );

          await db.execute(
            '''
            CREATE TABLE contraseñas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              password TEXT NOT NULL,
              palabra_clave TEXT NOT NULL
            )
            '''
          );
          // Inserta una contraseña por defecto (puedes cambiarla luego)
          //await db.insert('contraseñas', {'password': '12345', 'palabra_clave': 'gimnasio'});

          print("✅ BASE DE DATOS CREADA CON EXITO");//--------------------
        },
      );
    }
    catch(e){
      print("❌ ERROR al crear la base de datos: $e");
      rethrow;
    }    
  }
}