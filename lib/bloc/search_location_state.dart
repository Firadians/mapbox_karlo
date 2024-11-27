part of 'search_location_bloc.dart';

abstract class SearchLocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchLocationInitial extends SearchLocationState {}

class SearchLocationLoading extends SearchLocationState {}

class SearchLocationLoaded extends SearchLocationState {
  final List<Map<String, dynamic>> results;

  SearchLocationLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class SearchLocationError extends SearchLocationState {
  final String message;

  SearchLocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchResultCentered extends SearchLocationState {
  final Map<String, dynamic> result;

  SearchResultCentered(this.result);

  @override
  List<Object?> get props => [result];
}
