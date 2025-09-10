
String asignarEmoji(String estatus) {
  switch (estatus) {
    case 'Pago vencido':
      return '❌'; // Emoji para vencido
    case 'Pago urgente':
      return '⚠️'; // Emoji para urgente
    case 'Próximo a pagar':
      return '🟡'; // Emoji para próximo
    case 'Pago al corriente':
      return '✅'; // Emoji para activo
    default:
      return ''; // Emoji por defecto si no coincide con ningún caso
  }
}