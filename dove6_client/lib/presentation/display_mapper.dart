// Routes DisplayData stream to the correct screen with transition logic
import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/display_data.dart';
import '../domain/train_state.dart';
import 'screens/_shared.dart';
import 'screens/idle_screen.dart';
import 'screens/route_selected_screen.dart';
import 'screens/station_screen.dart';
import 'screens/departing_screen.dart';
import 'screens/moving_speed_screen.dart';
import 'screens/moving_progress_screen.dart';
import 'screens/arriving_screen.dart';
import 'screens/arrived_message_screen.dart';
import 'screens/end_of_route_screen.dart';

class DisplayMapper extends StatefulWidget {
  final Stream<DisplayData> dataStream;
  const DisplayMapper({super.key, required this.dataStream});

  @override
  State<DisplayMapper> createState() => _DisplayMapperState();
}

class _DisplayMapperState extends State<DisplayMapper> {
  DisplayData _data = DisplayData.initial();
  StreamSubscription<DisplayData>? _sub;

  bool _showSpeedPhase = true;
  bool _showArrivedMessage = false;

  Timer? _speedTimer;
  Timer? _arrivedTimer;

  TrainState? _prevState;

  @override
  void initState() {
    super.initState();
    _sub = widget.dataStream.listen(_onData);
  }

  void _onData(DisplayData data) {
    final TrainState newState = data.state;
    final TrainState? oldState = _prevState;

    setState(() {
      _data = data;

      // entering moving: show speed phase for 5 seconds then progress
      if (newState == TrainState.moving && oldState != TrainState.moving) {
        _showSpeedPhase = true;
        _speedTimer?.cancel();
        _speedTimer = Timer(const Duration(seconds: 5), () {
          setState(() => _showSpeedPhase = false);
        });
      }

      // arriving → atStation transition: show arrived message for 3 seconds
      if (newState == TrainState.atStation && oldState == TrainState.arriving) {
        _showArrivedMessage = true;
        _arrivedTimer?.cancel();
        _arrivedTimer = Timer(const Duration(seconds: 3), () {
          setState(() => _showArrivedMessage = false);
        });
      }

      _prevState = newState;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _speedTimer?.cancel();
    _arrivedTimer?.cancel();
    super.dispose();
  }

  Widget _buildScreen() {
    final state = _data.state;

    // Priority states
    if (state == TrainState.warning) {
      return _PriorityScreen(
        key: const ValueKey('warning'),
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFE8650A),
        title: 'WARNING',
        message: 'Operational alert — stand by',
      );
    }
    if (state == TrainState.manual) {
      return _PriorityScreen(
        key: const ValueKey('manual'),
        icon: Icons.pan_tool_rounded,
        color: const Color(0xFFCC3300),
        title: 'MANUAL MODE',
        message: 'Train under manual control',
      );
    }
    if (state == TrainState.recovery) {
      return _PriorityScreen(
        key: const ValueKey('recovery'),
        icon: Icons.sync_problem_rounded,
        color: const Color(0xFF333333),
        title: 'CONNECTION LOST',
        message: 'Attempting to reconnect…',
      );
    }

    switch (state) {
      case TrainState.idle:
        return IdleScreen(key: const ValueKey('idle'), data: _data);
      case TrainState.routeSelected:
        return RouteSelectedScreen(key: const ValueKey('routeSelected'), data: _data);
      case TrainState.atStation:
        if (_showArrivedMessage) {
          return ArrivedMessageScreen(
            key: ValueKey('arrived-${_data.currentStation}'),
            data: _data,
          );
        }
        return StationScreen(key: ValueKey('station-${_data.currentStation}'), data: _data);
      case TrainState.departing:
        return DepartingScreen(key: const ValueKey('departing'), data: _data);
      case TrainState.moving:
        if (_showSpeedPhase) {
          return MovingSpeedScreen(key: const ValueKey('movingSpeed'), data: _data);
        }
        return MovingProgressScreen(key: const ValueKey('movingProgress'), data: _data);
      case TrainState.arriving:
        return ArrivingScreen(key: const ValueKey('arriving'), data: _data);
      case TrainState.endOfRoute:
        return EndOfRouteScreen(key: const ValueKey('endOfRoute'), data: _data);
      default:
        return IdleScreen(key: const ValueKey('idle-default'), data: _data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = _buildScreen();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: screen,
    );
  }
}

// ── _PriorityScreen ───────────────────────────────────────────────────────────
class _PriorityScreen extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _PriorityScreen({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 64),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: kSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
