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

  bool _showOverlay = true;

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

  void _mostrarSuscripcion() async {
    // Espera el regreso y refresca el estado
    await Navigator.pushNamed(context, '/suscripcion');
    await context.read<SuscripcionProvider>().refrescarDesdeBilling();
  }

  @override
  Widget build(BuildContext context) {

    final String? userType = ModalRoute.of(context)!.settings.arguments as String?;
    final suscripcionActiva = context.watch<SuscripcionProvider>().activa;

    // Get total records (not filtered)
    final totalRegistros = context.select<ClienteProvider, int>(
      (p) => p.clientes.length,
    );

    // Check if features should be disabled
    final debeDesactivarFunciones = !suscripcionActiva && totalRegistros > 9;

    return GestureDetector(
      onTap: _unfocusTextField,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        // Drawer only if features enabled and admin
        drawer: (!debeDesactivarFunciones && userType == "administrador") 
          ? ClientesDrawer() 
          : null,

        floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.black,
  onPressed: () {
    final totalRegistros = context.read<ClienteProvider>().clientes.length;
    final suscripcionActiva = context.read<SuscripcionProvider>().activa;

    if (!suscripcionActiva && totalRegistros >= 10) {
      // Mostrar overlay de suscripción
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  const Text(
                    'Límite de clientes alcanzado',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Has alcanzado el límite de 10 clientes. Suscríbete para agregar clientes ilimitados y acceder a todas las funciones.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Cierra el diálogo
                      Navigator.pushNamed(context, '/suscripcion');
                    },
                    child: const Text('Ver planes de suscripción'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Mostrar formulario de agregar cliente
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: const FormAgregarEditarCliente(estaEditando: false),
              );
            },
          );
        },
      );
    }
  },
  tooltip: 'Agregar cliente',
  child: const Icon(Icons.add, color: Colors.white),
),

        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Consumer<ClienteProvider>(
            builder: (context, clienteProvider, _) {
              final total = clienteProvider.clientesFiltrados.length;
              return Text("Clientes ($total)", 
                style: const TextStyle(color: Colors.white)
              );
            }
          ),
          backgroundColor: Colors.black,
          titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
          actions: [
            // Only show filter if features not disabled
            if (!debeDesactivarFunciones)
              IconButton(
                highlightColor: Colors.white38,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => const FormFiltroDisciplina(),
                  );
                },
                icon: const Icon(Icons.filter_alt_outlined)
              ),
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
                        // Modificado: mostrar máximo 10 registros si no hay suscripción
                        final clientesLimitados = !suscripcionActiva 
                            ? listaCompleta.take(10).toList()
                            : listaCompleta;

                        return Stack(
                          children: [
                            ListView.builder(
                              itemCount: clientesLimitados.length,
                              itemBuilder: (context, index) {
                                final cliente = clientesLimitados[index];
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
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Overlay/Capa que cubre toda la pantalla cuando no está activa la suscripción
            if (!suscripcionActiva && _showOverlay)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(32),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock, size: 80, color: Colors.deepPurple),
                                const SizedBox(height: 16),
                                const Text(
                                  'Suscripción requerida',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Para disfrutar de todos los beneficios de My Gym como agregar clientes ilimitados, visualizar todos los registros y más funciones, necesitas una suscripción activa.',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  ),
                                  onPressed: _mostrarSuscripcion,
                                  child: const Text('Ver planes de suscripción'),
                                ),
                              ],
                            ),
                          ),
                          // Add close button
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _showOverlay = false),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}