import 'package:app_emel_cm/models/estado_parque.dart';
import 'package:app_emel_cm/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/incident_database.dart';
import '../../models/incidente.dart';
import '../../models/parque.dart';

class ParqueTile extends StatefulWidget {
  late Parque parque;
  late List<Parque> parquesOrderById;
  late int index;

  ParqueTile(
      {super.key,
      required this.parque,
      required this.parquesOrderById,
      required this.index});

  @override
  State<ParqueTile> createState() => _ParqueTile();
}

class _ParqueTile extends State<ParqueTile> {
  Color? _colorCircle;
  Color? _colorBackground;

  @override
  Widget build(BuildContext context) {
    final database = context.read<IncidentDatabase>();

    switch (widget.parque.estadoParque) {
      case EstadoParque.LIVRE:
        _colorCircle = Colors.green;
        break;
      case EstadoParque.LOTADO:
        _colorCircle = Colors.red;
        break;
      case EstadoParque.PARCIALMENTE_LOTADO:
        _colorCircle = Colors.yellow;
        break;
      case null:
        break;
    }

    switch (widget.parque.metodo) {
      case 'dinheiro':
        _colorBackground = Colors.red;
        break;
      case 'multibanco':
        _colorBackground = Colors.blue;
        break;
      case 'via verde':
        _colorBackground = Colors.green;
        break;
      case null:
        break;
    }

    return FutureBuilder(
        future: database.getIncidentesByParque(widget.parque.nome!),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              return const Text('Ma boy deu erro!');
            } else {
              return buildTile(context, snapshot.data!);
            }
          }
        });
  }

  GestureDetector buildTile(BuildContext context, List<Incidente> incidentes) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(
                        parque: widget.parque,
                        parquesOrderById: widget.parquesOrderById,
                        index: widget.index,
                      )));
        },
        child: ListTile(
          title: Text(
            '${widget.parque.nome!} - ${widget.parque.distancia} km',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
            ),
          ),
          tileColor: _colorBackground,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6.0),
              Text(
                'Número de incidentes: ${incidentes.length}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Parque de ${widget.parque.tipoParque!.name.toLowerCase()}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 60.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: _colorCircle,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(widget.parque.estadoParque!.name.toLowerCase(),
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ));
  }
}
