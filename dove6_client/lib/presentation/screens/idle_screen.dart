// Idle state screen — shows time, date, and welcome message
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class IdleScreen extends StatelessWidget {
  final DisplayData data;
  const IdleScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final now = data.timestamp;
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final date = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrainIdChip(trainId: data.trainId),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(
              color: kPrimary,
              fontSize: 80,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              color: kSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Spacer(),
          const Text(
            'Welcome aboard',
            style: TextStyle(
              color: kSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Office National des Chemins de Fer',
            style: TextStyle(
              color: kDim,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _weekday(int d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(d - 1).clamp(0, 6)];
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
