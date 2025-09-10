class ClienteDisciplinaModel {
  int? id;
  int idCliente;
  int idDisciplina;

  ClienteDisciplinaModel({
    this.id,
    required this.idCliente,
    required this.idDisciplina,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'id_disciplina': idDisciplina,
    };
  }

  factory ClienteDisciplinaModel.fromMap(Map<String, dynamic> map) {
    return ClienteDisciplinaModel(
      id: map['id'],
      idCliente: map['id_cliente'],
      idDisciplina: map['id_disciplina'],
    );
  }
}