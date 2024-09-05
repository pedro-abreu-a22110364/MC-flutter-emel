import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class Meteorologia {
  String precipitacao;
  String data;
  IconData icone;


  Meteorologia({
    required this.precipitacao, required this.data, required this.icone});

  factory Meteorologia.fromMap(Map<String, dynamic> map, int horaAtual){
    double precipitaProb = double.parse(map['precipitaProb']);
    String precipitacao;
    IconData icone;

    if (horaAtual >= 6 && horaAtual < 20) {
      if (precipitaProb < 40) {
        icone = WeatherIcons.day_sunny;
        precipitacao = 'Sol';
      } else {
        icone = WeatherIcons.rain;
        precipitacao = 'Chuva';
      }
    } else {
      icone = WeatherIcons.night_clear;
      precipitacao = 'Céu limpo';
    }
    print(map['forecastDate']);
    return Meteorologia(
      precipitacao: precipitacao,
      data: map['forecastDate'],
      icone: icone,
    );
  }
}

