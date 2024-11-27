part of 'map_bloc.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {}

class MapError extends MapState {
  final String message;

  MapError(this.message);
}
