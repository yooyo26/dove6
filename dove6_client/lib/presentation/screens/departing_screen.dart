// Departing screen — farewell message and next stop info
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class DepartingScreen extends StatelessWidget {
  final DisplayData data;
  const DepartingScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrainIdChip(trainId: data.trainId),
          const Spacer(),
          const Text(
            'Welcome aboard',
            style: TextStyle(
              color: kPrimary,
              fontSize: 42,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Departing ${data.currentStation}',
            style: const TextStyle(
              color: kSecondary,
              fontSize: 20,
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
          const Spacer(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
