import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mygym/data/models/pago_model.dart';
import 'package:mygym/providers/cliente_disciplina_provider.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/disciplina_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/views/ver_fotos.dart';
import 'package:mygym/widgets/clientes/barra_busqueda.dart';
import 'package:mygym/widgets/clientes/cliente_card.dart';
import 'package:mygym/widgets/clientes/clientes_drawer.dart';
import 'package:mygym/widgets/clientes/form_agregar_editar_cliente.dart';
import 'package:mygym/widgets/clientes/form_filtro_disciplina.dart';
import 'package:mygym/widgets/clientes/form_filtros_maestro.dart';
import 'package:mygym/widgets/clientes/my_toggle_buttons.dart';
import 'package:provider/provider.dart';

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
    Provider.of<PagoProvider>(context, listen: false).cargarPagosTodosById();
    Provider.of<DisciplinaProvider>(context, listen: false).cargarDisciplinas();
  }

  void _unfocusTextField() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {

    final String? userType = ModalRoute.of(context)!.settings.arguments as String?;

    return GestureDetector(
      onTap: () {
        _unfocusTextField();
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
                return FormAgregarEditarCliente(estaEditando: false,);
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
            // ICONO APLICAR FILTROS
          IconButton(
            highlightColor: Colors.white38,
            onPressed: () {
            showModalBottomSheet(
              context: context, 
              builder: (BuildContext context) {
                return FormFiltroDisciplina(
                  
                );
              }
            );
          }, icon: const Icon(Icons.filter_alt_outlined)),
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
                showModalBottomSheet(
              context: context, 
              builder: (BuildContext context) {
                return FormFiltrosMaestro();
              }
            );
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
                Consumer<ClienteProvider>(
                  builder: (context, clienteProvider,_) {
                    bool desactivarBarraBusqueda = true;
                      
                      if(clienteProvider.isSelected[0] != true) {
                        desactivarBarraBusqueda = false;
                      }

                    return Container(
                      padding: EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 20),
                      child: BarraBusqueda(
                        desactivarBarraBusqueda: desactivarBarraBusqueda,
                        onSearchChanged: (value) {
                          clienteProvider.filtrarClientesPorNombresApellidos(value);
                        },
                        focusNode: _searchFocusNode
                      )
                      
                    );
                  }
                ),

                //-------------------------------------------Filtro clientes
                Container(
                  key: _toggleKey,
                  padding: EdgeInsets.only(top: 10),
                  child: MyToggleButtons()
                ),

                //-------------------------------------------Lista clientes
                Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(top: 10),
                      width: double.infinity,
                      child: Consumer2<ClienteProvider, PagoProvider>(
                        builder: (context, clienteProvider, pagoProvider, _) {                  
                          
                          if(clienteProvider.clientes.isEmpty) {
                            return const Center(child: Text("No hay clientes registrados"),);
                          }
                    
                          return ListView.builder(
                            itemCount: clienteProvider.clientesFiltrados.length,
                            itemBuilder: (context, index) {
                              final cliente = clienteProvider.clientesFiltrados[index];
                      
                              final ultimoPago = pagoProvider.pagos.firstWhere(
                                (pago) => pago.idCliente == cliente.id,
                                orElse: () => PagoModel(
                                  idCliente: 100000, 
                                  montoPago: 0, 
                                  fechaPago: DateTime(1900), 
                                  proximaFechaPago: DateTime(1900), 
                                  tipoPago: "ninguno"),
                              );          
                          
                              return FutureBuilder<List<String>>(
                                future: Provider.of<ClienteDisciplinaProvider>(context, listen: false)
                                    .getNombresDisciplinasPorCliente(cliente.id!),
                                builder: (context, snapshot) {
                                  final disciplinas = snapshot.data ?? [];
                                  return ClienteCard(
                                    cliente: cliente,
                                    ultimoPago: ultimoPago,
                                    disciplinas: disciplinas,
                                  );
                                },
                              );
                            }
                          );            
                        },
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
        
      ),
    );
  }
}