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
import 'package:mygym/views/onboarding_screen.dart';
import 'package:mygym/views/registro_inicial_screen.dart';
import 'package:mygym/views/suscripcion_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
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
        restorationScopeId: "app",
        routes: {
          "/": (context) => const LaunchDecider(),
          '/clientes': (context) => const ClientesScreen(),
          '/login': (context) => const LoginScreen(),
          '/gestion_contrasenas': (context) => const GestionContrasenasScreen(),
          '/suscripcion': (context) => const SuscripcionScreen(),
          '/registro_inicial': (context) => const RegistroInicialScreen(),
        },
      ),
    );
  }
}

// Decisor de arranque: Onboarding -> Registro inicial -> Login
class LaunchDecider extends StatelessWidget {
  const LaunchDecider({super.key});

  Future<Widget> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('show_onboarding') ?? true;
    final registroHecho = prefs.getBool('registro_inicial_completado') ?? false;

    if (!registroHecho) {
      return showOnboarding ? const OnboardingScreen() : const RegistroInicialScreen();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decide(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data!;
      },
    );
  }
}
