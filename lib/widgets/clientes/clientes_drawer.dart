import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/views/cambiar_imagen_screen.dart';
import 'package:mygym/views/gestion_contrase%C3%B1as.dart';
import 'package:mygym/views/gestion_disciplinas.dart';
import 'package:mygym/views/reportes_screen.dart';
import 'package:mygym/views/respaldos_screen.dart';
import 'package:mygym/views/suscripcion_screen.dart';

class ClientesDrawer extends StatelessWidget {
  const ClientesDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    return  Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.chartSimple, color: Colors.black),
                    title: Text('Reportes'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReportesScreen()));
                      // Acción para reporte
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.black,),
                    title: Text('Gestionar disciplinas'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GestionDisciplinasScreen()));
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.image, color: Colors.black,),
                    title: Text('Cambiar imagen de inicio'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CambiarImagenScreen()));
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.black,),
                    title: Text('Respaldos'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RespaldosScreen()));
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.key, color: Colors.black,),
                    title: Text('Gestionar contraseña'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GestionContrasenasScreen()));
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.solidCreditCard, color: Colors.black,),
                    title: Text('Suscripción'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SuscripcionScreen()));
                    },
                  ),
                ],
              ),
            );
  }
}