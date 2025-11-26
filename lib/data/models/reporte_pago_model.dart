class ReportePagoModel {
  final String nombreCliente;
  final DateTime fechaPago;
  final double montoPago;
  final String tipoPago;
  final String? nombreDisciplina;

  ReportePagoModel({
    required this.nombreCliente,
    required this.fechaPago,
    required this.montoPago,
    required this.tipoPago,
    this.nombreDisciplina,
  });
}