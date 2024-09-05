import 'dart:convert';
import 'package:app_emel_cm/http/http_client.dart';
import 'package:flutter/material.dart';
import '../models/meteorologia.dart';
import '../models/parque.dart';

class ParqueRepository {

  final HttpClient _client;
  ParqueRepository({required HttpClient client}) : _client = client;
  //respeita encaps e atribui o parametro que recebo a _client

  Future<List<Parque>> getParques() async {
    debugPrint('Entrei no get parques');
    final response = await _client.get(
        url: 'https://run.mocky.io/v3/45626bac-44d1-4918-9b26-bd4b38e793ab',
        headers: {'accept': 'application/json','api_key': '93600bb4e7fee17750ae478c22182dda'});

    //vamos converter de string para um formato um pouco mais estruturado
    if (response.statusCode==200) {
      final responseJSON = jsonDecode(response.body);
      List parquesJSON = responseJSON;

      List<Parque> parques = parquesJSON.map((parquesJSON) => Parque.fromJSON(parquesJSON)).toList();

      return parques;
    }
    else {
      throw Exception('status code: ${response.statusCode}');
    }
  }

  Future<List<String>?> getNomeParques() async {
    List<Parque> parques = await getParques();

    List<String> nomesParqueList = parques.map((parque) => parque.nome!).toList();

    return nomesParqueList;
  }

  Future <Meteorologia> getMeteorologia() async {
    final response = await _client.get(
        url : 'https://api.ipma.pt/open-data/forecast/meteorology/cities/daily/1110600.json');

    if (response.statusCode==200) {
      final responseJSON = jsonDecode(response.body);

      if (!responseJSON.containsKey('data')) {
        throw Exception("A resposta da API não contém a chave 'data' esperada");
      }
      final previsaoHoje = responseJSON['data'][0];
      int horaAtual = DateTime.now().hour;
      print('vejamos o tempo');
      print(responseJSON);

      return Meteorologia.fromMap(previsaoHoje,horaAtual);
    } else {
      throw Exception('status code: ${response.statusCode}');
    }
  }

}