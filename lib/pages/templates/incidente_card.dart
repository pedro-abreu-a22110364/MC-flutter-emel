import 'package:app_emel_cm/models/incidente.dart';
import 'package:flutter/material.dart';

class IncidenteCard extends StatelessWidget {
  late Incidente incidente;

  IncidenteCard({super.key, required this.incidente});

  @override
  Widget build(BuildContext context) {

    return Card(
        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                incidente.parque,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                incidente.data.toString(),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ));
  }
}
