// Shared colours, scaffold, and reusable widgets used by all screens
import 'package:flutter/material.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const kBg         = Color(0xFFE8E4DF); // warm light grey background
const kSurface    = Color(0xFFD6CFC7); // slightly darker surface
const kCard       = Color(0xFFD6CFC7); // card background
const kBorder     = Color(0xFFC8C3BC); // subtle border
const kPrimary    = Color(0xFF1A1A1A); // near black — main text
const kSecondary  = Color(0xFF5F5E5A); // muted grey — labels
const kAccent     = Color(0xFFE8650A); // orange — stations, highlights
const kAccentGold = Color(0xFF333333); // dark grey — speed number
const kDim        = Color(0xFFBFB9B1); // very subtle — track, dividers

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
  final List<String> stations;
  final double progress;
  final int currentStationIndex;

  const RouteProgressPainter({
    required this.stations,
    required this.progress,
    required this.currentStationIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int total = stations.length;
    if (total == 0) return;
    final int cur   = currentStationIndex.clamp(0, total - 1);
    final int last  = total - 1;
    final double w  = size.width;
    final double trackY = size.height * 0.42;

    // ── Draw the grey track line ──────────────────────────
    canvas.drawLine(
      Offset(0, trackY),
      Offset(w, trackY),
      Paint()
        ..color       = kDim
        ..strokeWidth = 2
        ..strokeCap   = StrokeCap.round,
    );

    // ── Draw ALL station dots ─────────────────────────────
    for (int i = 0; i < total; i++) {
      final double x = i == 0
          ? 0
          : i == last
              ? w
              : w * i / last;

      final bool isPast    = i < cur;
      final bool isCurrent = i == cur;
      final bool isNext    = i == cur + 1;

      if (isCurrent) {
        // Glow ring
        canvas.drawCircle(
          Offset(x, trackY), 16,
          Paint()
            ..color = kAccent.withValues(alpha: 0.13)
            ..style = PaintingStyle.fill,
        );
        // Current dot
        canvas.drawCircle(
          Offset(x, trackY), 10,
          Paint()
            ..color = kAccent
            ..style = PaintingStyle.fill,
        );
      } else if (isPast) {
        canvas.drawCircle(
          Offset(x, trackY), 5,
          Paint()
            ..color = kAccent
            ..style = PaintingStyle.fill,
        );
      } else if (isNext) {
        // Hollow ring — filled with background color
        canvas.drawCircle(
          Offset(x, trackY), 6,
          Paint()
            ..color = kBg
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(x, trackY), 6,
          Paint()
            ..color       = kAccent
            ..style       = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      } else {
        // Future dot
        canvas.drawCircle(
          Offset(x, trackY), 4,
          Paint()
            ..color = kDim
            ..style = PaintingStyle.fill,
        );
      }
    }

    // ── Origin label (left) ───────────────────────────────
    final tpOrigin = TextPainter(
      text: TextSpan(
        text: stations.first,
        style: const TextStyle(
          color: kDim,
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w / 2);
    tpOrigin.paint(canvas, Offset(0, trackY + 20));

    // ── Destination label (right) ─────────────────────────
    final tpDest = TextPainter(
      text: TextSpan(
        text: stations.last,
        style: const TextStyle(
          color: kDim,
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w / 2);
    tpDest.paint(
      canvas,
      Offset(w - tpDest.width, trackY + 20),
    );
  }

  @override
  bool shouldRepaint(RouteProgressPainter old) =>
      old.progress            != progress            ||
      old.currentStationIndex != currentStationIndex ||
      old.stations            != stations;
}

// ── AudioSyncBadge ────────────────────────────────────────────────────────────
// Shows an Arabic audio indicator when isArabic is true; hidden otherwise.
class AudioSyncBadge extends StatelessWidget {
  final bool isArabic;

  const AudioSyncBadge({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    if (!isArabic) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.volume_up_rounded, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'ع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

