import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String? _selectedUser;

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
                      onPressed: _selectedUser == null
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(context, '/clientes', arguments: _selectedUser);
                            },
                      child: Text("Ingresar")
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