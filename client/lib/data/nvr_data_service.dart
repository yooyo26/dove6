// Connects to NVR server and polls all endpoints.
// baseUrl examples:
//   fake dev server  → 'http://127.0.0.1:8080'
//   real NVR (R6S)   → 'http://192.168.1.50:3002/v0'
// Only this file changes when switching from fake to real NVR.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/display_data.dart';
import '../domain/station.dart';
import '../domain/train_state.dart';
import 'data_service.dart';

class NvrDataService implements DataService {
  final String baseUrl;
  final String trainId;

  final _controller = StreamController<DisplayData>.broadcast();

  @override
  Stream<DisplayData> get stream => _controller.stream;

  Timer? _pollTimer;
  Timer? _healthTimer;

  String?       _lastRouteId;
  List<Station> _stations         = [];
  bool          _isArabic         = false;
  bool          _isInReverse      = false;
  double        _speed            = 0;
  double        _progress         = 0;
  TrainState    _currentState     = TrainState.idle;
  int           _currentStationIdx = 0;
  int           _passengerCount   = 0;

  NvrDataService({required this.baseUrl, required this.trainId});

  // ── Startup ──────────────────────────────────────────────────────────────

  @override
  void start() => _checkHealth();

  Future<void> _checkHealth() async {
    final res = await _get('/health');
    if (res != null && res['status'] == 'ok') {
      _startPolling();
    } else {
      _controller.add(DisplayData.initial(trainId).copyWith(
        state: TrainState.recovery,
      ));
      _healthTimer = Timer(const Duration(seconds: 3), _checkHealth);
    }
  }

  void _startPolling() {
    _fetchAndEmit();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchAndEmit());
  }

  // ── Poll cycle ───────────────────────────────────────────────────────────
  // 5 endpoints fired in parallel every second, merged into one DisplayData.

  Future<void> _fetchAndEmit() async {
    try {
      final results = await Future.wait([
        _get('/running-state'),       // 0
        _get('/audio-state'),         // 1
        _get('/data/speed'),          // 2
        _get('/data/distance-ratio'), // 3
        _get('/data/current-route'),  // 4
        _get('/sensors/human-counter'), // 5 — non-critical
      ]);

      final stateRes    = results[0];
      final audioRes    = results[1];
      final speedRes    = results[2];
      final distanceRes = results[3];
      final routeRes    = results[4];
      final counterRes  = results[5];

      // Critical endpoints — emit recovery if any fail
      if (stateRes == null || speedRes == null || distanceRes == null) {
        _emitRecovery();
        return;
      }

      _currentState = _parseState(stateRes['current_state'] as String);
      _speed        = (speedRes['speed'] as num).toDouble();
      _progress     = ((distanceRes['ratio'] as num).toDouble() / 100.0)
          .clamp(0.0, 1.0);

      // Audio: polled every tick, applied by DisplayMapper only on state transitions
      if (audioRes != null) {
        _isArabic = _parseAudio(audioRes['audio_action'] as String);
      }

      // Passenger count: non-critical — keep last known on failure
      if (counterRes != null) {
        _passengerCount = (counterRes['count'] as num? ?? 0).toInt();
      }

      // Route: re-fetch stations only when route_id changes
      if (routeRes != null) {
        final routeId = routeRes['route_id'] as String;
        _isInReverse = routeRes['is_in_reverse'] as bool? ?? false;

        // IMPORTANT: start_station_index is the CURRENT station index,
        // not the departure station — the name from the server is misleading.
        _currentStationIdx = (routeRes['start_station_index'] as int? ?? 0)
            .clamp(0, _stations.isEmpty ? 0 : _stations.length - 1);

        if (routeId != _lastRouteId) {
          await _fetchRouteData(routeId);
          _lastRouteId = routeId;
        }
      }

      _emitData();
    } catch (_) {
      _emitRecovery();
    }
  }

  // ── Station fetch (once per route_id) ───────────────────────────────────

  Future<void> _fetchRouteData(String routeId) async {
    try {
      final idsRes = await _get('/data/stations-in-route/$routeId');
      if (idsRes == null) return;

      final ids = List<String>.from(idsRes['_list'] as List);
      final List<Station> loaded = [];

      for (int i = 0; i < ids.length; i++) {
        final info = await _get('/data/station-info/${ids[i]}');
        if (info != null) {
          final nameFr = info['display_name_fr'] as String?
              ?? info['display_name'] as String? ?? ids[i];
          // Fall back to French if Arabic is absent in the response
          final nameAr = info['display_name_ar'] as String? ?? nameFr;
          loaded.add(Station(index: i, id: ids[i], nameFr: nameFr, nameAr: nameAr));
        }
      }

      _stations = loaded;
    } catch (_) {
      // Keep existing station data on error — do not clear
    }
  }

  // ── Emission ─────────────────────────────────────────────────────────────

  void _emitData() {
    // Destination is last station normally, first station if running in reverse
    final Station? dest = _stations.isEmpty
        ? null
        : (_isInReverse ? _stations.first : _stations.last);

    _controller.add(DisplayData(
      state:             _currentState,
      speedKmh:          _speed,
      routeProgress:     _progress,
      currentStationIdx: _currentStationIdx,
      isInReverse:       _isInReverse,
      routeId:           _lastRouteId ?? '',
      stations:          _stations,
      destinationFr:     dest?.nameFr ?? '',
      destinationAr:     dest?.nameAr ?? '',
      passengerCount:    _passengerCount,
      isArabic:          _isArabic,
      trainId:           trainId,
    ));
  }

  void _emitRecovery() {
    _controller.add(DisplayData.initial(trainId).copyWith(
      state: TrainState.recovery,
    ));
  }

  // ── HTTP helper ──────────────────────────────────────────────────────────
  // Lists are wrapped as {'_list': [...]} to keep the return type uniform.

  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is List) return {'_list': decoded};
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── State/audio parsers ──────────────────────────────────────────────────

  TrainState _parseState(String s) {
    // Exact-match the one case-inconsistent string first
    if (s == 'Operating_State_ManualHandling') return TrainState.manual;
    switch (s) {
      case 'operating_state_idle':          return TrainState.idle;
      case 'operating_state_routeselected': return TrainState.routeSelected;
      case 'operating_state_atstation':     return TrainState.atStation;
      case 'operating_state_departing':     return TrainState.departing;
      case 'operating_state_moving':        return TrainState.moving;
      case 'operating_state_coasting':      return TrainState.moving; // same visual
      case 'operating_state_arriving':      return TrainState.arriving;
      case 'operating_state_endofroute':    return TrainState.endOfRoute;
      case 'operating_state_recovery':      return TrainState.recovery;
      case 'operating_state_warning':       return TrainState.warning;
      default:                              return TrainState.idle;
    }
  }

  bool _parseAudio(String action) => action == 'playing_arabic_audio';

  // ── Cleanup ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _pollTimer?.cancel();
    _healthTimer?.cancel();
    _controller.close();
  }
}
