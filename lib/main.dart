import 'package:flutter/material.dart';
import 'package:mygym/views/clientes_screen.dart';
import 'package:mygym/views/login_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => LoginScreen(),
        '/clientes': (context) => ClientesScreen(),
      },
    );
  }
}
