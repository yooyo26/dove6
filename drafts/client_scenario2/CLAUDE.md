# CLAUDE.md — dove6_client

## Mission
Build a complete Flutter passenger information display app targeting
Ubuntu Linux. The app polls a local Go server every 2 seconds and
displays the current train state on a full-screen dark UI.

## Folder structure — create every file listed here
```
lib/
  main.dart
  domain/
    train_state.dart
    display_data.dart
  data/
    data_service.dart
    fake_data_service.dart
    nvr_data_service.dart
  presentation/
    display_mapper.dart
    screens/
      _shared.dart
      idle_screen.dart
      route_selected_screen.dart
      station_screen.dart
      departing_screen.dart
      moving_speed_screen.dart
      moving_progress_screen.dart
      arriving_screen.dart
      arrived_message_screen.dart
      end_of_route_screen.dart
```

## domain/train_state.dart
```dart
// All possible train operational states
enum TrainState {
  idle,
  routeSelected,
  atStation,
  departing,
  moving,
  arriving,
  endOfRoute,
  warning,
  manual,
  recovery,
}
```

## domain/display_data.dart
```dart
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
```

## data/data_service.dart
```dart
// Abstract contract — swap fake/real by changing one line in main.dart
import '../domain/display_data.dart';

abstract class DataService {
  Stream<DisplayData> get stream;
  void start();
  void dispose();
}
```

## data/fake_data_service.dart
```dart
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
```

## data/nvr_data_service.dart
```dart
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
```

## main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/data_service.dart';
import 'data/fake_data_service.dart';
import 'data/nvr_data_service.dart';
import 'presentation/display_mapper.dart';

// ── Configuration ─────────────────────────────────────────────────────────────
// Set to true  → uses local fake simulation (no server needed)
// Set to false → polls the Go server at nvrIp
const bool useLocalSimulation = false;

// Your laptop IP address on WSL. Find it with: ip addr | grep "inet "
const String nvrIp = '127.0.0.1';
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const Dove6App());
}

class Dove6App extends StatefulWidget {
  const Dove6App({super.key});
  @override
  State<Dove6App> createState() => _Dove6AppState();
}

class _Dove6AppState extends State<Dove6App> {
  late final DataService _service;

