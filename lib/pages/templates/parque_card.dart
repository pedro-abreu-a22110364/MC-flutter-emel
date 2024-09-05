import 'package:app_emel_cm/models/estado_parque.dart';
import 'package:app_emel_cm/pages/detail_page.dart';
import 'package:flutter/material.dart';
import '../../models/parque.dart';

class ParqueCard extends StatefulWidget {
  late Parque parque;
  late List<Parque> parquesOrderById;
  late int index;

  ParqueCard(
      {super.key,
      required this.parque,
      required this.parquesOrderById,
      required this.index});

  @override
  State<ParqueCard> createState() => _ParqueCard();
}

class _ParqueCard extends State<ParqueCard> {
  Color? _color;

  @override
  Widget build(BuildContext context) {
    switch (widget.parque.estadoParque) {
      case EstadoParque.LIVRE:
        _color = Colors.green;
        break;
      case EstadoParque.LOTADO:
        _color = Colors.red;
        break;
      case EstadoParque.PARCIALMENTE_LOTADO:
        _color = Colors.yellow;
        break;
      case null:
        break;
    }

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
        child: Card(
          color: const Color(0xFFEFF2D5),
          elevation: 5,
          child: ListTile(
            title: Text(
              widget.parque.nome! ?? '',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6.0),
                Text(
                  '${widget.parque.distancia} km',
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
                      color: _color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(widget.parque.estadoParque!.name.toLowerCase(),
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        ));
  }
}
