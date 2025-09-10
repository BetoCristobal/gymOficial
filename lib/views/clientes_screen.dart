import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/views/ver_fotos.dart';
import 'package:mygym/widgets/clientes/barra_busqueda.dart';
import 'package:mygym/widgets/clientes/clientes_drawer.dart';
import 'package:mygym/widgets/clientes/form_agregar_editar_cliente.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {

  //KEY PARA TOGGLE BUTTONS Y PARA CALCULAR ALTURA DEL TOGGLE
  final GlobalKey _toggleKey = GlobalKey();
  double _toggleHalf = 0;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //OBTENER LA ALTURA DEL TOGGLE BUTTONS
      //Esto se hace para que el toggle buttons se ajuste a la altura del contenido
      final RenderBox? box = _toggleKey.currentContext?.findRenderObject() as RenderBox?;
      if(box != null){
        setState(() {
          _toggleHalf = box.localToGlobal(Offset.zero).dy + box.size.height / 2;
        });
      }
    });
  }

  void _unfocusTextField() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {

    final String? userType = ModalRoute.of(context)!.settings.arguments as String?;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context, 
              builder: (BuildContext context) {
                return FormAgregarEditarCliente();
              }
            );
          },
          child: Icon(Icons.add, color: Colors.white,),
        ),

        //----------------------------------------------------------Drawer solo para admin
        drawer: userType == "administrador" ? ClientesDrawer() : null,

        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Clientes"),
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(fontSize: 23, color: Colors.white),
          actions: [
            //------------------------------Icono Ver Fotos Huerfanas
            IconButton(
              highlightColor: Colors.white38,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VerFotos()));
              }, 
              icon: Icon(Icons.photo_album)),
      
            //------------------------------Icono Mandar Reportes
            IconButton(
              highlightColor: Colors.white38,
              onPressed: () {
      
              }, 
              icon: FaIcon(FontAwesomeIcons.paperPlane), color: Colors.white,),
          ],
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: _toggleHalf > 0 ? _toggleHalf : 100,
                
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                )
              ),                
            ),

            Column(
              children: [
                //-------------------------------------------Barra busqueda
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 20),
                  child: BarraBusqueda(
                    desactivarBarraBusqueda: true,
                    onSearchChanged: (value) {
                      
                    },
                    focusNode: _searchFocusNode
                  )
                ),

                //-------------------------------------------Filtro clientes
                
              ],
            ),
          ],
        ),
        
      ),
    );
  }
}