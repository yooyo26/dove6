// Arriving screen — shows approach to next station with progress indicators
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class ArrivingScreen extends StatelessWidget {
  final DisplayData data;
  const ArrivingScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = data.routeStations.indexOf(data.currentStation);

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
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Arriving at',
            style: TextStyle(
              color: kSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.nextStation,
            style: const TextStyle(
              color: kAccent,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 40),
          LinearProgressIndicator(
            value: data.routeProgress,
            minHeight: 6,
            backgroundColor: kDim,
            valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
          ),
          const SizedBox(height: 32),
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
          const Spacer(),
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
