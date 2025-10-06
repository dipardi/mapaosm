import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapaosm/models/location_model.dart';
import 'package:mapaosm/views/location_service.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;

  LocationModel? _location;
  LocationModel? _searchedLocation;
  String _errorMessage = '';
  bool _isLoading = true;

  LocationModel? get location => _location;
  LocationModel? get searchedLocation => _searchedLocation;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  LocationViewModel() {
    startLocationUpdates();
  }

  Future<void> startLocationUpdates() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final hasPermission = await _locationService.handleLocationPermission();
    if (!hasPermission) {
      _errorMessage =
          'Permissão de localização negada. Habilite nas configurações do dispositivo.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _positionSubscription = _locationService.getPositionStream().listen(
      (Position position) {
        _location = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        if (_isLoading) {
          _isLoading = false;
        }
        _errorMessage = '';
        notifyListeners();
      },
      onError: (e) {
        _errorMessage =
            'Não foi possível obter a localização. Verifique o GPS.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> searchLocation(String address) async {
    geocoding.Location? location = await _locationService
        .getCoordinatesFromAddress(address);
    if (location != null) {
      _searchedLocation = LocationModel(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _errorMessage = '';
    } else {
      _searchedLocation = null;
      _errorMessage = "Endereço não encontrado.";
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
