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

  bool _mostrarInstrucciones = true;
  bool _verPass = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferenciaInstrucciones();
  }

  @override
  void dispose() {
    _passController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _cargarPreferenciaInstrucciones() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mostrarInstrucciones = prefs.getBool('ri_mostrar_instrucciones') ?? true;
    });
  }

  Future<void> _ocultarInstrucciones({bool recordar = true}) async {
    setState(() => _mostrarInstrucciones = false);
    if (recordar) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ri_mostrar_instrucciones', false);
    }
  }

  Future<void> _guardarCredenciales() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final pass = _passController.text.trim();
      final clave = _claveController.text.trim();

      // Guarda en la tabla 'contraseñas'
      await DatabaseHelper().guardarCredenciales(pass, clave);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registro_inicial_completado', true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales guardadas')),
      );

      // Ir a Login y limpiar la pila
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro inicial'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Ver instrucciones',
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => setState(() => _mostrarInstrucciones = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_mostrarInstrucciones)
              Card(
                color: Colors.deepPurple.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text('Instrucciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('• Crea una contraseña para ingresar a la app.'),
                      const Text('• Define una palabra clave para recuperación.'),
                      const Text('• Guarda estos datos en un lugar seguro.'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _ocultarInstrucciones(),
                            child: const Text('No volver a mostrar'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _ocultarInstrucciones(recordar: false),
                            child: const Text('Ocultar ahora'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            Row(
              children: const [
                Icon(Icons.vpn_key, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Nueva contraseña y palabra clave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),

            const SizedBox(height: 8),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _verPass = !_verPass),
                          ),
                        ),
                        obscureText: !_verPass,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _claveController,
                        decoration: const InputDecoration(
                          labelText: 'Palabra clave',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _guardarCredenciales,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Guardar y continuar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}