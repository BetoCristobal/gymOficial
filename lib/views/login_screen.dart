import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mygym/data/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String masterPassword = 'pacc18'; // Cambia esto por seguridad

  String? _selectedUser;
  final TextEditingController _passController = TextEditingController();
  bool _loading = false;
  String? _rutaImagen;
  
  @override
  void initState() {
    super.initState();
    _cargarImagen();
  }

  Future<void> _cargarImagen() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rutaImagen = prefs.getString('ruta_imagen_login');
    });
  }

  Future<bool> validarPasswordAdmin(String password) async {
    if (password == masterPassword) return true; // Permite acceso con la maestra
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'contraseñas',
      where: 'password = ?',
      whereArgs: [password],
    );
    return result.isNotEmpty;
  }

  void _login() async {
    if (_selectedUser == "administrador") {
      setState(() => _loading = true);
      final isValid = await validarPasswordAdmin(_passController.text);
      setState(() => _loading = false);
      if (isValid) {
        Navigator.pushReplacementNamed(context, '/clientes', arguments: _selectedUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Contraseña incorrecta')),
        );
      }
    } else if (_selectedUser == "maestro") {
      Navigator.pushReplacementNamed(context, '/clientes', arguments: _selectedUser);
    }
  }

  Future<void> recuperarContrasenaConClave(BuildContext context) async {
    final TextEditingController claveController = TextEditingController();
    bool _recuperando = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Recuperar acceso'),
              content: TextField(
                controller: claveController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Palabra clave',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _recuperando ? null : () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _recuperando
                      ? null
                      : () async {
                          setStateDialog(() => _recuperando = true);
                          final claveIngresada = claveController.text;
                          final db = await DatabaseHelper().database;
                          final esClave = await db.query(
                            'contraseñas',
                            where: 'palabra_clave = ?',
                            whereArgs: [claveIngresada],
                          );
                          if (claveIngresada == masterPassword || esClave.isNotEmpty) {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacementNamed('/gestion_contrasenas');
                          } else {
                            setStateDialog(() => _recuperando = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('❌ Palabra clave incorrecta')),
                            );
                          }
                        },
                  child: _recuperando
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.only(bottom: bottomInset),
            width: double.infinity,
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              reverse: true,
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _rutaImagen != null && File(_rutaImagen!).existsSync()
                                ? Image.file(
                                    File(_rutaImagen!),
                                    width: 250,
                                    height: 250,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/logo.png',
                                    width: 250,
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: DropdownButton2<String>(
                              underline: SizedBox(),
                              isExpanded: true,
                              hint: Text(
                                'Elija usuario',
                                style: TextStyle(color: Colors.white60),
                              ),
                              value: _selectedUser,
                              items: [
                                DropdownMenuItem(
                                  value: "administrador",
                                  child: Text("Administrador"),
                                ),
                                DropdownMenuItem(
                                  value: "maestro",
                                  child: Text("Maestro"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedUser = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white60),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              iconStyleData: IconStyleData(
                                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                              ),
                              style: TextStyle(color: Colors.white),
                              onMenuStateChange: (isOpen) {
                                if (isOpen) FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          if(_selectedUser == "administrador")
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TextField(
                                controller: _passController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Contraseña",
                                  hintStyle: TextStyle(color: Colors.white60),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white60),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _selectedUser == null || _loading
                                    ? null
                                    : _login,
                                child: _loading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text("Ingresar"),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if(_selectedUser == "administrador")
                            TextButton(
                              onPressed: () => recuperarContrasenaConClave(context),
                              child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.white),),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}