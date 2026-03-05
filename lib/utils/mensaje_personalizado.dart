import 'dart:convert';

class MensajePersonalizado {
  String titulo;
  String mensaje;

  MensajePersonalizado({required this.titulo, required this.mensaje});

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'mensaje': mensaje,
      };

  factory MensajePersonalizado.fromMap(Map<String, dynamic> map) => MensajePersonalizado(
        titulo: map['titulo'],
        mensaje: map['mensaje'],
      );

  static String encodeList(List<MensajePersonalizado> mensajes) =>
      jsonEncode(mensajes.map((e) => e.toMap()).toList());

  static List<MensajePersonalizado> decodeList(String source) {
    final List<dynamic> data = jsonDecode(source);
    return data.map((e) => MensajePersonalizado.fromMap(e)).toList();
  }
}
