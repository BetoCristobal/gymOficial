import 'package:flutter/material.dart';
import 'package:mygym/data/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistroInicialScreen extends StatefulWidget {
  const RegistroInicialScreen({super.key});

  @override
  State<RegistroInicialScreen> createState() => _RegistroInicialScreenState();
}

class _RegistroInicialScreenState extends State<RegistroInicialScreen> {
  final _passController = TextEditingController();
  final _claveController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _guardarCredenciales() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    // Guarda la contraseña y palabra clave en la DB
    await DatabaseHelper().guardarCredenciales(_passController.text, _claveController.text);
    await prefs.setBool('registro_inicial_completado', true);
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro inicial'),
        backgroundColor: Colors.black,
          titleTextStyle: TextStyle(fontSize: 23, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              //----------------------------------------------------------------ICONO Y TEXTO
              Row(
                children: [
                  Icon(Icons.vpn_key, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text('Nueva contraseña y palabra clave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              //----------------------------------------------------------------CAMPOS
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _claveController,
                          decoration: InputDecoration(
                            labelText: 'Palabra clave',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                        ),
                        
                        SizedBox(height: 24),
        
                        ElevatedButton(
                          onPressed: _guardarCredenciales,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Guardar y continuar'),
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
    );
  }
}