part of 'search_location_bloc.dart';

abstract class SearchLocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchLocationEvent {
  final String query;

  SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchResultSelected extends SearchLocationEvent {
  final Map<String, dynamic> result;

  SearchResultSelected(this.result);

  @override
  List<Object?> get props => [result];
}
