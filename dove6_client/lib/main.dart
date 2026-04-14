// Entry point — instantiates the data service and launches the app
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/data_service.dart';
import 'data/fake_data_service.dart';
import 'data/nvr_data_service.dart';
import 'presentation/display_mapper.dart';

// ── Configuration ─────────────────────────────────────────────────────────────
// Set to true  → uses local fake simulation (no server needed)
// Set to false → polls the Go server at _apiBaseUrl
const bool useLocalSimulation = false;

// Base URL of the Go NVR server.
// Override at build time:  --dart-define=API_BASE_URL=http://192.168.137.1:8080
// Board connects to the Windows Ethernet IP (192.168.137.1), NOT to localhost
// or the WSL-internal IP, because the server runs inside WSL on the dev machine.
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8080',
);
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
        : NvrDataService(baseUrl: _apiBaseUrl);
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
