class ReportePagoModel {
  final String nombreCliente;
  final DateTime fechaPago;
  final double montoPago;
  final String tipoPago;

  ReportePagoModel({
    required this.nombreCliente,
    required this.fechaPago,
    required this.montoPago,
    required this.tipoPago,
  });
}