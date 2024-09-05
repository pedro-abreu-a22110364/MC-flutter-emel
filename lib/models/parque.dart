import 'dart:math';
import 'package:app_emel_cm/models/estado_parque.dart';
import 'package:app_emel_cm/models/tipo_parque.dart';
import 'package:app_emel_cm/models/incidente.dart';
import 'package:flutter/cupertino.dart';

class Parque extends ChangeNotifier {
  String idParque;
  String? nome;
  int? lotacaoReal;
  int? lotacaoMax;
  DateTime? data;
  int? distancia;
  String? latitude;
  String? longitude;
  TipoParque? tipoParque;
  EstadoParque? estadoParque;
  List<Incidente> incidentes = [];

  String? metodo;

  Parque(
      {
        required this.idParque,
        required this.nome,
        required this.lotacaoReal,
        required this.lotacaoMax,
        required this.tipoParque,
        required this.latitude,
        required this.longitude,
        required this.metodo
      }) {
    estadoParque = calculaEstadoParque();
  }

  void addIncidente(Incidente incidente) {
    incidentes.add(incidente);
    notifyListeners();
  }

  EstadoParque calculaEstadoParque() {
    if (lotacaoReal! - lotacaoMax! == 0) {
      return EstadoParque.LOTADO;
    } else if ((lotacaoReal! * 100) / lotacaoMax! >= 50) {
      return EstadoParque.PARCIALMENTE_LOTADO;
    } else {
      return EstadoParque.LIVRE;
    }
  }

  void calculateDistance(
      double lat1, double lon1) {
    const p = 0.017453292519943295; // Pi/180
    const c = cos;
    final a = 0.5 -
        c((double.parse(latitude!) - lat1) * p) / 2 +
        c(lat1 * p) * c(double.parse(latitude!) * p) * (1 - c((double.parse(longitude!) - lon1) * p)) / 2;
    distancia = (12742 * asin(sqrt(a))).round(); // 2 * R; R = 6371 km
  }

  factory Parque.fromJSON(Map<String, dynamic> json){
    return Parque(
        idParque: json['id_parque'],
        nome: json['nome'],
        lotacaoReal: json['ocupacao'],
        lotacaoMax: json['capacidade_max'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        tipoParque: stringToTipoParque(json['tipo']),
        metodo: json['pagamento']
    );
  }

  factory Parque.fromDB(Map<String, dynamic> db){
    return Parque(
        idParque: db['id'],
        nome: db['nome'],
        lotacaoReal: db['ocupacao'],
        lotacaoMax: db['capacidade_max'],
        latitude: db['latitude'],
        longitude: db['longitude'],
        tipoParque:  stringToTipoParque(db['tipo']),
        metodo: db['pagamento']
    );
  }

  Map<String,dynamic> toDb() {
    return {
      'id': idParque,
      if (nome != null) 'nome': nome,
      if (lotacaoReal != null) 'lotacao_real': lotacaoReal,
      if (lotacaoMax != null) 'lotacao_max': lotacaoMax,
      if (data != null) 'data': data.toString(),
      if (distancia != null) 'distancia': distancia,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (tipoParque != null) 'tipo_parque': tipoParque,
      if (estadoParque != null) 'estado_parque': estadoParque,
    };
  }

  @override
  String toString() {
    return 'Parque{idParque: $idParque, nome: $nome, lotacaoReal: $lotacaoReal, lotacaoMax: $lotacaoMax, tipoParque: $tipoParque}';
  }
}
