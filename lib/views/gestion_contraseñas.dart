import 'package:flutter/material.dart';
import 'package:mygym/data/db/database_helper.dart';

const String masterPassword = 'pacc18'; // Cambia esto por seguridad

class GestionContrasenasScreen extends StatefulWidget {
  const GestionContrasenasScreen({Key? key}) : super(key: key);

  @override
  State<GestionContrasenasScreen> createState() => _GestionContrasenasScreenState();
}

class _GestionContrasenasScreenState extends State<GestionContrasenasScreen> {
  final _formPassKey = GlobalKey<FormState>();
  final _formClaveKey = GlobalKey<FormState>();

  final _newPassController = TextEditingController();
  final _claveController = TextEditingController();

  final _claveActualController = TextEditingController();
  final _nuevaClaveController = TextEditingController();

  bool _loadingPass = false;
  bool _loadingClave = false;

  bool _verPalabraClave = false;
  bool _verNuevaPass = false;
  bool _verPalabraClaveActual = false;
  bool _verNuevaPalabraClave = false;

  Future<bool> validarClave(String clave) async {
    if (clave == masterPassword) return true;
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'contraseñas',
      where: 'palabra_clave = ?',
      whereArgs: [clave],
    );
    return result.isNotEmpty;
  }

  Future<bool> cambiarPasswordAdmin(String newPass, String clave) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'contraseñas',
      where: 'palabra_clave = ? OR ? = ?',
      whereArgs: [clave, clave, masterPassword],
    );
    if (result.isEmpty) return false;
    await db.update(
      'contraseñas',
      {'password': newPass},
      where: 'id = ?',
      whereArgs: [result.first['id']],
    );
    return true;
  }

  Future<bool> cambiarPalabraClave(String claveActual, String nuevaClave) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'contraseñas',
      where: 'palabra_clave = ? OR ? = ?',
      whereArgs: [claveActual, claveActual, masterPassword],
    );
    if (result.isEmpty) return false;
    await db.update(
      'contraseñas',
      {'palabra_clave': nuevaClave},
      where: 'id = ?',
      whereArgs: [result.first['id']],
    );
    return true;
  }

  Future<void> _cambiarPassword() async {
    setState(() => _loadingPass = true);

    final claveValida = await validarClave(_claveController.text);
    if (!claveValida) {
      setState(() => _loadingPass = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Palabra clave incorrecta')),
      );
      return;
    }

    final success = await cambiarPasswordAdmin(
      _newPassController.text,
      _claveController.text,
    );
    setState(() => _loadingPass = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ Contraseña cambiada correctamente'
            : '❌ No se pudo cambiar la contraseña'),
      ),
    );
    if (success) {
      _newPassController.clear();
      _claveController.clear();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _cambiarPalabraClave() async {
    setState(() => _loadingClave = true);

    final claveValida = await validarClave(_claveActualController.text);
    if (!claveValida) {
      setState(() => _loadingClave = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Palabra clave actual incorrecta')),
      );
      return;
    }

    final success = await cambiarPalabraClave(
      _claveActualController.text,
      _nuevaClaveController.text,
    );
    setState(() => _loadingClave = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ Palabra clave cambiada correctamente'
            : '❌ No se pudo cambiar la palabra clave'),
      ),
    );
    if (success) {
      _claveActualController.clear();
      _nuevaClaveController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de credenciales'),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(fontSize: 23, color: Colors.white),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bullet y Card para cambiar contraseña
                  Row(
                    children: [
                      Icon(Icons.vpn_key, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text('Cambiar contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formPassKey,
                        child: Column(
                          children: [
                            //------------------------------------------------CAMPO PALABRA CLAVE
                            TextFormField(
                              controller: _claveController,
                              decoration: InputDecoration(
                                labelText: 'Palabra clave',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_verPalabraClave ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _verPalabraClave = !_verPalabraClave),
                                ),
                              ),
                              obscureText: !_verPalabraClave,
                              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                            ),
                            SizedBox(height: 16),

                            //-------------------------------------------------CAMPO NUEVA CONTRASEÑA
                            TextFormField(
                              controller: _newPassController,
                              decoration: InputDecoration(
                                labelText: 'Nueva contraseña',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_verNuevaPass ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _verNuevaPass = !_verNuevaPass),
                                ),
                              ),
                              obscureText: !_verNuevaPass,
                              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                            ),
                            SizedBox(height: 16),
                            _loadingPass
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: () {
                                      if (_formPassKey.currentState!.validate()) {
                                        _cambiarPassword();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Cambiar contraseña'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bullet y Card para cambiar palabra clave
                  Row(
                    children: [
                      Icon(Icons.password, color: Colors.teal),
                      SizedBox(width: 8),
                      Text('Cambiar palabra clave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formClaveKey,
                        child: Column(
                          children: [
                            //------------------------------------------------CAMPO PALABRA CLAVE ACTUAL
                            TextFormField(
                              controller: _claveActualController,
                              decoration: InputDecoration(
                                labelText: 'Palabra clave actual',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_verPalabraClaveActual ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _verPalabraClaveActual = !_verPalabraClaveActual),
                                ),
                              ),
                              obscureText: !_verPalabraClaveActual,
                              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                            ),
                            SizedBox(height: 16),
                            //-------------------------------------------------CAMPO NUEVA PALABRA CLAVE
                            TextFormField(
                              controller: _nuevaClaveController,
                              decoration: InputDecoration(
                                labelText: 'Nueva palabra clave',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_verNuevaPalabraClave ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _verNuevaPalabraClave = !_verNuevaPalabraClave),
                                ),
                              ),
                              obscureText: !_verNuevaPalabraClave,
                              validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                            ),
                            SizedBox(height: 16),
                            _loadingClave
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: () {
                                      if (_formClaveKey.currentState!.validate()) {
                                        _cambiarPalabraClave();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Cambiar palabra clave'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}