import 'package:flutter/material.dart';
import 'package:mygym/widgets/disciplinas/alert_dialog_eliminar_disciplina.dart';
import 'package:provider/provider.dart';
import 'package:mygym/data/models/disciplina_model.dart';
import 'package:mygym/providers/disciplina_provider.dart';

class GestionDisciplinasScreen extends StatefulWidget {
  const GestionDisciplinasScreen({super.key});

  @override
  State<GestionDisciplinasScreen> createState() => _GestionDisciplinasScreenState();
}

class _GestionDisciplinasScreenState extends State<GestionDisciplinasScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<DisciplinaProvider>(context, listen: false).cargarDisciplinas();
  }

  void _agregarDisciplina() async {
    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();
    if (nombre.isEmpty) return;

    await Provider.of<DisciplinaProvider>(context, listen: false).agregarDisciplina(
      DisciplinaModel(nombre: nombre, descripcion: descripcion.isEmpty ? null : descripcion),
    );
    _nombreController.clear();
    _descripcionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplinas'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            //------------------------------------------------CAMPO PARA AGREGAR DISCIPLINA
            TextField(
              controller: _nombreController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nombre de la disciplina',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),

            const SizedBox(height: 10),

            //------------------------------------------------CAMPO PARA AGREGAR DESCRIPCION
            TextField(
              controller: _descripcionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _agregarDisciplina,
              icon: const Icon(Icons.add, color: Colors.white,),
              label: const Text('Agregar disciplina'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: Consumer<DisciplinaProvider>(
                builder: (context, disciplinaProvider, _) {
                  final disciplinas = disciplinaProvider.disciplinas;
                  if (disciplinas.isEmpty) {
                    return const Center(child: Text('No hay disciplinas registradas'));
                  }
                  return ListView.builder(
                    itemCount: disciplinas.length,
                    itemBuilder: (context, index) {
                      final disciplina = disciplinas[index];
                      return Card(
                        child: ListTile(
                          title: Text(disciplina.nombre),
                          subtitle: disciplina.descripcion != null && disciplina.descripcion!.isNotEmpty
                              ? Text(disciplina.descripcion!)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final resultado = await AlertDialogEliminarDisciplina(context, disciplina.id!);
                                        if(resultado == true) {
                                          await disciplinaProvider.eliminarDisciplina(disciplina.id!);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("❌Disciplina eliminada")),
                                          ); 
                                        }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}