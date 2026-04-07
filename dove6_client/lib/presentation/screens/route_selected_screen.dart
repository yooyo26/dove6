// Route selected screen — shows origin, destination, and all route stations
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class RouteSelectedScreen extends StatelessWidget {
  final DisplayData data;
  const RouteSelectedScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrainIdChip(trainId: data.trainId),
          const Spacer(),
          const Text(
            'ROUTE',
            style: TextStyle(
              color: kSecondary,
              fontSize: 13,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                data.currentStation,
                style: const TextStyle(
                  color: kPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward_rounded, color: kAccent, size: 28),
              ),
              Text(
                data.destination,
                style: const TextStyle(
                  color: kAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: kCard,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.routeStations.map((s) {
                return Text(
                  s,
                  style: const TextStyle(
                    color: kSecondary,
                    fontSize: 14,
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          const Text(
            'Preparing for departure',
            style: TextStyle(
              color: kSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
