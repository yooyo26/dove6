// Entry point — instantiates the data service and launches the app
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/data_service.dart';
import 'data/fake_data_service.dart';
import 'data/nvr_data_service.dart';
import 'presentation/display_mapper.dart';

// ── Configuration ─────────────────────────────────────────────────────────────
// Set to true  → uses local Dart fake simulation (no server needed)
// Set to false → polls the NVR server defined by nvrBaseUrl below
const bool useLocalSimulation = false;

// Base URL of the NVR server.
//   dove6_server (dev)  → 'http://127.0.0.1:8080'
//   real NVR (R6S)      → 'http://192.168.1.50:3002/v0'
const String nvrBaseUrl = 'http://127.0.0.1:8080';

// Train identifier sent by the NVR — shown in every screen header chip.
// Change this per deployment to match the physical train unit.
const String trainId = 'DOVE-6';
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
        : NvrDataService(baseUrl: nvrBaseUrl, trainId: trainId);
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE8E4DF),
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFD6CFC7),
          primary: Color(0xFFE8650A),
        ),
      ),
      home: DisplayMapper(dataStream: _service.stream),
    );
  }
}
