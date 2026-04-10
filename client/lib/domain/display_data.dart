// Core data snapshot — exactly what the server sends, nothing more
import 'train_state.dart';
import 'station.dart';

class DisplayData {
  // ── Server-provided fields ────────────────────────────────────────────────
  final TrainState    state;
  final double        speedKmh;          // from /data/speed
  final double        routeProgress;     // ratio / 100.0 from /data/distance-ratio
  final int           currentStationIdx; // start_station_index from /data/current-route
  final bool          isInReverse;       // from /data/current-route
  final String        routeId;           // from /data/current-route
  final List<Station> stations;          // resolved from /data/stations-in-route + /data/station-info
  final String        destinationFr;     // last station nameFr (or first if isInReverse)
  final String        destinationAr;     // last station nameAr (or first if isInReverse)
  final int           passengerCount;    // from /sensors/human-counter
  // isArabic: raw from /audio-state every poll.
  // DisplayMapper applies it ONLY on state transitions — never mid-screen.
  final bool          isArabic;

  // ── Deployment constant — needed by all screen headers ───────────────────
  final String        trainId;

  const DisplayData({
    required this.state,
    required this.speedKmh,
    required this.routeProgress,
    required this.currentStationIdx,
    required this.isInReverse,
    required this.routeId,
    required this.stations,
    required this.destinationFr,
    required this.destinationAr,
    required this.passengerCount,
    required this.isArabic,
    required this.trainId,
  });

  // ── Computed helpers for screens ─────────────────────────────────────────
  Station? get currentStation {
    if (stations.isEmpty) return null;
    return stations[currentStationIdx.clamp(0, stations.length - 1)];
  }

  Station? get nextStation {
    if (stations.isEmpty) return null;
    final nxt = currentStationIdx + 1;
    return stations[nxt.clamp(0, stations.length - 1)];
  }

  // ── Initial placeholder — used before first server response ──────────────
  static DisplayData initial([String trainId = '']) => DisplayData(
    state:             TrainState.idle,
    speedKmh:          0,
    routeProgress:     0,
    currentStationIdx: 0,
    isInReverse:       false,
    routeId:           '',
    stations:          const [],
    destinationFr:     '',
    destinationAr:     '',
    passengerCount:    0,
    isArabic:          false,
    trainId:           trainId,
  );

  DisplayData copyWith({
    TrainState?    state,
    double?        speedKmh,
    double?        routeProgress,
    int?           currentStationIdx,
    bool?          isInReverse,
    String?        routeId,
    List<Station>? stations,
    String?        destinationFr,
    String?        destinationAr,
    int?           passengerCount,
    bool?          isArabic,
    String?        trainId,
  }) => DisplayData(
    state:             state             ?? this.state,
    speedKmh:          speedKmh          ?? this.speedKmh,
    routeProgress:     routeProgress     ?? this.routeProgress,
    currentStationIdx: currentStationIdx ?? this.currentStationIdx,
    isInReverse:       isInReverse       ?? this.isInReverse,
    routeId:           routeId           ?? this.routeId,
    stations:          stations          ?? this.stations,
    destinationFr:     destinationFr     ?? this.destinationFr,
    destinationAr:     destinationAr     ?? this.destinationAr,
    passengerCount:    passengerCount    ?? this.passengerCount,
    isArabic:          isArabic          ?? this.isArabic,
    trainId:           trainId           ?? this.trainId,
  );
}
