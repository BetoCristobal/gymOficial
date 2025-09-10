import 'package:flutter/material.dart';
import 'package:mygym/data/models/pago_model.dart';
import '../data/repositories/pago_repository.dart';

class PagoProvider extends ChangeNotifier {
  final PagoRepository pagoRepo;

  PagoProvider(this.pagoRepo);

  List<PagoModel> _pagos = [];
  List<PagoModel> _pagosPorCliente = [];
  PagoModel? _ultimoPagoCliente;

  List<PagoModel> get pagos => _pagos;
  List<PagoModel> get pagosPorCliente => _pagosPorCliente;
  PagoModel? get ultimoPagoCliente => _ultimoPagoCliente;

  Future<void> cargarPagosTodosById() async {
    try{
      _pagos = await pagoRepo.getPagosTodosOrdenadosById();
      notifyListeners();
      print("✅Se obtuvieron todos los pagos");
    } catch(e) {
      print("❌ Error al cargar todos pagos: $e");
    }
  }

  Future<void> cargarPagosClientePorId(int idCliente) async {
    try{
      _pagosPorCliente = await pagoRepo.getPagosPorIdCliente(idCliente);
      notifyListeners();
      print("✅Se obtuvieron los pagos POR CLIENTE");
    } catch(e){
      print("❌ Error al cargar los PAGOS POR CLIENTE: $e");
    }
  }

  Future<void> agregarPago(int idCliente, double monto, DateTime fechaPago, DateTime proximaFechaPago, String tipoPago) async {
    try{
      final nuevoPago = PagoModel(
        idCliente: idCliente, 
        montoPago: monto, 
        fechaPago: fechaPago, 
        proximaFechaPago: proximaFechaPago, 
        tipoPago: tipoPago
      );
      await pagoRepo.insertPago(nuevoPago);
      print("✅Se agrego nuevo pago: $nuevoPago");
      await cargarPagosClientePorId(idCliente);
      await cargarPagosTodosById();
    }catch(e) {
      print("❌Error al agregar pago: $e");
    }
  }

  Future<void> actualizarPago(int id, int idCliente, double monto, DateTime fechaPago, DateTime proximaFechaPago, String tipoPago) async {
    try{
      final pagoActualizado = PagoModel(
        id: id,
        idCliente: idCliente, 
        montoPago: monto, 
        fechaPago: fechaPago, 
        proximaFechaPago: proximaFechaPago, 
        tipoPago: tipoPago
      );
      await pagoRepo.updatePago(pagoActualizado);
      notifyListeners();
      await cargarPagosClientePorId(idCliente);
      await cargarPagosTodosById();
    } catch(e) {
      print("❌Error al actualizar pago: $e");
    }
  }

  Future<void> eliminarPago(int id, int idCliente) async {
    try{
      await pagoRepo.deletePago(id);
      notifyListeners();
      await cargarPagosClientePorId(idCliente);
      await cargarPagosTodosById();      
    }catch(e) {
      print("❌ Error al eliminar pago: $e");
    }
  }

  //--------CARGAR ULTIMO PAGO POR CLIENTE
  Future<PagoModel?> obtenerUltimoPagoCliente(int idCliente) async {
    try {
      _ultimoPagoCliente = await pagoRepo.obtenerUltimoPago(idCliente);
      return _ultimoPagoCliente; 
    } catch(e) {
      print("❌ Error al obtener ultimo pago: $e");
      return null;
    }
  }
}