import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  final List<LatLng> _polylinePoints = [];
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _location.onLocationChanged.listen((locationData) {
      setState(() {
        final LatLng latLng =
            LatLng(locationData.latitude!, locationData.longitude!);
        _polylinePoints.add(latLng);
        _updateMarkerPosition(latLng);
      });
    });
    _animateToCurrentLocation();
  }

  void _animateToCurrentLocation() async {
    var locationData = await _location.getLocation();
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void _updateMarkerPosition(LatLng latLng) {
    _marker = Marker(
      markerId: const MarkerId("my_location"),
      position: latLng,
      infoWindow: InfoWindow(
        title: "My current location",
        snippet: "Lat: ${latLng.latitude}, Lng: ${latLng.longitude}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Time Location Tracker'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 15.0,
        ),
        markers: _marker != null ? Set<Marker>.of([_marker!]) : {},
        polylines: {
          Polyline(
            polylineId: const PolylineId("tracking"),
            color: Colors.blue,
            points: _polylinePoints,
            width: 5,
          ),
        },
      ),
    );
  }
}
