import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/location_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.searchedLocation != null) {
            _mapController.move(
              LatLng(
                viewModel.searchedLocation!.latitude,
                viewModel.searchedLocation!.longitude,
              ),
              16.0,
            );
          }
        });

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: viewModel.location != null
                      ? LatLng(
                          viewModel.location!.latitude,
                          viewModel.location!.longitude,
                        )
                      : const LatLng(-30.8911, -55.5323),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'br.edu.ifsul.flutter_mapas_osm',
                  ),
                  MarkerLayer(markers: _buildMarkers(viewModel)),
                ],
              ),
              Positioned(
                top: 50,
                left: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar endereço...',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            viewModel.searchLocation(_searchController.text);
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        viewModel.searchLocation(value);
                      }
                    },
                  ),
                ),
              ),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (viewModel.errorMessage.isNotEmpty &&
                  viewModel.location == null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white.withOpacity(0.8),
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers(LocationViewModel viewModel) {
    final List<Marker> markers = [];

    if (viewModel.location != null) {
      markers.add(
        Marker(
          point: LatLng(
            viewModel.location!.latitude,
            viewModel.location!.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
        ),
      );
    }

    if (viewModel.searchedLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            viewModel.searchedLocation!.latitude,
            viewModel.searchedLocation!.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      );
    }

    return markers;
  }
}
