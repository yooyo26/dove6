import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'data/data_service.dart';
import 'data/fake_data_service.dart';
import 'data/nvr_data_service.dart';
import 'presentation/display_mapper.dart';

const bool useLocalSimulation = false;
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.137.1:8080',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    fullScreen: true,
    backgroundColor: Color(0xFFE8E4DF),
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setFullScreen(true);
    },
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

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
