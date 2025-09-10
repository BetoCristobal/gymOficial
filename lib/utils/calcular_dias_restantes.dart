//----------------------------------------------CALCULAR TIEMPO RESTANTE 
int calcularDiasRestantes(DateTime proximaFechaPago) {
  Duration diferencia = proximaFechaPago.difference(DateTime.now());
  int diasRestantes = diferencia.inDays;
  return diasRestantes;
}