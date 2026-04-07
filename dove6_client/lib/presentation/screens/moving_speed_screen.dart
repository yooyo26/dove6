// Moving (speed phase) screen — large speed readout
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class MovingSpeedScreen extends StatelessWidget {
  final DisplayData data;
  const MovingSpeedScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              const Spacer(),
              Text(
                data.destination,
                style: const TextStyle(
                  color: kSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              data.speedKmh.toStringAsFixed(0),
              style: const TextStyle(
                color: kAccentGold,
                fontSize: 130,
                fontWeight: FontWeight.w200,
                letterSpacing: -4,
                height: 1,
              ),
            ),
          ),
          const Center(
            child: Text(
              'km/h',
              style: TextStyle(
                color: kSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),
          ),
          const Spacer(),
          const KDivider(),
          StationRow(label: 'Next stop', value: data.nextStation, valueColor: kAccent),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
