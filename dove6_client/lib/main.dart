// Entry point — instantiates the data service and launches the app
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
