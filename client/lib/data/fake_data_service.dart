// Local simulation — no network needed. Used for offline development.
import 'dart:async';
import '../domain/display_data.dart';
import '../domain/station.dart';
import '../domain/train_state.dart';
import 'data_service.dart';

class FakeDataService implements DataService {
  final _controller = StreamController<DisplayData>.broadcast();

  @override
  Stream<DisplayData> get stream => _controller.stream;

  static const List<Station> _stations = [
    Station(index: 0, id: 'st-0', nameFr: 'Casa Voyageurs',           nameAr: 'الدار البيضاء المسافرين'),
    Station(index: 1, id: 'st-1', nameFr: 'Rabat Agdal',              nameAr: 'الرباط أكدال'),
    Station(index: 2, id: 'st-2', nameFr: 'Kénitra',                  nameAr: 'القنيطرة'),
    Station(index: 3, id: 'st-3', nameFr: 'Tanger Ville',             nameAr: 'طنجة المدينة'),
  ];

  static const List<Map<String, dynamic>> _script = [
    {'state': TrainState.idle,          'cur': 0, 'spd': 0.0,   'prg': 0.00, 'dur': 4},
    {'state': TrainState.routeSelected, 'cur': 0, 'spd': 0.0,   'prg': 0.00, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 0, 'spd': 0.0,   'prg': 0.00, 'dur': 4},
    {'state': TrainState.departing,     'cur': 0, 'spd': 20.0,  'prg': 0.02, 'dur': 3},
    {'state': TrainState.moving,        'cur': 0, 'spd': 120.0, 'prg': 0.15, 'dur': 4},
    {'state': TrainState.moving,        'cur': 0, 'spd': 175.0, 'prg': 0.28, 'dur': 4},
    {'state': TrainState.arriving,      'cur': 0, 'spd': 60.0,  'prg': 0.32, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 1, 'spd': 0.0,   'prg': 0.33, 'dur': 4},
    {'state': TrainState.departing,     'cur': 1, 'spd': 25.0,  'prg': 0.35, 'dur': 3},
    {'state': TrainState.moving,        'cur': 1, 'spd': 150.0, 'prg': 0.50, 'dur': 4},
    {'state': TrainState.moving,        'cur': 1, 'spd': 185.0, 'prg': 0.62, 'dur': 4},
    {'state': TrainState.arriving,      'cur': 1, 'spd': 55.0,  'prg': 0.65, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 2, 'spd': 0.0,   'prg': 0.66, 'dur': 4},
    {'state': TrainState.departing,     'cur': 2, 'spd': 30.0,  'prg': 0.68, 'dur': 3},
    {'state': TrainState.moving,        'cur': 2, 'spd': 160.0, 'prg': 0.80, 'dur': 4},
    {'state': TrainState.moving,        'cur': 2, 'spd': 195.0, 'prg': 0.92, 'dur': 4},
    {'state': TrainState.arriving,      'cur': 2, 'spd': 40.0,  'prg': 0.96, 'dur': 3},
    {'state': TrainState.atStation,     'cur': 3, 'spd': 0.0,   'prg': 1.00, 'dur': 3},
    {'state': TrainState.endOfRoute,    'cur': 3, 'spd': 0.0,   'prg': 1.00, 'dur': 5},
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
    final s   = _script[index];
    final cur = s['cur'] as int;
    final dest = _stations.last;

    _controller.add(DisplayData(
      state:             s['state'] as TrainState,
      speedKmh:          s['spd'] as double,
      routeProgress:     s['prg'] as double,
      currentStationIdx: cur,
      isInReverse:       false,
      routeId:           'fake-route',
      stations:          _stations,
      destinationFr:     dest.nameFr,
      destinationAr:     dest.nameAr,
      passengerCount:    0,
      isArabic:          false,
      trainId:           'DOVE-6',
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
