class PagoModel {
  int? id;
  int idCliente;
  double montoPago;
  DateTime fechaPago;
  DateTime proximaFechaPago;
  String tipoPago;

  PagoModel({
    this.id,
    required this.idCliente,
    required this.montoPago,
    required this.fechaPago,
    required this.proximaFechaPago,
    required this.tipoPago,
  });

  // Pago -> Map PARA GUARDAR EN BD
  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'id_cliente': idCliente,
      'monto_pago': montoPago,
      'fecha_pago': fechaPago.toIso8601String(),
      'proxima_fecha_pago': proximaFechaPago.toIso8601String(),
      'tipo_pago': tipoPago
    };
  }

  //Map -> Pago, de la BD  a PagoModel
  factory PagoModel.fromMap(Map<String, dynamic> map){
    return PagoModel(
      id: map['id'], 
      idCliente: map['id_cliente'], 
      montoPago: map['monto_pago'], 
      fechaPago: DateTime.parse(map['fecha_pago']), 
      proximaFechaPago: DateTime.parse(map['proxima_fecha_pago']), 
      tipoPago: map['tipo_pago']
    );
  }
}