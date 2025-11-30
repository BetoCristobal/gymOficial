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
          await db.insert('contraseñas', {'password': '12345', 'palabra_clave': 'gimnasio'});

          print("✅ BASE DE DATOS CREADA CON EXITO");//--------------------
        },

        // -------------------------------------------------------------
        // 🔥🔥🔥 MIGRACIONES
        // -------------------------------------------------------------

        onUpgrade: (db, oldVersion, newVersion) async {
          // -----------------------------------------------------------
          // 👉👉👉 Migración V1 → V2
          // -----------------------------------------------------------
          if (oldVersion < 2) {
            print("🔄 Ejecutando migración V1 → V2...");

            // 1. Agregar columna 'activa' en disciplinas
            await db.execute("""
              ALTER TABLE disciplinas ADD COLUMN activa INTEGER DEFAULT 1;
            """);
            print("✔ Columna 'activa' agregada a disciplinas");

            // 2. Agregar columna 'nombre_disciplina' en pagos
            await db.execute("""
              ALTER TABLE pagos ADD COLUMN nombre_disciplina TEXT;
            """);
            print("✔ Columna 'id_disciplina' agregada a pagos");

            // 3. Insertar disciplina por defecto "General"
            int idGeneral = await db.insert("disciplinas", {
              "nombre": "General",
              "descripcion": "Disciplina asignada por defecto",
              "activa": 1
            });

            print("✔ Disciplina 'General' creada con id = $idGeneral");

            // 4. Asignar disciplina General a todos los pagos anteriores
            await db.update(
              "pagos",
              {"nombre_disciplina": "General"},
              where: "nombre_disciplina IS NULL"
            );

            print("✔ Todos los pagos antiguos ahora apuntan a nombre_disciplina = General");

            // 5. Quitar ON DELETE CASCADE de la FK de pagos a clientes
            // SQLite no permite modificar FKs directamente, así que recreamos la tabla:
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

            print("🎉 Migración a versión 2 completada con éxito.");
          }
        },
      );
    }
    catch(e){
      print("❌ ERROR al crear la base de datos: $e");
      rethrow;
    }    
  }
}