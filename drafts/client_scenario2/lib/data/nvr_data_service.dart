// Polls the Go server every 2 seconds.
// FUTURE: replace HTTP polling with WebSocket — only this file changes.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/display_data.dart';
import '../domain/train_state.dart';
import 'data_service.dart';

class NvrDataService implements DataService {
  final String nvrIp;
  final _controller = StreamController<DisplayData>.broadcast();

  @override
  Stream<DisplayData> get stream => _controller.stream;

  Timer? _timer;

  NvrDataService({required this.nvrIp});

  @override
  void start() {
    _fetchAndEmit();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchAndEmit());
  }

  Future<void> _fetchAndEmit() async {
    try {
      final response = await http
          .get(Uri.parse('http://$nvrIp:8080/state'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _controller.add(_parse(json));
      }
    } catch (_) {
      _controller.add(DisplayData.initial().copyWith(
        state: TrainState.recovery,
        timestamp: DateTime.now(),
      ));
    }
  }

  DisplayData _parse(Map<String, dynamic> j) {
    return DisplayData(
      state: _toState(j['state'] as String),
      trainId: j['train_id'] as String? ?? 'DOVE-6',
      currentStation: j['current_station'] as String,
      nextStation: j['next_station'] as String,
      destination: j['destination'] as String,
      speedKmh: (j['speed_kmh'] as num).toDouble(),
      routeProgress: (j['route_progress'] as num).toDouble(),
      routeStations: List<String>.from(j['route_stations'] as List),
      timestamp: DateTime.now(),
      currentStationFr:  j['current_station_fr']  as String? ?? '',
      currentStationAr:  j['current_station_ar']  as String? ?? '',
      nextStationFr:     j['next_station_fr']      as String? ?? '',
      nextStationAr:     j['next_station_ar']      as String? ?? '',
      destinationFr:     j['destination_fr']       as String? ?? '',
      destinationAr:     j['destination_ar']       as String? ?? '',
      routeStationsFr:   j['route_stations_fr'] != null
          ? List<String>.from(j['route_stations_fr'] as List)
          : [],
      routeStationsAr:   j['route_stations_ar'] != null
          ? List<String>.from(j['route_stations_ar'] as List)
          : [],
      messageEn:         j['message_en']           as String? ?? '',
      messageFr:         j['message_fr']           as String? ?? '',
      messageAr:         j['message_ar']           as String? ?? '',
      activeAudioLang:   j['active_audio_lang']    as String? ?? '',
      audioFile:         j['audio_file']           as String? ?? '',
    );
  }

  TrainState _toState(String s) {
    switch (s) {
      case 'IDLE':           return TrainState.idle;
      case 'ROUTE_SELECTED': return TrainState.routeSelected;
      case 'AT_STATION':     return TrainState.atStation;
      case 'DEPARTING':      return TrainState.departing;
      case 'MOVING':         return TrainState.moving;
      case 'ARRIVING':       return TrainState.arriving;
      case 'END_OF_ROUTE':   return TrainState.endOfRoute;
      case 'WARNING':        return TrainState.warning;
      case 'MANUAL':         return TrainState.manual;
      case 'RECOVERY':       return TrainState.recovery;
      default:               return TrainState.idle;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
