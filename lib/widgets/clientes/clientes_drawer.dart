import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/views/gestion_disciplinas.dart';
import 'package:mygym/views/reportes_screen.dart';
import 'package:mygym/views/respaldos_screen.dart';

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
                      Navigator.pop(context);
                      // Acción para gestionar disciplinas
                    },
                  ),
                ],
              ),
            );
  }
}