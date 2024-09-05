import 'dart:math';
import 'package:app_emel_cm/models/incidente.dart';
import 'package:app_emel_cm/pages/detail_page.dart';
import 'package:app_emel_cm/pages/main_page.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../data/incident_database.dart';
import '../models/parque.dart';
import '../repository/parque_repository.dart';

class IncidentePage extends StatefulWidget {
  final Parque parque;

  const IncidentePage({super.key, required this.parque});

  @override
  State<IncidentePage> createState() => _IncidentePageState();
}

class _IncidentePageState extends State<IncidentePage> {
  final _formKey = GlobalKey<FormState>();

  late String _parque;
  late DateTime _data;
  late int _gravidade;
  String? _descricao;

  @override
  Widget build(BuildContext context) {
    final parqueRepository = context.watch<ParqueRepository>();

    return Scaffold(
        body: FutureBuilder(
            future: parqueRepository.getNomeParques(),
            builder: (_, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  return const Text('Ma boy deu erro!');
                } else {
                  return buildIncidente(snapshot.data!);
                }
              }
            }));
  }

  Widget buildIncidente(List<String> parques) {
    final database = context.read<IncidentDatabase>();

    String? selectedValue = parques.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registo de incidente'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D5920),
      ),
      body: Container(
        color: const Color(0xFFEFF2D5),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Builder(
          builder: (context) => Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Lista de parquitos
                DropdownButtonFormField(
                    items: parques
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.toString(),
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedValue = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nome do parque',
                      labelStyle: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSaved: (value) => setState(() => _parque = value!),
                    validator: (value) {
                      if (value == null) {
                        return 'Escolha um parque';
                      }
                      return null;
                    }),
                DateTimeFormField(
                    decoration: InputDecoration(
                      labelText: 'Data e hora',
                      labelStyle: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (DateTime? value) {
                      print(value);
                    },
                    onSaved: (value) => setState(() => _data = value!),
                    validator: (value) {
                      if (value == null) {
                        return 'Escolha uma data e hora';
                      } else if (value.isAfter(DateTime.now())) {
                        return 'Escolha uma data válida';
                      }
                      return null;
                    }),
                FormBuilderChoiceChip(
                    name: 'gravidade',
                    alignment: WrapAlignment.spaceEvenly,
                    direction: Axis.horizontal,
                    decoration: InputDecoration(
                      labelText: 'Gravidade',
                      labelStyle: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    options: const [
                      FormBuilderChipOption(
                        value: 1,
                        child: Text('1'),
                      ),
                      FormBuilderChipOption(
                        value: 2,
                        child: Text('2'),
                      ),
                      FormBuilderChipOption(
                        value: 3,
                        child: Text('3'),
                      ),
                      FormBuilderChipOption(
                        value: 4,
                        child: Text('4'),
                      ),
                      FormBuilderChipOption(
                        value: 5,
                        child: Text('5'),
                      ),
                    ],
                    onChanged: (value) => _gravidade = value!,
                    onSaved: (value) => setState(() => _gravidade = value!),
                    validator: (value) {
                      if (value == null) {
                        return 'Escolha uma gravidade';
                      }
                      return null;
                    }),
                TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: 5,
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSaved: (value) => setState(() => _descricao = value!),
                    validator: (value) {
                      if (_gravidade >= 4 && value == '') {
                        return 'Descrição obrigatória para gravidade igual ou superior a 4';
                      }
                      return null;
                    }),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final incidentModel = Incidente(
                            id: Random().nextInt(100),
                            parque: _parque,
                            data: _data,
                            descricao: _descricao,
                            gravidade: _gravidade);

                        //widget.parque.addIncidente(incidentModel);
                        database.insert(incidentModel);

                        if (widget.parque.idParque == '0') {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()));
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                        parque: widget.parque,
                                        parquesOrderById: [],
                                        index: 0,
                                      )));
                        }
                      }
                    },
                    child: const Text('Avançar'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
