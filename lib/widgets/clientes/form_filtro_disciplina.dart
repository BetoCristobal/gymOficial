import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/providers/disciplina_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:provider/provider.dart';

class FormFiltroDisciplina extends StatefulWidget {
  final void Function(String?)? onFiltrarDisciplina;

  const FormFiltroDisciplina({super.key, this.onFiltrarDisciplina});

  @override
  State<FormFiltroDisciplina> createState() => _FormFiltroDisciplinaState();
}

class _FormFiltroDisciplinaState extends State<FormFiltroDisciplina> {

  String? _selectedDisciplina;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Filtrar por disciplina:", style: TextStyles.tituloShowModal,  ),
              ),

              //--------------------------------------------Dropdown disciplinas
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Consumer<DisciplinaProvider>(
                  builder: (context, disciplinaProvider, _) {
                    final disciplinas = disciplinaProvider.disciplinas;

                    return DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Elija disciplina',
                            style: TextStyle(color: Colors.white60),
                          ),
                          value: _selectedDisciplina,
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text("Todas"),
                            ),
                            ...disciplinas.map((d) => DropdownMenuItem(
                              value: d.nombre,
                              child: Text(d.nombre)
                            ))
                          ],
                          onChanged: (value) {
                            setState(() {
                              
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white60),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          onMenuStateChange: (isOpen) {
                            if (isOpen) FocusScope.of(context).unfocus(); // Cierra el teclado al abrir el menú
                          },
                        );
                  }
                ),
              ),

                  //----------------------------------------------------Boton aplicar
                  //BOTON APLICAR
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 30, bottom: 20),
                  child: ElevatedButton.icon(
                    icon: Icon(FontAwesomeIcons.check, color: Colors.white,),
                    label: Text("Aplicar", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 173, 33)
                    ),
                    onPressed: () {
                      
                      Navigator.pop(context);
                    }, 
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}