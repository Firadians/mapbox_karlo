part of 'map_bloc.dart';

abstract class MapEvent {}

class MapInitialized extends MapEvent {
  final MapboxMap controller;

  MapInitialized(this.controller);
}

class AddMarkers extends MapEvent {
  final List<Position> positions;

  AddMarkers(this.positions);
}

class FetchAndDisplayRoute extends MapEvent {
  final List<Position> positions;

  FetchAndDisplayRoute(this.positions);
}

class MoveCameraToPosition extends MapEvent {
  final Position position;

  MoveCameraToPosition(this.position);
}
