// End of route screen — thank you message with full route progress
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class EndOfRouteScreen extends StatelessWidget {
  final DisplayData data;
  const EndOfRouteScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final int lastIndex = data.routeStations.length - 1;

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrainIdChip(trainId: data.trainId),
          const Spacer(),
          const Text(
            'Thank you for\ntravelling with us.',
            style: TextStyle(
              color: kPrimary,
              fontSize: 46,
              fontWeight: FontWeight.w300,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Terminal — ${data.destination}',
            style: const TextStyle(
              color: kAccent,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'End of route',
            style: TextStyle(
              color: kSecondary,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: RouteProgressPainter(
                progress: 1.0,
                currentStationIndex: lastIndex < 0 ? 0 : lastIndex,
                stations: data.routeStations,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
