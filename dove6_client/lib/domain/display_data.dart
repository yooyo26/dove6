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
  final String currentStationFr;
  final String currentStationAr;
  final String nextStationFr;
  final String nextStationAr;
  final String destinationFr;
  final String destinationAr;
  final String activeAudioLang;

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
    required this.currentStationFr,
    required this.currentStationAr,
    required this.nextStationFr,
    required this.nextStationAr,
    required this.destinationFr,
    required this.destinationAr,
    required this.activeAudioLang,
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
    String? currentStationFr,
    String? currentStationAr,
    String? nextStationFr,
    String? nextStationAr,
    String? destinationFr,
    String? destinationAr,
    String? activeAudioLang,
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
      currentStationFr: currentStationFr ?? this.currentStationFr,
      currentStationAr: currentStationAr ?? this.currentStationAr,
      nextStationFr: nextStationFr ?? this.nextStationFr,
      nextStationAr: nextStationAr ?? this.nextStationAr,
      destinationFr: destinationFr ?? this.destinationFr,
      destinationAr: destinationAr ?? this.destinationAr,
      activeAudioLang: activeAudioLang ?? this.activeAudioLang,
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
    currentStationFr: 'Casa Voyageurs',
    currentStationAr: 'Casa Voyageurs',
    nextStationFr: 'Rabat Agdal',
    nextStationAr: 'Rabat Agdal',
    destinationFr: 'Tanger Ville',
    destinationAr: 'Tanger Ville',
    activeAudioLang: '',
  );
}
