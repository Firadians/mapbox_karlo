import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karlo_mapbox/strings.dart';

part 'search_location_event.dart';
part 'search_location_state.dart';

class SearchLocationBloc
    extends Bloc<SearchLocationEvent, SearchLocationState> {
  SearchLocationBloc() : super(SearchLocationInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchResultSelected>(_onSearchResultSelected);
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<SearchLocationState> emit) async {
    final query = event.query;

    if (query.isEmpty) {
      emit(SearchLocationLoaded([]));
      return;
    }

    emit(SearchLocationLoading());

    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$geocodingApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        final results = features.map((feature) {
          return {
            'name': feature['text'],
            'address': feature['place_name'],
            'coordinates': feature['geometry']['coordinates'],
          };
        }).toList();

        emit(SearchLocationLoaded(results));
      } else {
        emit(SearchLocationError('Failed to fetch results'));
      }
    } catch (e) {
      emit(SearchLocationError('Error: $e'));
    }
  }

  Future<void> _onSearchResultSelected(
      SearchResultSelected event, Emitter<SearchLocationState> emit) async {
    emit(SearchResultCentered(event.result));
  }
}