  @override
  void initState() {
    super.initState();
    _service = useLocalSimulation
        ? FakeDataService()
        : NvrDataService(nvrIp: nvrIp);
    _service.start();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dove6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF141414),
          primary: Color(0xFF4FC3F7),
        ),
      ),
      home: DisplayMapper(dataStream: _service.stream),
    );
  }
}
```

## presentation/display_mapper.dart
StatefulWidget. Subscribes to Stream<DisplayData>.

Rules:
- On entering `moving`: start 5-second timer → show MovingSpeedScreen first, then MovingProgressScreen
- On `arriving → atStation` transition: show ArrivedMessageScreen for 3 seconds, then StationScreen
- Priority states checked first: warning, manual, recovery → show _PriorityScreen
- All screen swaps use AnimatedSwitcher with 600ms crossfade
- Key: ValueKey('${state}-${_showSpeedPhase}-${_showArrivedMessage}')
- Cancel all timers in dispose()
- _PriorityScreen is a private widget inside this file with icon, color, title, message

## presentation/screens/_shared.dart
Contains:
1. Colour constants:
```dart
const kBg         = Color(0xFF0A0A0A);
const kSurface    = Color(0xFF141414);
const kCard       = Color(0xFF1C1C1E);
const kBorder     = Color(0xFF2A2A2A);
const kPrimary    = Color(0xFFFFFFFF);
const kSecondary  = Color(0xFF888888);
const kAccent     = Color(0xFF4FC3F7);
const kAccentGold = Color(0xFFFFD54F);
const kDim        = Color(0xFF333333);
```

2. ScreenScaffold widget — dark Scaffold with horizontal padding 48, vertical 40

3. StationRow widget — takes label (String) and value (String) and valueColor.
   Shows label in uppercase kSecondary 13px letterSpacing 2,
   value below in valueColor 22px fontWeight w600

4. TrainIdChip widget — small rounded container with kDim background
   showing trainId in kSecondary 13px letterSpacing 2

5. KDivider widget — Divider with kBorder color thickness 1 height 32

6. RouteProgressPainter — CustomPainter:
   - Draws full-width horizontal line in kDim (the track)
   - Draws filled portion in kAccent from 0 to progress * width
   - For each station: draws dot — gold+ring for current, kAccent for passed, kDim for future
   - Draws station name label below each dot in matching color
   - shouldRepaint returns false when progress and currentStationIndex unchanged

## Screens — all StatelessWidget, all take DisplayData data, all import _shared.dart

### idle_screen.dart
- TrainIdChip top left
- Spacer
- Time HH:MM in kPrimary fontSize 80 fontWeight w200
- Date below in kSecondary fontSize 20 fontWeight w300
- Spacer
- "Welcome aboard" in kSecondary fontSize 22 fontWeight w300 letterSpacing 1
- "Office National des Chemins de Fer" in kDim fontSize 14 letterSpacing 2
- SizedBox height 40

### route_selected_screen.dart
- TrainIdChip
- Spacer
- "ROUTE" label kSecondary fontSize 13 letterSpacing 4
- Row: currentStation (large left) + arrow icon kAccent + destination (large right kAccent)
- Card (kCard background kBorder border radius 12) with all route stations listed in a Row
- Spacer
- "Preparing for departure" kSecondary fontSize 16
- SizedBox height 40

### station_screen.dart
- Row: TrainIdChip + "STOPPED" label kSecondary if not final station
- Spacer
- "CURRENT STATION" label kSecondary letterSpacing 3
- currentStation in kPrimary fontSize 48 fontWeight w700
- KDivider
- If not final: StationRow for next stop (kAccent) + StationRow for destination (kSecondary fontSize 18)
- If final: "Final destination reached" in kAccent fontSize 20
- Spacer
- RouteProgressPainter height 60
- SizedBox height 40

### departing_screen.dart
- TrainIdChip
- Spacer
- "Welcome aboard" kPrimary fontSize 42 fontWeight w300
- "Departing [currentStation]" kSecondary fontSize 20
- KDivider
- StationRow next stop kAccent
- StationRow destination kSecondary fontSize 18
- Spacer
- SizedBox height 40

### moving_speed_screen.dart
- Row: TrainIdChip + destination text kSecondary fontSize 14
- Spacer
- Center: speed number kAccentGold fontSize 130 fontWeight w200 letterSpacing -4 height 1
- "km/h" below in kSecondary fontSize 22 fontWeight w300 letterSpacing 4
- Spacer
- KDivider
- StationRow next stop kAccent
- SizedBox height 40

### moving_progress_screen.dart
- Row: TrainIdChip + speed small kSecondary "${speed} km/h" fontSize 16
- Spacer
- Center: progress percent kAccent fontSize 100 fontWeight w200 letterSpacing -2 height 1
- "of journey complete" kSecondary fontSize 16 letterSpacing 2
- SizedBox height 40
- RouteProgressPainter height 60
- KDivider
- StationRow next stop kAccent
- StationRow destination kSecondary fontSize 18
- SizedBox height 40

### arriving_screen.dart
- Row: TrainIdChip + speed kSecondary fontSize 14
- Spacer
- "Arriving at" kSecondary fontSize 22 fontWeight w300
- nextStation kAccent fontSize 52 fontWeight w700 letterSpacing -1
- SizedBox height 40
- LinearProgressIndicator value routeProgress minHeight 6 backgroundColor kDim valueColor kAccent
- SizedBox height 32
- RouteProgressPainter height 60
- Spacer
- StationRow destination kSecondary fontSize 18
- SizedBox height 40

### arrived_message_screen.dart
- Center the entire content vertically and horizontally
- Icon Icons.location_on_rounded kAccent size 56
- SizedBox height 24
- "Arrived at" kSecondary fontSize 22 fontWeight w300
- SizedBox height 8
- currentStation kPrimary fontSize 46 fontWeight w700 letterSpacing -1 textAlign center

### end_of_route_screen.dart
- TrainIdChip
- Spacer
- "Thank you for\ntravelling with us." kPrimary fontSize 46 fontWeight w300 height 1.2
- SizedBox height 24
- "Terminal — [destination]" kAccent fontSize 22 fontWeight w500
- SizedBox height 12
- "End of route" kSecondary fontSize 16 letterSpacing 2
- Spacer
- RouteProgressPainter height 60 progress 1.0 currentStationIndex last index
- SizedBox height 40

## Key rules — never break
1. No screen imports anything except DisplayData and _shared.dart
2. All routing logic only in display_mapper.dart
3. All colours and shared widgets only in _shared.dart
4. DataService is the only contract between data and UI
5. main.dart is the only place where service is instantiated
6. Swapping fake to real = change useLocalSimulation bool only
7. Every file has a one-line comment at top explaining its role
8. No packages except http
9. All screens are StatelessWidget
10. All timer logic stays in DisplayMapper only