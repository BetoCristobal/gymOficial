import 'package:flutter/material.dart';
import 'package:mygym/data/models/pago_model.dart';
import 'package:mygym/providers/cliente_disciplina_provider.dart';
import 'package:mygym/providers/cliente_provider.dart';
import 'package:mygym/providers/disciplina_provider.dart';
import 'package:mygym/providers/pago_provider.dart';
import 'package:mygym/providers/suscripcion_provider.dart';
import 'package:mygym/widgets/clientes/barra_busqueda.dart';
import 'package:mygym/widgets/clientes/cliente_card.dart';
import 'package:mygym/widgets/clientes/clientes_drawer.dart';
import 'package:mygym/widgets/clientes/form_agregar_editar_cliente.dart';
import 'package:mygym/widgets/clientes/form_filtro_disciplina.dart';
import 'package:mygym/widgets/clientes/my_toggle_buttons.dart';
import 'package:provider/provider.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> with WidgetsBindingObserver{

  //KEY PARA TOGGLE BUTTONS Y PARA CALCULAR ALTURA DEL TOGGLE
  final GlobalKey _toggleKey = GlobalKey();
  double _toggleHalf = 0;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //OBTENER LA ALTURA DEL TOGGLE BUTTONS
      //Esto se hace para que el toggle buttons se ajuste a la altura del contenido
      final RenderBox? box = _toggleKey.currentContext?.findRenderObject() as RenderBox?;
      if(box != null){
        setState(() {
          _toggleHalf = box.localToGlobal(Offset.zero).dy + box.size.height / 2;
        });
      }

      // Refresca estado de suscripción al abrir la pantalla
      context.read<SuscripcionProvider>().refrescarDesdeBilling();
    });
    Provider.of<PagoProvider>(context, listen: false).cargarPagosTodosById();
    Provider.of<DisciplinaProvider>(context, listen: false).cargarDisciplinas();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Al volver al foreground, refresca desde Billing
      context.read<SuscripcionProvider>().refrescarDesdeBilling();
    }
  }

  void _unfocusTextField() {
    _searchFocusNode.unfocus();
  }

  bool get _modoDemo {
    final clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
    return clienteProvider.clientesFiltrados.length > 7;
  }

  void _mostrarSuscripcion() async {
    // Espera el regreso y refresca el estado
    await Navigator.pushNamed(context, '/suscripcion');
    await context.read<SuscripcionProvider>().refrescarDesdeBilling();
  }

  @override
  Widget build(BuildContext context) {

    final String? userType = ModalRoute.of(context)!.settings.arguments as String?;
    final suscripcionActiva = context.watch<SuscripcionProvider>().activa;

    // Toma el total de clientes para decidir si mostrar el FAB
    final totalClientes = context.select<ClienteProvider, int>(
      (p) => p.clientesFiltrados.length,
    );
    final puedeAgregar = suscripcionActiva || totalClientes < 8;

    return GestureDetector(
      onTap: () {
        _unfocusTextField();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        floatingActionButton: puedeAgregar ? FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context, 
              builder: (BuildContext context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.8, // 80% de la pantalla
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, ScrollController) {
                    return SingleChildScrollView(
                      controller: ScrollController,
                      child: FormAgregarEditarCliente(estaEditando: false,));
                  }
                );
              }
            );
          },
          child: Icon(Icons.add, color: Colors.white,),
        )
        : null,

        //----------------------------------------------------------Drawer solo para admin
        drawer: userType == "administrador" ? ClientesDrawer() : null,

        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Consumer<ClienteProvider>(
            builder: (context, clienteProvider, _) {
              final total = clienteProvider.clientesFiltrados.length;
              return Text("Clientes ($total)", style: TextStyle(color: Colors.white),);
            }
          ),
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
            // IconButton(
            //   highlightColor: Colors.white38,
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => VerFotos()));
            //   }, 
            //   icon: Icon(Icons.photo_album)),
      
            //------------------------------Icono Mandar Reportes
            // IconButton(
            //   highlightColor: Colors.white38,
            //   onPressed: () {
            //     showModalBottomSheet(
            //   context: context, 
            //   builder: (BuildContext context) {
            //     return FormFiltrosMaestro();
            //   }
            // );
            //   }, 
            //   icon: FaIcon(FontAwesomeIcons.paperPlane), color: Colors.white,),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    child: Consumer2<ClienteProvider, PagoProvider>(
                      builder: (context, clienteProvider, pagoProvider, _) {
                        final suscripcionActiva = context.watch<SuscripcionProvider>().activa;

                        if (clienteProvider.clientes.isEmpty) {
                          return const Center(child: Text("No hay clientes registrados"));
                        }

                        final listaCompleta = clienteProvider.clientesFiltrados;
                        final clientesDemo = (!suscripcionActiva && listaCompleta.length > 7)
                            ? listaCompleta.take(7).toList()
                            : listaCompleta;

                        return Stack(
                          children: [
                            ListView.builder(
                              itemCount: clientesDemo.length,
                              itemBuilder: (context, index) {
                                final cliente = clientesDemo[index];
                                final ultimoPago = pagoProvider.pagos.firstWhere(
                                  (pago) => pago.idCliente == cliente.id,
                                  orElse: () => PagoModel(
                                    idCliente: 100000,
                                    montoPago: 0,
                                    fechaPago: DateTime(1900),
                                    proximaFechaPago: DateTime(1900),
                                    tipoPago: "ninguno",
                                  ),
                                );
                                return FutureBuilder<List<String>>(
                                  future: Provider.of<ClienteDisciplinaProvider>(context, listen: false)
                                      .getNombresDisciplinasPorCliente(cliente.id!),
                                  builder: (context, snapshot) {
                                    final disciplinas = snapshot.data ?? [];
                                    final screenWidth = MediaQuery.of(context).size.width;
                                    return Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: screenWidth > 799 ? screenWidth * 0.7 : screenWidth * 0.95,
                                        ),
                                        child: ClienteCard(
                                          cliente: cliente,
                                          ultimoPago: ultimoPago,
                                          disciplinas: disciplinas,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            if (!suscripcionActiva && listaCompleta.length > 7)
                              Positioned(
                                bottom: 30,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Para agregar más clientes y visualizar todos los clientes, desbloquea la app suscribiéndote.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        icon: const Icon(Icons.lock_open, color: Colors.white),
                                        label: const Text('Desbloquear app / Suscribirse'),
                                        onPressed: _mostrarSuscripcion,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        
      ),
    );
  }
}