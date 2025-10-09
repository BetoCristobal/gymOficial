import 'package:flutter/material.dart';
import 'package:mygym/data/repositories/cliente_disciplina_repository.dart';
import 'package:mygym/data/repositories/cliente_repository.dart';
import 'package:mygym/data/repositories/disciplina_repository.dart';
import 'package:mygym/data/repositories/pago_repository.dart';
import 'package:mygym/providers/cliente_disciplina_provider.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/disciplina_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/providers/reportes_provider.dart';
import 'package:mygym/providers/suscripcion_provider.dart';
import 'package:mygym/views/clientes_screen.dart';
import 'package:mygym/views/gestion_contrase%C3%B1as.dart';
import 'package:mygym/views/login_screen.dart';
import 'package:mygym/views/registro_inicial_screen.dart';
import 'package:mygym/views/suscripcion_screen.dart';
import 'package:provider/provider.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => DisciplinaProvider(DisciplinaRepository())),
        ChangeNotifierProvider(create: (_) => ClienteDisciplinaProvider(ClienteDisciplinaRepository())),
        ChangeNotifierProvider(create: (_) => SuscripcionProvider()..cargarEstado()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) => LoginScreen(),
          '/clientes': (context) => ClientesScreen(),
          '/login': (context) => LoginScreen(),
          '/gestion_contrasenas': (context) => GestionContrasenasScreen(),
          '/suscripcion': (context) => SuscripcionScreen(),
          '/registro_inicial': (context) => RegistroInicialScreen(),
        },
      ),
    );
  }
}
