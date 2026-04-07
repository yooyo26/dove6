// Core data snapshot — everything any screen needs
import 'train_state.dart';

class DisplayData {
  final TrainState state;
  final String trainId;
  final String currentStation;
  final String nextStation;
  final String destination;
  final double speedKmh;
  final double routeProgress; // 0.0 to 1.0
  final List<String> routeStations;
  final DateTime timestamp;

  const DisplayData({
    required this.state,
    required this.trainId,
    required this.currentStation,
    required this.nextStation,
    required this.destination,
    required this.speedKmh,
    required this.routeProgress,
    required this.routeStations,
    required this.timestamp,
  });

  DisplayData copyWith({
    TrainState? state,
    String? trainId,
    String? currentStation,
    String? nextStation,
    String? destination,
    double? speedKmh,
    double? routeProgress,
    List<String>? routeStations,
    DateTime? timestamp,
  }) {
    return DisplayData(
      state: state ?? this.state,
      trainId: trainId ?? this.trainId,
      currentStation: currentStation ?? this.currentStation,
      nextStation: nextStation ?? this.nextStation,
      destination: destination ?? this.destination,
      speedKmh: speedKmh ?? this.speedKmh,
      routeProgress: routeProgress ?? this.routeProgress,
      routeStations: routeStations ?? this.routeStations,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static DisplayData initial() => DisplayData(
    state: TrainState.idle,
    trainId: 'DOVE-6',
    currentStation: 'Casa Voyageurs',
    nextStation: 'Rabat Agdal',
    destination: 'Tanger Ville',
    speedKmh: 0,
    routeProgress: 0,
    routeStations: const [
      'Casa Voyageurs',
      'Rabat Agdal',
      'Kenitra',
      'Tanger Ville',
    ],
    timestamp: DateTime.now(),
  );
}
