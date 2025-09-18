import 'package:flutter/material.dart';
import 'package:mygym/data/db/database_helper.dart';

const String masterPassword = 'pacc18'; // Cambia esto por seguridad

class GestionContrasenasScreen extends StatefulWidget {
  const GestionContrasenasScreen({Key? key}) : super(key: key);

  @override
  State<GestionContrasenasScreen> createState() => _GestionContrasenasScreenState();
}

class _GestionContrasenasScreenState extends State<GestionContrasenasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  bool _loading = false;

  Future<bool> cambiarPasswordAdmin(String oldPass, String newPass) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'contraseñas',
      where: 'password = ?',
      whereArgs: [oldPass],
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

  Future<void> recuperarContrasenaConMaestra(BuildContext context) async {
    final TextEditingController masterController = TextEditingController();
    final TextEditingController nuevaController = TextEditingController();
    bool _recuperando = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Recuperar contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: masterController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña maestra',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: nuevaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _recuperando ? null : () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _recuperando
                      ? null
                      : () async {
                          setStateDialog(() => _recuperando = true);
                          if (masterController.text == masterPassword) {
                            final db = await DatabaseHelper().database;
                            // Cambia la contraseña al primer registro
                            await db.update(
                              'contraseñas',
                              {'password': nuevaController.text},
                              where: 'id = 1',
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Contraseña restablecida'), duration: Duration(milliseconds: 900)),
                            );
                          } else {
                            setStateDialog(() => _recuperando = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Contraseña maestra incorrecta'), duration: Duration(milliseconds: 900)),
                            );
                          }
                        },
                  child: _recuperando
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Recuperar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cambiarPassword() async {
    setState(() => _loading = true);
    final success = await cambiarPasswordAdmin(
      _oldPassController.text,
      _newPassController.text,
    );
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Contraseña cambiada correctamente'
            : 'Contraseña actual incorrecta'),
      ),
    );
    if (success) {
      _oldPassController.clear();
      _newPassController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar contraseña'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _oldPassController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña actual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),

                    SizedBox(height: 16),

                    TextFormField(
                      controller: _newPassController,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    SizedBox(height: 24),
                    _loading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _cambiarPassword();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Cambiar contraseña'),
                          ),
                    SizedBox(height: 24),
                    TextButton(
                      onPressed: () => recuperarContrasenaConMaestra(context),
                      child: Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}