// Connects to NVR server.
// baseUrl examples:
//   fake dev server  → 'http://127.0.0.1:8080'
//   real NVR (R6S)   → 'http://192.168.1.50:3002/v0'
// FUTURE: Replace HTTP polling with WebSocket for lower latency.
// Only this file changes when switching from fake to real NVR.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/display_data.dart';
import '../domain/train_state.dart';
import 'data_service.dart';

class NvrDataService implements DataService {
  final String baseUrl;
  final String trainId;
  final _controller = StreamController<DisplayData>.broadcast();

  @override
  Stream<DisplayData> get stream => _controller.stream;

  Timer? _pollTimer;
  TrainState? _lastState;
  String? _lastRouteId;
  List<String> _stationsFr     = [];
  List<String> _stationsAr     = [];
  bool _isArabic                = false;
  double _speed                 = 0;
  double _progress              = 0;
  TrainState _currentState      = TrainState.idle;
  int _currentStationIndex      = 0;

  NvrDataService({required this.baseUrl, required this.trainId});

  String get _base => baseUrl;

  @override
  void start() {
    _fetchAndEmit();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _fetchAndEmit(),
    );
  }

  Future<void> _fetchAndEmit() async {
    try {
      // Always poll state, speed, distance in parallel
      final results = await Future.wait([
        _get('/running-state'),
        _get('/data/speed'),
        _get('/data/distance-ratio'),
      ]);

      final stateRes    = results[0];
      final speedRes    = results[1];
      final distanceRes = results[2];

      if (stateRes == null || speedRes == null || distanceRes == null) {
        _emitRecovery();
        return;
      }

      final newState = _parseState(stateRes['current_state'] as String);
      _speed    = (speedRes['speed'] as num).toDouble();
      _progress = ((distanceRes['ratio'] as num).toDouble() / 100.0)
          .clamp(0.0, 1.0);

      // On state change: fetch audio immediately
      if (newState != _lastState) {
        final audioRes = await _get('/audio-state');
        if (audioRes != null) {
          _isArabic = _parseAudio(audioRes['audio_action'] as String);
        }
        _lastState = newState;
      }

      _currentState = newState;

      // Fetch route data (only re-fetches stations when route_id changes)
      final routeRes = await _get('/data/current-route');
      if (routeRes != null) {
        final routeId = routeRes['route_id'] as String;
        if (routeId != _lastRouteId) {
          await _fetchRouteData(routeId);
          _lastRouteId = routeId;
        }
        _currentStationIndex =
            (routeRes['start_station_index'] as int)
                .clamp(0, _stationsFr.isEmpty ? 0 : _stationsFr.length - 1);
      }

      _emitData();
    } catch (_) {
      _emitRecovery();
    }
  }

  Future<void> _fetchRouteData(String routeId) async {
    try {
      final idsRes = await _get('/data/stations-in-route/$routeId');
      if (idsRes == null) return;

      final ids = List<String>.from(idsRes['_list'] as List);
      _stationsFr = [];
      _stationsAr = [];

      for (final id in ids) {
        final info = await _get('/data/station-info/$id');
        if (info != null) {
          _stationsFr.add(
              info['display_name_fr'] as String? ??
              info['display_name'] as String? ?? id);
          // Arabic not yet in API — fall back to FR until colleague adds it
          // TODO: use display_name_ar when colleague adds Arabic support
          _stationsAr.add(
              info['display_name_ar'] as String? ??
              info['display_name_fr'] as String? ??
              info['display_name'] as String? ?? id);
        }
      }
    } catch (_) {
      // Keep existing station data on error
    }
  }

  // Returns parsed JSON. Lists are wrapped as {'_list': [...]} to
  // keep the return type uniform across all endpoints.
  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$_base$path'))
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

  void _emitData() {
    if (_stationsFr.isEmpty) {
      // Route not loaded yet — emit current state with empty route
      _controller.add(DisplayData.initial().copyWith(
        state: _currentState,
        speedKmh: _speed,
        routeProgress: _progress,
        timestamp: DateTime.now(),
      ));
      return;
    }

    final cur = _currentStationIndex.clamp(0, _stationsFr.length - 1);
    final nxt = (cur + 1).clamp(0, _stationsFr.length - 1);

    _controller.add(DisplayData(
      state:            _currentState,
      trainId:          trainId,
      currentStation:   _stationsFr[cur],
      currentStationFr: _stationsFr[cur],
      currentStationAr: _stationsAr[cur],
      nextStation:      _stationsFr[nxt],
      nextStationFr:    _stationsFr[nxt],
      nextStationAr:    _stationsAr[nxt],
      destination:      _stationsFr.last,
      destinationFr:    _stationsFr.last,
      destinationAr:    _stationsAr.last,
      speedKmh:         _speed,
      routeProgress:    _progress,
      routeStations:    _stationsFr,
      routeStationsFr:  _stationsFr,
      routeStationsAr:  _stationsAr,
      messageEn:        '',
      messageFr:        '',
      messageAr:        '',
      activeAudioLang:  _isArabic ? 'ar' : 'fr',
      audioFile:        '',
      passengerCount:   0,
      timestamp:        DateTime.now(),
    ));
  }

  void _emitRecovery() {
    _controller.add(DisplayData.initial().copyWith(
      state:     TrainState.recovery,
      timestamp: DateTime.now(),
    ));
  }

  TrainState _parseState(String s) {
    switch (s.toLowerCase()) {
      case 'operating_state_idle':
        return TrainState.idle;
      case 'operating_state_routeselected':
        return TrainState.routeSelected;
      case 'operating_state_atstation':
        return TrainState.atStation;
      case 'operating_state_departing':
        return TrainState.departing;
      case 'operating_state_moving':
        return TrainState.moving;
      case 'operating_state_coasting':
        return TrainState.coasting; // mapped to moving in display_mapper
      case 'operating_state_arriving':
        return TrainState.arriving;
      case 'operating_state_endofroute':
        return TrainState.endOfRoute;
      case 'operating_state_recovery':
        return TrainState.recovery;
      case 'operating_state_warning':
        return TrainState.warning;
      case 'operating_state_manualhandling':
        return TrainState.manual;
      default:
        return TrainState.idle;
    }
  }

  bool _parseAudio(String action) {
    // Returns true only when Arabic audio is explicitly active.
    // NOTE: playing_arabic_audio not yet confirmed in API contract.
    // TODO: verify exact string with colleague.
    return action == 'playing_arabic_audio';
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.close();
  }
}
