// Idle state screen — shows time, date, and welcome message
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';
import '_shared.dart';

class IdleScreen extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const IdleScreen({super.key, required this.data, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final now = data.timestamp;
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final date =
        '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return ScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TrainIdChip(trainId: data.trainId),
              const Spacer(),
              AudioSyncBadge(activeAudioLang: data.activeAudioLang),
            ],
          ),
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
          isArabic
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'مرحباً بكم على متن القطار',
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                )
              : const Text(
                  'Bienvenue à bord',
                  style: TextStyle(
                    color: kSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                  ),
                ),
          const SizedBox(height: 6),
          const Text(
            'Office National des Chemins de Fer',
            style: TextStyle(color: kDim, fontSize: 14, letterSpacing: 2),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _weekday(int d) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[(d - 1).clamp(0, 6)];
  }

  String _month(int m) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
