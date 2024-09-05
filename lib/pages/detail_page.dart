import 'package:app_emel_cm/data/incident_database.dart';
import 'package:app_emel_cm/pages/incidente_page.dart';
import 'package:app_emel_cm/pages/templates/incidente_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incidente.dart';
import '../models/parque.dart';

class DetailPage extends StatefulWidget {
  late Parque parque;
  late List<Parque> parquesOrderById;
  late int index;

  DetailPage(
      {super.key,
      required this.parque,
      required this.parquesOrderById,
      required this.index});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    debugPrint('ENTREI NO PARQUE COM O ID ${widget.parque.idParque}');
    final database = context.read<IncidentDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parque.nome ?? '',
            style:
                const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D5920),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Different icon for back button
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Container(
          color: const Color(0xFF8DBF41),
          child: FutureBuilder(
              future: database.getIncidentesByParque(widget.parque.nome!),
              builder: (_, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasError) {
                    return const Text('Ma boy deu erro!');
                  } else {
                    return buildParque(snapshot.data!);
                  }
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(
                        parque: widget.parquesOrderById[widget.index == widget.parquesOrderById.length ? 0 : widget.index++],
                        parquesOrderById: widget.parquesOrderById,
                        index: widget.index == widget.parquesOrderById.length ? 0 : widget.index,
                      )));
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        child: const Icon(Icons.car_repair),
      ),
    );
  }

  Widget buildParque(List<Incidente> listIncidentes) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Text('Distância',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Text('${widget.parque.distancia} km'),
          buildDivider(),
          const Text('Tipo de parque',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Text(widget.parque.tipoParque!.name),
          buildDivider(),
          const Text('Lotação',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Text(widget.parque.calculaEstadoParque().name),
          buildDivider(),
          const Text('Horário de pagamento',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const Text('2º a 6º - 7h00 às 24h00'),
          buildDivider(),
          const Text('Pagamento',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Text(widget.parque.metodo!),
          buildDivider(),
          buildIncidentList(listIncidentes),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    // Shape of the button
                    borderRadius: BorderRadius.circular(10.0), // Square edges
                  ),
                  padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => IncidentePage(
                                parque: widget.parque,
                              )));
                },
                child: const Text('REGISTRAR INCIDENTE',
                    style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildIncidentList(List<Incidente> incidentes) {
    return ExpansionTile(
      title: Text('Mostrar incidentes (${incidentes.length})',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      leading: const Icon(Icons.warning),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: incidentes.length,
          itemBuilder: (context, index) {
            return IncidenteCard(incidente: incidentes[index]);
          },
        ),
      ],
    );
  }

  Widget buildDivider() {
    return const Divider(
      thickness: 3.0,
      indent: 10.0,
      endIndent: 10.0,
    );
  }
}
