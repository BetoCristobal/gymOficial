import 'package:flutter/material.dart';
import 'package:mygym/data/repositories/cliente_repository.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class VerFotos extends StatefulWidget {
  const VerFotos({super.key});

  @override
  State<VerFotos> createState() => _VerFotosState();
}

class _VerFotosState extends State<VerFotos> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 50)),
          ElevatedButton(
            onPressed: () async {
              await eliminarFotosHuerfanas();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Fotos huérfanas eliminadas."),
                ),
              );
              setState(() {
                
              });
            }, 
            child: Text("Eliminar fotos huerfanas")
          ),
      
          FutureBuilder(
            future: obtenerTodasLasFotosGuardadas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
          
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text("No hay fotos guardadas.");
              }
          
              final fotos = snapshot.data as List<FileSystemEntity>;
          
              return Expanded(
                child: GridView.builder(
                  itemCount: fotos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    final file = fotos[index] as File;
                    return Image.file(file, fit: BoxFit.cover);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<List<FileSystemEntity>> obtenerTodasLasFotosGuardadas() async {
  final directorio = await getApplicationDocumentsDirectory();
  final fotosDir = Directory(p.join(directorio.path, 'fotos_usuarios'));
  print("Ruta de la carpeta de fotos: ${fotosDir.path}"); 
  if (!await fotosDir.exists()) {
    return [];
  }
  final archivos = fotosDir.listSync();

  // Filtrar solo los archivos .jpg
  final fotos = archivos.where((archivo) {
    return archivo.path.endsWith('.jpg');
  }).toList();

  return fotos;
}

final ClienteRepository clienteRepo = ClienteRepository();

Future<void> eliminarFotosHuerfanas() async {
  final directorio = await getApplicationDocumentsDirectory();
  final fotosDir = Directory(p.join(directorio.path, 'fotos_usuarios'));
  if (!await fotosDir.exists()) return;

  final archivos = fotosDir.listSync();
  final fotosDB = await clienteRepo.obtenerFotosPathDesdeBD();

  for (var archivo in archivos) {
    if(archivo.path.endsWith('.jpg')) {
      if(!fotosDB.contains(archivo.path)) {
        try {
          await File(archivo.path).delete();
          print("Foto eliminada: ${archivo.path}");
        } catch (e) {
          print("Error al eliminar foto: $e");
        }
      }
    }
  }
}