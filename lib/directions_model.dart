import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    final routes = map['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception("No routes found in directions response.");
    }

    final data = Map<String, dynamic>.from(routes[0]);

    // Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest']; // fixed: was "southeast"

    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // Distance & Duration
    String distance = '';
    String duration = '';
    final legs = data['legs'] as List?;
    if (legs != null && legs.isNotEmpty) {
      final leg = legs[0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    // Polyline points
    final points = PolylinePoints().decodePolyline(data['overview_polyline']['points']);

    return Directions(
      bounds: bounds,
      polylinePoints: points,
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
