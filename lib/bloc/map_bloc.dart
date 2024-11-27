import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:karlo_mapbox/strings.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  late MapboxMap _mapController;
  PointAnnotationManager? _pointAnnotationManager;

  MapBloc() : super(MapInitial()) {
    on<MapInitialized>(_onMapInitialized);
    on<AddMarkers>(_onAddMarkers);
    on<FetchAndDisplayRoute>(_onFetchAndDisplayRoute);
    on<MoveCameraToPosition>(_onMoveCameraToPosition); // New handler
  }

  void _onMapInitialized(MapInitialized event, Emitter<MapState> emit) async {
    _mapController = event.controller;
    emit(MapLoaded());
  }

  Future<void> _onAddMarkers(AddMarkers event, Emitter<MapState> emit) async {
    try {
      if (_pointAnnotationManager == null) {
        _pointAnnotationManager =
            await _mapController.annotations.createPointAnnotationManager();
      }

      final ByteData bytes = await rootBundle.load('assets/marker.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      for (var position in event.positions) {
        PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(coordinates: position),
          image: imageData,
          iconSize: 0.05,
        );

        await _pointAnnotationManager!.create(pointAnnotationOptions);
      }
    } catch (e) {
      emit(MapError("Error adding markers: $e"));
    }
  }

  Future<void> _onFetchAndDisplayRoute(
      FetchAndDisplayRoute event, Emitter<MapState> emit) async {
    final String coordinatesString = event.positions
        .map((position) => '${position.lng},${position.lat}')
        .join(';');

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinatesString?geometries=geojson&steps=true&access_token=$DIRECTIONS_API_TOKEN';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'];

        final List<Position> routePositions = coordinates
            .map<Position>(
                (coord) => Position(coord[0] as double, coord[1] as double))
            .toList();

        final polylineAnnotationManager =
            await _mapController.annotations.createPolylineAnnotationManager();
        await polylineAnnotationManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: routePositions),
            lineColor: 0xFF0080FF,
            lineWidth: 8.0,
          ),
        );
      } else {
        emit(MapError('Failed to fetch directions: ${response.body}'));
      }
    } catch (e) {
      emit(MapError("Error fetching route: $e"));
    }
  }

  Future<void> _onMoveCameraToPosition(
      MoveCameraToPosition event, Emitter<MapState> emit) async {
    try {
      await _mapController.flyTo(
          CameraOptions(
            center: Point(coordinates: event.position),
            zoom: 15.0,
          ),
          MapAnimationOptions());
    } catch (e) {
      emit(MapError("Error moving camera: $e"));
    }
  }
}
