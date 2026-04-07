// Moving (progress phase) screen — journey progress percentage and route bar
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class MovingProgressScreen extends StatelessWidget {
  final DisplayData data;
  const MovingProgressScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = data.routeStations.indexOf(data.currentStation);
    final int percent = (data.routeProgress * 100).round();

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              const Spacer(),
              Text(
                '${data.speedKmh.toStringAsFixed(0)} km/h',
                style: const TextStyle(
                  color: kSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              '$percent%',
              style: const TextStyle(
                color: kAccent,
                fontSize: 100,
                fontWeight: FontWeight.w200,
                letterSpacing: -2,
                height: 1,
              ),
            ),
          ),
          const Center(
            child: Text(
              'of journey complete',
              style: TextStyle(
                color: kSecondary,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
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
          const KDivider(),
          StationRow(label: 'Next stop', value: data.nextStation, valueColor: kAccent),
          const SizedBox(height: 16),
          StationRow(
            label: 'Destination',
            value: data.destination,
            valueColor: kSecondary,
            valueFontSize: 18,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
