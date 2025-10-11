import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_onboarding', false);
    Navigator.of(context).pushReplacementNamed('/registro_inicial');
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      pageColor: Colors.black,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      bodyTextStyle: TextStyle(fontSize: 16, color: Colors.white),
    );

    return IntroductionScreen(
      globalBackgroundColor: Colors.black,
      pages: [
        PageViewModel(
          title: 'Bienvenido a My Gym',
          body: 'Administra tu gimnasio de forma sencilla y segura.',
          decoration: pageDecoration,
          image: const Icon(Icons.fitness_center, size: 140, color: Colors.white),
        ),
        PageViewModel(
          title: 'Seguridad primero',
          body: 'Protegemos datos sensibles como clientes y pagos. Por eso pediremos configurar acceso seguro.',
          decoration: pageDecoration,
          image: const Icon(Icons.verified_user, size: 140, color: Colors.white),
        ),
        PageViewModel(
          title: 'Acceso de administrador',
          body: 'Deberás crear una contraseña y una palabra clave. Esto asegura que solo el administrador gestione la app.',
          decoration: pageDecoration,
          image: const Icon(Icons.vpn_key, size: 140, color: Colors.white),
        ),
        PageViewModel(
          title: 'Listo para comenzar',
          body: 'Configura tu contraseña y palabra clave para continuar.',
          decoration: pageDecoration,
          image: const Icon(Icons.lock, size: 140, color: Colors.white),
        ),
      ],
      showSkipButton: true,
      skip: const Text('Saltar', style: TextStyle(color: Colors.white)),
      next: const Icon(Icons.arrow_forward, color: Colors.white),
      done: const Text('Comenzar', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      onDone: () => _finish(context),
      onSkip: () => _finish(context),
      dotsDecorator: const DotsDecorator(
        color: Colors.white38,
        activeColor: Colors.white,
        size: Size(8, 8),
        activeSize: Size(20, 8),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
      ),
    );
  }
}