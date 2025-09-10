class ClienteModel {
  int? id;
  String nombres;
  String apellidos;
  String telefono;
  String estatus;
  String? fotoPath;
  String? telefonoEmergencia;
  String? nombreEmergencia;
  String? correo;
  String? observaciones;

  ClienteModel({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.estatus,
    this.fotoPath,
    this.telefonoEmergencia,
    this.nombreEmergencia,
    this.correo,
    this.observaciones,
  });

  //Cliente -> Map
  //Metodo para insertar a base de datos
  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'estatus': estatus,
      'fotoPath': fotoPath,
      'telefono_emergencia': telefonoEmergencia,
      'nombre_emergencia': nombreEmergencia,
      'correo': correo,
      'observaciones': observaciones,
    };
  }

  // Map -> Cliente
  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      id: map['id'], 
      nombres: map['nombres'], 
      apellidos: map['apellidos'], 
      telefono: map['telefono'], 
      estatus: map['estatus'],
      fotoPath: map['fotoPath'],
      telefonoEmergencia: map['telefono_emergencia'],
      nombreEmergencia: map['nombre_emergencia'],
      correo: map['correo'],
      observaciones: map['observaciones'],
      );
  }
}
