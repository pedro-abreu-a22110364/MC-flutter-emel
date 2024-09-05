import 'package:app_emel_cm/pages/templates/parque_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../repository/parque_repository.dart';
import '../models/parque.dart';
import 'package:provider/provider.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Parque> _parques = [];
  LatLng? currentPosition;
  final locationController = Location();
  late Future<void> _fetchData;

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
    _fetchData = _fetchLocationAndData();
  }

  Future<void> _fetchLocationAndData() async {
    await _fetchLocationUpdates();
    await _fetchParques();
    _filterAndSortParques();
  }

  Future<void> _fetchLocationUpdates() async {
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

    final currentLocation = await locationController.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      currentPosition = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
    }
  }

  Future<void> _fetchParques() async {
    final parqueRepository = context.read<ParqueRepository>();
    _parques = await parqueRepository.getParques();
    parquesOrderById = await parqueRepository.getParques();
  }

  void _filterAndSortParques() {
    if (currentPosition != null) {
      _parques.removeWhere((parque) =>
          parque.latitude == null ||
          parque.longitude == null ||
          parque.tipoParque == null);

      parquesOrderById.removeWhere((parque) =>
          parque.latitude == null ||
          parque.longitude == null ||
          parque.tipoParque == null);

      for (Parque parque in _parques) {
        parque.calculateDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );
      }

      for (Parque parque in parquesOrderById) {
        parque.calculateDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );
      }

      _parques.sort((a, b) => a.distancia!.compareTo(b.distancia!));
      parquesOrderById.sort((a, b) => int.parse(a.idParque.split('P0')[1])
          .compareTo(int.parse(b.idParque.split('P0')[1])));
    }
  }

  @override
  void dispose() {
    locationController.onLocationChanged.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: const Color(0xFF8DBF41),
        child: FutureBuilder(
          future: _fetchData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.separated(
                shrinkWrap: true,
                itemCount: _parques.length,
                itemBuilder: (context, index) {
                  return ParqueTile(
                    parque: _parques[index],
                    parquesOrderById: parquesOrderById,
                    index: procuraIndex(parquesOrderById, int.parse(_parques[index].idParque.split('P0')[1])),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.black,
                    thickness: 1,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
