class DisciplinaModel {
  int? id;
  String nombre;
  String? descripcion;

  DisciplinaModel({
    this.id,
    required this.nombre,
    this.descripcion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  factory DisciplinaModel.fromMap(Map<String, dynamic> map) {
    return DisciplinaModel(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
    );
  }
}