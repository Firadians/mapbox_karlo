import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karlo_mapbox/bloc/search_location_bloc.dart';
import 'package:karlo_mapbox/home_screen.dart';
import 'package:karlo_mapbox/marked_screen.dart';
import 'package:karlo_mapbox/search_screen.dart';
import 'package:karlo_mapbox/strings.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(ACCESS_TOKEN);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map App',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/markedScreen': (context) => ExistingPositionsPage(),
        '/searchScreen': (context) => BlocProvider(
              create: (_) => SearchLocationBloc(),
              child: SearchLocationPage(),
            ),
      },
    );
  }
}
