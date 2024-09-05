class Incidente {
  int? id;
  String parque;
  DateTime data;
  int gravidade;
  String? descricao;

  Incidente({
    this.id,
    required this.parque,
    required this.data,
    required this.gravidade,
    this.descricao
  });

  factory Incidente.fromDB(Map<String, dynamic> db) {
    return Incidente(
        id: int.parse(db['id']),
        parque: db['parque'],
        data: DateTime.parse(db['data']),
        gravidade: db['gravidade'],
        descricao: db['descricao']
    );
  }

  Map<String,dynamic> toDb() {
    return {
      'id': '$id',
      'parque': parque,
      'data': data.toString(),
      'gravidade': gravidade,
      if (descricao != null) 'descricao': descricao
    };
  }

  @override
  String toString() {
    return 'Incidente{id: $id, parque: $parque, gravidade: $gravidade}';
  }
}