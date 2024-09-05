import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import '../models/estado_parque.dart';
import '../models/parque.dart';
import '../repository/parque_repository.dart';
import 'detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final locationController = Location();
  LatLng? currentPosition;
  Map<PolylineId, Polyline> polylines = {};
  List<Parque> _parques = [];

  @override
  void initState() {
    super.initState();
    final parqueRepository = context.read<ParqueRepository>();
    final futureParque = parqueRepository.getParques();

    futureParque.then((parques) {
      setState(() {
        _parques = parques;

        _parques.removeWhere((parque) => parque.tipoParque == null);
      });
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
    _updatePolylines();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentPosition!,
                  zoom: 13,
                ),
                markers: _parquesMarker(),
                polylines: Set<Polyline>.of(polylines.values),
              ),
      );

  Set<Marker> _parquesMarker() {
    Set<Marker> markers = {
      if (currentPosition != null)
        Marker(
          markerId: const MarkerId('currentLocation'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          position: currentPosition!,
          onTap: () => _showLocationInfo(),
        ),
    };

    for (int i = 0; i < _parques.length; i++) {
      double latitude = double.parse(_parques[i].latitude!);
      double longitude = double.parse(_parques[i].longitude!);
      switch (_parques[i].estadoParque) {
        case EstadoParque.LIVRE:
          markers.add(
            Marker(
              markerId: MarkerId(_parques[i].idParque),
              position: LatLng(latitude, longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              onTap: () => _showParqueInfo(_parques[i]),
            ),
          );
          break;
        case EstadoParque.PARCIALMENTE_LOTADO:
          markers.add(
            Marker(
              markerId: MarkerId(_parques[i].idParque),
              position: LatLng(latitude, longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow),
              onTap: () => _showParqueInfo(_parques[i]),
            ),
          );
          break;
        case EstadoParque.LOTADO:
          markers.add(
            Marker(
              markerId: MarkerId(_parques[i].idParque),
              position: LatLng(latitude, longitude),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () => _showParqueInfo(_parques[i]),
            ),
          );
          break;
        case null:
          break;
      }
    }

    return markers;
  }

  Future<void> _updatePolylines() async {
    List<LatLng> allPoints = [];

    if (currentPosition != null) {
      LatLng startPoint = currentPosition!;
      allPoints.add(startPoint);

      for (int i = 0; i < _parques.length; i++) {
        double latitude = double.parse(_parques[i].latitude!);
        double longitude = double.parse(_parques[i].longitude!);
        LatLng nextPoint = LatLng(latitude, longitude);
        List<LatLng> segmentPoints =
            await fetchPolylinePoints(startPoint, nextPoint);
        allPoints.addAll(segmentPoints);
        startPoint = nextPoint;
      }

      //coordenaditas temporarias
      List<LatLng> finalSegmentPoints =
          await fetchPolylinePoints(startPoint, LatLng(37.3861, -122.0839));
      allPoints.addAll(finalSegmentPoints);
    }
  }

  Future<void> fetchLocationUpdates() async {
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

    locationController.onLocationChanged.listen((currentLocation) {
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

  Future<List<LatLng>> fetchPolylinePoints(LatLng start, LatLng end) async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyD26FJFsHStUubQu2eYLfLC8mbnq4SKJiw',
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  void _showParqueInfo(Parque parque) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                parque.nome!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailPage(
                                parque: parque,
                                parquesOrderById: [],
                                index: 0,
                              )));
                },
                child: const Text('Ver detalhes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationInfo() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('SUA LOCALIZAÇÃO')));
  }
}
