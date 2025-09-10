import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mygym/data/models/cliente_model.dart';
import 'package:mygym/data/models/reporte_pago_model.dart';
import 'package:mygym/data/repositories/cliente_repository.dart';
import 'package:mygym/data/repositories/pago_repository.dart';

class ReportesProvider extends ChangeNotifier{
  final PagoRepository pagoRepo;
  final ClienteRepository clienteRepo;

  ReportesProvider(this.pagoRepo, this.clienteRepo);

  List<ReportePagoModel> _reportes = [];
  double _sumaTotal = 0;
  List<ReportePagoModel> _reportesMostrar = [];

  List<ReportePagoModel> _reportesFiltrados = [];

  List<ReportePagoModel> get reportes => _reportes;
  double get sumaPagos => _sumaTotal;
  List<ReportePagoModel> get reportesMostrar => _reportesMostrar;

  //---------------variables y geters para reportes----------
  List<ReportePagoModel> _pagosEfectivo = [];
  List<ReportePagoModel> _pagosTransferencia = [];
  List<ReportePagoModel> _pagosTarjeta = [];

  double _totalEfectivo = 0;
  double _totalTransferencia = 0;
  double _totalTarjeta = 0;

  double _porcentajeEfectivo = 0;
  double _porcentajeTransferencia = 0;
  double _porcentajeTarjeta = 0;

  List<ReportePagoModel> get pagosEfectivo => _pagosEfectivo;
  List<ReportePagoModel> get pagosTransferencia => _pagosTransferencia;
  List<ReportePagoModel> get pagosTarjeta => _pagosTarjeta;

  double get totalEfectivo => _totalEfectivo;
  double get totalTransferencia => _totalTransferencia;
  double get totalTarjeta => _totalTarjeta;

  double get porcentajeEfectivo => _porcentajeEfectivo;
  double get porcentajeTransferencia => _porcentajeTransferencia;
  double get porcentajeTarjeta => _porcentajeTarjeta;

  String? txtFechaInicioFiltro;
  String? txtFechaFinFiltro;  
  String? txtTipoPago;

  //------------CARGAR TODOS REPORTES----------
  
  Future<void> cargarReportes() async {
    try {
      final pagos = await pagoRepo.getPagosTodosOrdenadosById();
      final clientes = await clienteRepo.getClientes();
      
      _reportes = pagos.map((pago) {
        final cliente = clientes.firstWhere(
          (c) => c.id == pago.idCliente,
          orElse: () => ClienteModel(
            nombres: "desconocido", 
            apellidos: "", 
            telefono: "", 
            estatus: ""
          ),
        );
        return ReportePagoModel(
          nombreCliente: "${cliente.nombres} ${cliente.apellidos}", 
          fechaPago: pago.fechaPago, 
          montoPago: pago.montoPago, 
          tipoPago: pago.tipoPago
        );
      }).toList();

      _sumaTotal = pagos.fold(0, (sum, item) => sum + item.montoPago);
      _reportesMostrar = _reportes;
      clasificarPagosPorTipo();
      notifyListeners();
      print("Se cargaron totdos los reportes");

    } catch(e) {
      print('❌ Error al cargar reportes: $e');
    }
  }

  //----------------------------METODO OBTENER TOTALES Y PORCENTAJES POR TIPO DE PAGO
  void clasificarPagosPorTipo() {
    //Limpiar listas
    _pagosEfectivo = [];
    _pagosTransferencia = [];
    _pagosTarjeta = [];

    _totalEfectivo = 0;
    _totalTransferencia = 0;
    _totalTarjeta = 0;

    for(var reporte in _reportes) {
      switch(reporte.tipoPago.toLowerCase()) {
        case 'efectivo':
          _pagosEfectivo.add(reporte);
          _totalEfectivo += reporte.montoPago;
          break;

        case 'transferencia':
          _pagosTransferencia.add(reporte);
          _totalTransferencia += reporte.montoPago;
          break;
        
        case 'tarjeta':
          _pagosTarjeta.add(reporte);
          _totalTarjeta += reporte.montoPago;
          break;
      }
    }

    if(_sumaTotal > 0) {
      _porcentajeEfectivo = (_totalEfectivo / _sumaTotal) * 100;
      _porcentajeTransferencia = (_totalTransferencia / _sumaTotal) * 100;
      _porcentajeTarjeta = (_totalTarjeta / _sumaTotal) * 100;
    } else {
      _porcentajeEfectivo = 0;
      _porcentajeTransferencia = 0;
      _porcentajeTarjeta = 0;
    }
    notifyListeners();
  }

