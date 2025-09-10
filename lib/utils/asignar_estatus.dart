
String asignarEstatus(int diasRestantes, int id) {
  String nuevoEstatus;

  if(diasRestantes < 0) {
    nuevoEstatus = "Pago vencido";
  } else if(diasRestantes >= 0 && diasRestantes < 1) {
    nuevoEstatus = "Pago urgente";
  } else if(diasRestantes >= 1 && diasRestantes <= 3) {
    nuevoEstatus = "Próximo a pagar";
  }else {
    nuevoEstatus = "Pago al corriente";
  }

  return nuevoEstatus;
}