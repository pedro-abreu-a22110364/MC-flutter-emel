import 'package:app_emel_cm/models/estado_parque.dart';
import 'package:app_emel_cm/models/tipo_parque.dart';
import 'package:app_emel_cm/pages/new_dashboard.dart';
import 'package:app_emel_cm/pages/templates/parque_card.dart';
import 'package:app_emel_cm/repository/parque_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meteorologia.dart';
import '../models/parque.dart';
import 'package:location/location.dart';
import 'incidente_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Parque> parques = [];
  LatLng? currentPosition;
  final locationController = Location();
  Meteorologia? meteorologia;
  bool isLoading = true;

  int parquesEstrutura = 0;
  int parquesSuperficie = 0;

  List<Parque> parquesOrderById = [];

  int procuraIndex(List<Parque> parquesOrder, int id) {
    for (int i = 0; i < parquesOrder.length; i++) {
      if (int.parse(parquesOrder[i].idParque.split('P0')[1]) == id) {
        return i;
      }
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    fetchLocationUpdates();
  }

  Future<void> fetchInitialData() async {
    final parqueRepository = context.read<ParqueRepository>();
    try {
      final results = await Future.wait([
        parqueRepository.getParques(),
        parqueRepository.getMeteorologia(),
      ]);

      if (mounted) {
        setState(() {
          parques = results[0] as List<Parque>;
          parquesOrderById = results[0] as List<Parque>;
          meteorologia = results[1] as Meteorologia;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // Handle error
    }
  }

  void fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        if (mounted) {
          setState(() {
            currentPosition = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    locationController.onLocationChanged.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    parquesEstrutura = 0;
    parquesSuperficie = 0;

    parquesOrderById.sort((a, b) => int.parse(a.idParque.split('P0')[1])
        .compareTo(int.parse(b.idParque.split('P0')[1])));

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Parque> closestParks = _getThreeClosestParks(parques);
    closestParks.sort((p1, p2) => p1.distancia!.compareTo(p2.distancia!));

    List<Parque> filteredParks;
    if (meteorologia!.precipitacao == 'Chuva') {
      filteredParks = closestParks
          .where((parque) =>
              parque.tipoParque == TipoParque.ESTRUTURA ||
              parque.estadoParque == EstadoParque.LIVRE)
          .toList();
    } else {
      filteredParks = closestParks
          .where((parque) =>
              parque.tipoParque == TipoParque.SUPERFICIE ||
              parque.estadoParque == EstadoParque.LIVRE)
          .toList();
    }
    List<Parque> recommendedParks = filteredParks.take(3).toList();

    return buildHome(recommendedParks, meteorologia!);
  }

  List<Parque> _getThreeClosestParks(List<Parque> parques) {
    if (currentPosition == null) return [];

    for (Parque parque in parques) {
      if (parque.tipoParque == TipoParque.SUPERFICIE) {
        parquesSuperficie++;
      } else if (parque.tipoParque == TipoParque.ESTRUTURA) {
        parquesEstrutura++;
      }

      parque.calculateDistance(
          currentPosition!.latitude, currentPosition!.longitude);
    }
    return parques;
  }

  Widget buildHome(List<Parque> parques, Meteorologia meteorologia) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF8DBF41),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40.0),
            buildDiaAtualWidget(context),
            buildMeteorologiaWidget(meteorologia),
            buildRecommendationWidget(meteorologia),
            const SizedBox(height: 50.0),
            Expanded(child: buildList(parques)),
            const SizedBox(height: 5),
            buildIncidentButton(),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewDash(
                        parquesEstrutura: parquesEstrutura,
                        parquesSuperficie: parquesSuperficie,
                      )));
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        child: const Icon(Icons.dashboard),
      ),
    );
  }

  Widget buildDiaAtualWidget(BuildContext context) {
    DateFormat dateFormat =
        DateFormat("EEEE", Localizations.localeOf(context).toString());
    String weekday = dateFormat.format(DateTime.now());

    String locale = Localizations.localeOf(context).toString();
    DateFormat monthFormat = DateFormat("MMMM", locale);
    String month = monthFormat.format(DateTime.now());

    DateTime now = DateTime.now();
    return Text('$weekday, ${now.day} de $month de ${now.year}',
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  Widget buildMeteorologiaWidget(Meteorologia meteorologia) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Meteorologia',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const Expanded(
            child: Divider(thickness: 3.0, indent: 10.0, endIndent: 10.0),
          ),
          Text(meteorologia.precipitacao,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Icon(meteorologia.icone),
        ],
      ),
    );
  }

  Widget buildRecommendationWidget(Meteorologia meteorologia) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Recomendamos',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const Expanded(
            child: Divider(thickness: 3.0, indent: 10.0, endIndent: 10.0),
          ),
          Text(
              'Parques de ${meteorologia.precipitacao == 'Chuva' ? 'Estrutura' : 'Superfície'}',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildList(List<Parque> parques) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: parques.length,
      itemBuilder: (_, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 30.0),
          // Ajuste a margem conforme necessário
          child: ParqueCard(
            parque: parques[index],
            parquesOrderById: parquesOrderById,
            index: procuraIndex(parquesOrderById, int.parse(parques[index].idParque.split('P0')[1])),
          ),
        );
      },
    );
  }

  Widget buildIncidentButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IncidentePage(
                          parque: Parque(
                              idParque: '0',
                              nome: '',
                              lotacaoReal: 100,
                              lotacaoMax: 100,
                              tipoParque: null,
                              latitude: '',
                              longitude: '',
                              metodo: ''),
                        )));
          },
          child: const Text('REGISTRAR INCIDENTE',
              style: TextStyle(fontSize: 20.0)),
        ),
      ],
    );
  }
}
