import 'package:flutter/material.dart';
import 'package:mygym/data/repositories/cliente_repository.dart';
import 'package:mygym/data/repositories/pago_repository.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/providers/reportes_provider.dart';
import 'package:mygym/views/clientes_screen.dart';
import 'package:mygym/views/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClienteProvider(ClienteRepository())),
        ChangeNotifierProvider(create: (_) => PagoProvider(PagoRepository())),
        ChangeNotifierProvider(create: (_) => ReportesProvider(PagoRepository(), ClienteRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) => LoginScreen(),
          '/clientes': (context) => ClientesScreen(),
        },
      ),
    );
  }
}
