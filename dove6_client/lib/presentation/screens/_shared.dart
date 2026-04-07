// Shared colours, scaffold, and reusable widgets used by all screens
import 'package:flutter/material.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const kBg         = Color(0xFF0A0A0A);
const kSurface    = Color(0xFF141414);
const kCard       = Color(0xFF1C1C1E);
const kBorder     = Color(0xFF2A2A2A);
const kPrimary    = Color(0xFFFFFFFF);
const kSecondary  = Color(0xFF888888);
const kAccent     = Color(0xFF4FC3F7);
const kAccentGold = Color(0xFFFFD54F);
const kDim        = Color(0xFF333333);

// ── ScreenScaffold ────────────────────────────────────────────────────────────
class ScreenScaffold extends StatelessWidget {
  final Widget child;
  const ScreenScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: child,
        ),
      ),
    );
  }
}

// ── StationRow ────────────────────────────────────────────────────────────────
class StationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double valueFontSize;

  const StationRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueFontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: kSecondary,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── TrainIdChip ───────────────────────────────────────────────────────────────
class TrainIdChip extends StatelessWidget {
  final String trainId;
  const TrainIdChip({super.key, required this.trainId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kDim,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        trainId,
        style: const TextStyle(
          color: kSecondary,
          fontSize: 13,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ── KDivider ──────────────────────────────────────────────────────────────────
class KDivider extends StatelessWidget {
  const KDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(color: kBorder, thickness: 1, height: 32);
  }
}

// ── RouteProgressPainter ──────────────────────────────────────────────────────
class RouteProgressPainter extends CustomPainter {
  final double progress;
  final int currentStationIndex;
  final List<String> stations;

  const RouteProgressPainter({
    required this.progress,
    required this.currentStationIndex,
    required this.stations,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double trackY = 16;
    const double dotRadius = 7;
    const double labelOffset = 28;

    final trackPaint = Paint()
      ..color = kDim
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = kAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw full track
    canvas.drawLine(Offset(0, trackY), Offset(size.width, trackY), trackPaint);

    // Draw progress portion
    if (progress > 0) {
      canvas.drawLine(
        Offset(0, trackY),
        Offset(progress * size.width, trackY),
        progressPaint,
      );
    }

    if (stations.isEmpty) return;

    final int lastIndex = stations.length - 1;

    for (int i = 0; i <= lastIndex; i++) {
      final double x = lastIndex == 0
          ? size.width / 2
          : i * size.width / lastIndex;
      final Offset center = Offset(x, trackY);

      final bool isPassed = i < currentStationIndex;
      final bool isCurrent = i == currentStationIndex;

      if (isCurrent) {
        // Gold ring + filled dot
        final ringPaint = Paint()
          ..color = kAccentGold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        final fillPaint = Paint()
          ..color = kAccentGold
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, dotRadius, fillPaint);
        canvas.drawCircle(center, dotRadius + 3, ringPaint);
      } else if (isPassed) {
        final paint = Paint()
          ..color = kAccent
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, dotRadius, paint);
      } else {
        final paint = Paint()
          ..color = kDim
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, dotRadius, paint);
      }

      // Station label
      final Color labelColor = isCurrent
          ? kAccentGold
          : isPassed
              ? kAccent
              : kDim;

      final textSpan = TextSpan(
        text: stations[i],
        style: TextStyle(color: labelColor, fontSize: 11),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, trackY + labelOffset),
      );
    }
  }

  @override
  bool shouldRepaint(RouteProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.currentStationIndex != currentStationIndex;
}
