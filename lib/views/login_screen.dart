import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mygym/data/db/database_helper.dart';

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
          SnackBar(content: Text('Contraseña incorrecta')),
        );
      }
    } else if (_selectedUser == "maestro") {
      Navigator.pushReplacementNamed(context, '/clientes', arguments: _selectedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: DropdownButton2<String>(
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
                      if (isOpen) FocusScope.of(context).unfocus(); // Cierra el teclado al abrir el menú
                    },
                  ),
                ),

                //-------------------------------CAMPO CONTRASEÑA
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
            
                //-----------------------------------BOTON INGRESAR
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}