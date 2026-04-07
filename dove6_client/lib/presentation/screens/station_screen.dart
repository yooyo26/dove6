// Station screen — shows current stop, next stop, and route progress
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class StationScreen extends StatelessWidget {
  final DisplayData data;
  const StationScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isFinal = data.currentStation == data.destination;
    final int currentIndex = data.routeStations.indexOf(data.currentStation);

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              if (!isFinal) ...[
                const SizedBox(width: 12),
                const Text(
                  'STOPPED',
                  style: TextStyle(
                    color: kSecondary,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          const Text(
            'CURRENT STATION',
            style: TextStyle(
              color: kSecondary,
              fontSize: 13,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.currentStation,
            style: const TextStyle(
              color: kPrimary,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
          const KDivider(),
          if (!isFinal) ...[
            StationRow(label: 'Next stop', value: data.nextStation, valueColor: kAccent),
            const SizedBox(height: 16),
            StationRow(
              label: 'Destination',
              value: data.destination,
              valueColor: kSecondary,
              valueFontSize: 18,
            ),
          ] else
            const Text(
              'Final destination reached',
              style: TextStyle(
                color: kAccent,
                fontSize: 20,
              ),
            ),
          const Spacer(),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: RouteProgressPainter(
                progress: data.routeProgress,
                currentStationIndex: currentIndex < 0 ? 0 : currentIndex,
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
