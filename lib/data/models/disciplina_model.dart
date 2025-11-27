class DisciplinaModel {
  int? id;
  String nombre;
  String? descripcion;
  int activa; // 1 = activa, 0 = inactiva

  DisciplinaModel({
    this.id,
    required this.nombre,
    this.descripcion,
    this.activa = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'activa': activa,
    };
  }

  factory DisciplinaModel.fromMap(Map<String, dynamic> map) {
    return DisciplinaModel(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      activa: map['activa'] != null ? map['activa'] as int : 1,
    );
  }
}