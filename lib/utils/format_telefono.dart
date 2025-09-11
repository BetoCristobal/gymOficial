String formatTelefono(String? telefono) {
  if (telefono == null || telefono.length != 10) return telefono ?? '';
  return '${telefono.substring(0, 2)}-${telefono.substring(2, 6)}-${telefono.substring(6, 10)}';
}