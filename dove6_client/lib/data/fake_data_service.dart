// Local simulation — no network needed. Used for offline development.
import 'dart:async';
import '../domain/display_data.dart';
import '../domain/train_state.dart';
import 'data_service.dart';

class FakeDataService implements DataService {
  final _controller = StreamController<DisplayData>.broadcast();

  @override
  Stream<DisplayData> get stream => _controller.stream;

  static const List<String> _stations = [
    'Casa Voyageurs', 'Rabat Agdal', 'Kenitra', 'Tanger Ville',
  ];

  static const List<Map<String, dynamic>> _script = [
    {'state': TrainState.idle,          'cur': 0, 'nxt': 1, 'spd': 0.0,   'prg': 0.00, 'dur': 4},
    {'state': TrainState.routeSelected, 'cur': 0, 'nxt': 1, 'spd': 0.0,   'prg': 0.00, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 0, 'nxt': 1, 'spd': 0.0,   'prg': 0.00, 'dur': 4},
    {'state': TrainState.departing,     'cur': 0, 'nxt': 1, 'spd': 20.0,  'prg': 0.02, 'dur': 3},
    {'state': TrainState.moving,        'cur': 0, 'nxt': 1, 'spd': 120.0, 'prg': 0.15, 'dur': 4},
    {'state': TrainState.moving,        'cur': 0, 'nxt': 1, 'spd': 175.0, 'prg': 0.28, 'dur': 4},
    {'state': TrainState.arriving,      'cur': 0, 'nxt': 1, 'spd': 60.0,  'prg': 0.32, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 1, 'nxt': 2, 'spd': 0.0,   'prg': 0.33, 'dur': 4},
    {'state': TrainState.departing,     'cur': 1, 'nxt': 2, 'spd': 25.0,  'prg': 0.35, 'dur': 3},
    {'state': TrainState.moving,        'cur': 1, 'nxt': 2, 'spd': 150.0, 'prg': 0.50, 'dur': 4},
    {'state': TrainState.moving,        'cur': 1, 'nxt': 2, 'spd': 185.0, 'prg': 0.62, 'dur': 4},
    {'state': TrainState.arriving,      'cur': 1, 'nxt': 2, 'spd': 55.0,  'prg': 0.65, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 2, 'nxt': 3, 'spd': 0.0,   'prg': 0.66, 'dur': 4},
    {'state': TrainState.departing,     'cur': 2, 'nxt': 3, 'spd': 30.0,  'prg': 0.68, 'dur': 3},
    {'state': TrainState.moving,        'cur': 2, 'nxt': 3, 'spd': 160.0, 'prg': 0.80, 'dur': 4},
    {'state': TrainState.moving,        'cur': 2, 'nxt': 3, 'spd': 195.0, 'prg': 0.92, 'dur': 4},
    {'state': TrainState.arriving,      'cur': 2, 'nxt': 3, 'spd': 40.0,  'prg': 0.96, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 3, 'nxt': 3, 'spd': 0.0,   'prg': 1.00, 'dur': 3},
    {'state': TrainState.endOfRoute,    'cur': 3, 'nxt': 3, 'spd': 0.0,   'prg': 1.00, 'dur': 5},
  ];

  int _step = 0;
  Timer? _timer;

  @override
  void start() {
    _emit(_step);
    _scheduleNext();
  }

  void _scheduleNext() {
    final dur = _script[_step]['dur'] as int;
    _timer = Timer(Duration(seconds: dur), () {
      _step = (_step + 1) % _script.length;
      _emit(_step);
      _scheduleNext();
    });
  }

  void _emit(int index) {
    final s = _script[index];
    _controller.add(DisplayData(
      state: s['state'] as TrainState,
      trainId: 'DOVE-6',
      currentStation: _stations[s['cur'] as int],
      nextStation: _stations[s['nxt'] as int],
      destination: _stations.last,
      speedKmh: s['spd'] as double,
      routeProgress: s['prg'] as double,
      routeStations: _stations,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
