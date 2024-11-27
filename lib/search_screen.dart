import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:karlo_mapbox/strings.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class SearchLocationPage extends StatefulWidget {
  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  late MapboxMap _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _lastSearchMarker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center:
                    Point(coordinates: Position(106.8456, -6.2088)), // Jakarta
                zoom: 13.0,
              ),
            ),
            Positioned(
              top: 20,
              left: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
            if (_searchResults.isNotEmpty)
              Positioned(
                top: 80,
                left: 15,
                right: 15,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: Text(result['name']),
                        subtitle: Text(result['address']),
                        onTap: () => _onSearchResultSelected(result),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap controller) async {
    _mapController = controller;
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$geocodingApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        setState(() {
          _searchResults = features.map((feature) {
            return {
              'name': feature['text'],
              'address': feature['place_name'],
              'coordinates': feature['geometry']['coordinates'],
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error searching locations: $e');
    }
  }

  Future<void> _onSearchResultSelected(Map<String, dynamic> result) async {
    final coordinates = result['coordinates'] as List;
    final position =
        Position(coordinates[0] as double, coordinates[1] as double);
    final name = result['name'];

    setState(() {
      _searchResults.clear();
      _searchController.clear();
    });

    if (_pointAnnotationManager == null) {
      _pointAnnotationManager =
          await _mapController.annotations.createPointAnnotationManager();
    }

    if (_lastSearchMarker != null) {
      await _pointAnnotationManager!.delete(_lastSearchMarker!);
      _lastSearchMarker = null;
    }

    await _mapController.setCamera(
      CameraOptions(center: Point(coordinates: position), zoom: 12.0),
    );

    _lastSearchMarker = await _addSearchMarker(position, name);

    await _sendCoordinatesToNative(
        position.lat.toDouble(), position.lng.toDouble());
  }

  Future<PointAnnotation> _addSearchMarker(
      Position position, String name) async {
    if (_pointAnnotationManager == null) {
      _pointAnnotationManager =
          await _mapController.annotations.createPointAnnotationManager();
    }

    final ByteData bytes = await rootBundle.load('assets/marker_red.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: Point(coordinates: position),
      image: imageData,
      iconSize: 0.15,
      textField: name,
      textColor: 0xFFFF0000,
      textHaloColor: 0xFFFF0000,
      textHaloWidth: 0.5,
      textOffset: [0, -2.5],
    );

    return await _pointAnnotationManager!.create(pointAnnotationOptions);
  }

  Future<void> _sendCoordinatesToNative(
      double latitude, double longitude) async {
    const platform = MethodChannel('com.example.mapbox/location');
    try {
      await platform.invokeMethod('showCoordinates', {
        'latitude': latitude,
        'longitude': longitude,
      });
      print(
          "Coordinates sent to native: Latitude=$latitude, Longitude=$longitude");
    } catch (e) {
      print("Error sending coordinates to native: $e");
    }
  }
}
