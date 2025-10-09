import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/views/cambiar_imagen_screen.dart';
import 'package:mygym/views/gestion_contrase%C3%B1as.dart';
import 'package:mygym/views/gestion_disciplinas.dart';
import 'package:mygym/views/reportes_screen.dart';
import 'package:mygym/views/respaldos_screen.dart';
import 'package:mygym/views/suscripcion_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientesDrawer extends StatelessWidget {
  const ClientesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Colors.black),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.chartSimple, color: Colors.black),
                  title: const Text('Reportes'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportesScreen()));
                  },
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.dumbbell, color: Colors.black),
                  title: const Text('Gestionar disciplinas'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GestionDisciplinasScreen()));
                  },
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.image, color: Colors.black),
                  title: const Text('Cambiar imagen de inicio'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CambiarImagenScreen()));
                  },
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.black),
                  title: const Text('Respaldos'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RespaldosScreen()));
                  },
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.key, color: Colors.black),
                  title: const Text('Gestionar contraseña'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GestionContrasenasScreen()));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.solidCreditCard, color: Colors.black),
            title: const Text('Suscripción'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SuscripcionScreen()));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.solidCircleQuestion, color: Colors.black),
            title: const Text('Tutoriales y ayuda'),
            onTap: () async {
              final uri = Uri.parse('https://pexel.com.mx/my-gym'); // cambia por tu URL
              final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo abrir la página')),
                );
              }
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.rightFromBracket, color: Colors.redAccent),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}