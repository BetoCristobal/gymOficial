import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygym/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstatusClientesScreen extends StatefulWidget {
  const EstatusClientesScreen({super.key});

  @override
  State<EstatusClientesScreen> createState() => _EstatusClientesScreenState();
}

class _EstatusClientesScreenState extends State<EstatusClientesScreen> {
  String? _rutaLogo;
  int _tapCount = 0;
  DateTime? _firstTapTime;

  @override
  void initState() {
    super.initState();
    _cargarLogo();
  }

  Future<void> _cargarLogo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rutaLogo = prefs.getString('ruta_imagen_login');
    });
  }

  void _onLogoTap() {
    final now = DateTime.now();
    if (_firstTapTime == null ||
        now.difference(_firstTapTime!) > Duration(seconds: 1)) {
      _firstTapTime = now;
      _tapCount = 1;
    } else {
      _tapCount++;
      if (_tapCount == 4) {
        // Navega a la pantalla deseada, por ejemplo:
        Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false, // Borra toda la pila
        );
        _tapCount = 0;
        _firstTapTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: _onLogoTap,
          child: _rutaLogo != null && File(_rutaLogo!).existsSync()
              ? Image.file(
                  File(_rutaLogo!),
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
      ),
    );
  }
}