import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karlo_mapbox/bloc/map_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ExistingPositionsPage extends StatelessWidget {
  final List<Position> _existingPositions = [
    Position(106.8456, -6.2088), // Jakarta
    Position(106.800160, -6.228233),
    Position(106.818286, -6.227602),
    Position(106.824562, -6.229333),
    Position(106.817991, -6.208403),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: Scaffold(
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return Center(child: LinearProgressIndicator());
            }

            return Stack(
              children: [
                MapWidget(
                  onMapCreated: (controller) {
                    context.read<MapBloc>().add(MapInitialized(controller));
                    context.read<MapBloc>().add(AddMarkers(_existingPositions));
                    context
                        .read<MapBloc>()
                        .add(FetchAndDisplayRoute(_existingPositions));
                    (styleUri: MapboxStyles.DARK);
                  },
                  cameraOptions: CameraOptions(
                    center: Point(coordinates: Position(106.8256, -6.238233)),
                    zoom: 12.0,
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showLocationList(context);
                    },
                    child: Icon(Icons.location_on),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLocationList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: _existingPositions.length,
            itemBuilder: (context, index) {
              final position = _existingPositions[index];
              return ListTile(
                leading: Icon(Icons.location_pin),
                title: Text('Position ${index + 1}'),
                subtitle: Text('Lat: ${position.lat}, Lng: ${position.lng}'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<MapBloc>().add(MoveCameraToPosition(position));
                },
              );
            },
          ),
        );
      },
    );
  }
}
