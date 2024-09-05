import 'package:app_emel_cm/data/incident_database.dart';
import 'package:app_emel_cm/http/http_client.dart';
import 'package:app_emel_cm/pages/main_page.dart';
import 'package:app_emel_cm/repository/parque_repository.dart';
import 'package:app_emel_cm/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/parque_database.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<ParqueRepository>(
          create: (_) => ParqueRepository(client: HttpClient())),
      Provider<IncidentDatabase>(create: (_) => IncidentDatabase()),
      Provider<ParqueDatabase>(create: (_) => ParqueDatabase()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final incidentDatabase = context.read<IncidentDatabase>();
    final parqueDatabase = context.read<ParqueDatabase>();

    return FutureBuilder(
      future: Future.wait([incidentDatabase.init(), parqueDatabase.init()]),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'EMEL',
            theme: lightTheme,
            home: MainPage(),
          );
        } else {
          return const MaterialApp(
              home: Center(
                child: CircularProgressIndicator(),
          ));
        }
      },
    );
  }
}