  // -------------------------------------FILTRADO POR TIPO PAGO Y FECHAS-------------

  Future<void> cargarReportesFiltrados(String tipoPago, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      txtFechaInicioFiltro = DateFormat('dd-MM-yyyy').format(fechaInicio);
      txtFechaFinFiltro = DateFormat('dd-MM-yyyy').format(fechaFin);

      txtTipoPago = tipoPago;

      final tipoPagoFiltrado = tipoPago.toLowerCase();

      _reportesFiltrados = _reportes.where((reporte) {
        final tipo = reporte.tipoPago.toLowerCase() == tipoPagoFiltrado;
        final rango = reporte.fechaPago.isAfter(fechaInicio.subtract(Duration(seconds: 1))) && 
                      reporte.fechaPago.isBefore(fechaFin.add(Duration(days: 1)));
        return tipo && rango;
      }).toList();

      _sumaTotal = _reportesFiltrados.fold<double>(0, (suma, item) => suma += item.montoPago);

      _reportesMostrar = _reportesFiltrados;
      clasificarPagosPorTipoFiltrados();
      notifyListeners();
    }catch (e) {
      print('❌ Error al filtrar reportes: $e');
    }
  }

  void reiniciarFiltros() {
    txtFechaInicioFiltro = null;
    txtFechaFinFiltro = null;
    txtTipoPago = "Todos";
    cargarReportes();
  }

  void clasificarPagosPorTipoFiltrados() {
    //Limpiar listas
    _pagosEfectivo = [];
    _pagosTransferencia = [];
    _pagosTarjeta = [];

    _totalEfectivo = 0;
    _totalTransferencia = 0;
    _totalTarjeta = 0;

    for(var reporte in _reportesFiltrados) {
      switch(reporte.tipoPago.toLowerCase()) {
        case 'efectivo':
          _pagosEfectivo.add(reporte);
          _totalEfectivo += reporte.montoPago;
          break;

        case 'transferencia':
          _pagosTransferencia.add(reporte);
          _totalTransferencia += reporte.montoPago;
          break;
        
        case 'tarjeta':
          _pagosTarjeta.add(reporte);
          _totalTarjeta += reporte.montoPago;
          break;
      }
    }

    if(_sumaTotal > 0) {
      _porcentajeEfectivo = (_totalEfectivo / _sumaTotal) * 100;
      _porcentajeTransferencia = (_totalTransferencia / _sumaTotal) * 100;
      _porcentajeTarjeta = (_totalTarjeta / _sumaTotal) * 100;
    } else {
      _porcentajeEfectivo = 0;
      _porcentajeTransferencia = 0;
      _porcentajeTarjeta = 0;
    }
    notifyListeners();
  }

  Future<void> cargarReportesFiltradosTodosPorFecha(DateTime fechaInicio, DateTime fechaFin) async {
    try {
      txtFechaInicioFiltro = DateFormat('dd-MM-yyyy').format(fechaInicio);
      txtFechaFinFiltro = DateFormat('dd-MM-yyyy').format(fechaFin);
      txtTipoPago = 'Todos';

      _reportesFiltrados = _reportes.where((reporte) {
        final rango = reporte.fechaPago.isAfter(fechaInicio.subtract(Duration(seconds: 1))) && 
                      reporte.fechaPago.isBefore(fechaFin.add(Duration(days: 1)));
        return rango;
      }).toList();

      _sumaTotal = _reportesFiltrados.fold<double>(0, (suma, item) => suma += item.montoPago);

      _reportesMostrar = _reportesFiltrados;
      clasificarPagosPorTipoFiltrados();
      notifyListeners();
    }catch (e) {
      print('❌ Error al filtrar reportes: $e');
    }
  }
}