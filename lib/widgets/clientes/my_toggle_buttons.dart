import 'package:flutter/material.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/styles/text_styles.dart';
import 'package:provider/provider.dart';

class MyToggleButtons extends StatelessWidget {

  MyToggleButtons({super.key});

  @override
  Widget build(BuildContext context) {

    final toggleProvider = Provider.of<ClienteProvider>(context);

    return Consumer<ClienteProvider>(
              builder: (context, value, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: Center(
                    child: ToggleButtons(
                      borderColor: Colors.white38,    //selectedBorderColor: Colors.white54,
                      color: Colors.white,
                      selectedColor: Colors.white,
                      selectedBorderColor: Colors.white38,
                      fillColor: Colors.blue[800],
                      borderRadius: BorderRadius.circular(10),
                      isSelected: toggleProvider.isSelected,
                      onPressed: (int index) {
                        toggleProvider.toggleButton(index);
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text("Todos", style: TextStyles.textoToggleButtons,),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text("Vencidos", style: TextStyles.textoToggleButtons,),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text("Urgentes", style: TextStyles.textoToggleButtons,),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text("Próximos", style: TextStyles.textoToggleButtons,),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: Text("Corrientes", style: TextStyles.textoToggleButtons,),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
  }
}