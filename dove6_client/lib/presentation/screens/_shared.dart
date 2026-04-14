// Shared colours, scaffold, and reusable widgets used by all screens
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/display_data.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const kBg         = Color(0xFFE8E4DF); // warm beige — screen background
const kSurface    = Color(0xFFD6CFC7); // lifted surface
const kCard       = Color(0xFFD6CFC7); // card background
const kBorder     = Color(0xFFC8C3BC); // subtle border / track base
const kPrimary    = Color(0xFF1A1A1A); // near-black — main text
const kSecondary  = Color(0xFF5F5E5A); // muted — labels / next station
const kAccent     = Color(0xFFE8650A); // ONCF orange — highlights / current
const kAccentGold = Color(0xFF333333); // dark grey
const kDim        = Color(0xFFBFB9B1); // very subtle — anchors / future dots

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

// ── ClockWidget ───────────────────────────────────────────────────────────────
class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  Timer? _clockTimer;
  Timer? _colonTimer;
  bool _colonVisible = true;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _colonTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => _colonVisible = !_colonVisible);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _colonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: kPrimary,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        children: [
          TextSpan(text: h),
          TextSpan(
            text: ':',
            style: TextStyle(
              color: kPrimary.withValues(alpha: _colonVisible ? 1.0 : 0.2),
            ),
          ),
          TextSpan(text: m),
        ],
      ),
    );
  }
}

// ── SharedHeader ──────────────────────────────────────────────────────────────
class SharedHeader extends StatelessWidget {
  final DisplayData data;
  final bool isArabic;

  const SharedHeader({
    super.key,
    required this.data,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 72,
          color: kBg,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Left: ONCF | Z2M · trainId ───────────────────────────────
              Row(
                children: [
                  Image.asset(
                    'assets/images/Logo-oncf.png',
                    height: 48,
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 24, color: kBorder),
                  const SizedBox(width: 16),
                  Text(
                    'Z2M · ${data.trainId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              // ── Right: clock ──────────────────────────────────────────────
              const ClockWidget(),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kBorder),
      ],
    );
  }
}

// ── RouteConnector ────────────────────────────────────────────────────────────
class RouteConnector extends StatelessWidget {
  const RouteConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: kAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 144,
          height: 6,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward_rounded, color: kAccent, size: 28),
      ],
    );
  }
}

// ── RouteProgressPainter ──────────────────────────────────────────────────────
// Use inside a SizedBox(height: 90) in every screen.
// currentStationIndex: data.routeStations.indexOf(data.currentStation)
//                        .clamp(0, data.routeStations.length - 1)
class RouteProgressPainter extends CustomPainter {
  final List<String> stations;
  final double progress;
  final int currentStationIndex;
  final bool isArabic;

  const RouteProgressPainter({
    required this.stations,
    required this.progress,
    required this.currentStationIndex,
    this.isArabic = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stations.isEmpty) return;

    // Track line sits at this Y — all dot centers are clamped to this value
    final double trackY  = size.height * 0.40;
    final int    lastIdx = stations.length - 1;
    final double totalWidth = size.width;

    // ── Track background ───────────────────────────────────────────────────
    canvas.drawLine(
      Offset(0, trackY),
      Offset(totalWidth, trackY),
      Paint()
        ..color       = kBorder
        ..strokeWidth = 6
        ..strokeCap   = StrokeCap.round
        ..style       = PaintingStyle.stroke,
    );

    // ── Track fill orange ──────────────────────────────────────────────────
    if (progress > 0) {
      canvas.drawLine(
        Offset(0, trackY),
        Offset(progress * totalWidth, trackY),
        Paint()
          ..color       = kAccent
          ..strokeWidth = 6
          ..strokeCap   = StrokeCap.round
          ..style       = PaintingStyle.stroke,
      );
    }

    // ── Station dots & labels ──────────────────────────────────────────────
    for (int i = 0; i <= lastIdx; i++) {
      final double x = lastIdx == 0 ? totalWidth / 2 : i * totalWidth / lastIdx;
      final center   = Offset(x, trackY); // node_center_y == track_center_y

      final bool isPassed  = i < currentStationIndex;
      final bool isCurrent = i == currentStationIndex;
      final bool isNext    = i == currentStationIndex + 1;
      // isFuture = (!isPassed && !isCurrent && !isNext)

      if (isCurrent) {
        // Glow ring
        canvas.drawCircle(
          center,
          18,
          Paint()
            ..color = kAccent.withValues(alpha: 0.15)
            ..style = PaintingStyle.fill,
        );
        // Solid dot
        canvas.drawCircle(
          center,
          12,
          Paint()
            ..color = kAccent
            ..style = PaintingStyle.fill,
        );
      } else if (isPassed) {
        canvas.drawCircle(
          center,
          8,
          Paint()
            ..color = kAccent
            ..style = PaintingStyle.fill,
        );
      } else if (isNext) {
        canvas.drawCircle(center, 8, Paint()..color = kBg..style = PaintingStyle.fill);
        canvas.drawCircle(
          center,
          8,
          Paint()
            ..color       = kAccent
            ..style       = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      } else {
        // Future dot
        canvas.drawCircle(center, 8, Paint()..color = kBg..style = PaintingStyle.fill);
        canvas.drawCircle(
          center,
          8,
          Paint()
            ..color       = kBorder
            ..style       = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Labels: only current and next
      if (isCurrent || isNext) {
        final tp = TextPainter(
          text: TextSpan(
            text: stations[i],
            style: TextStyle(
              color:      isCurrent ? kAccent : kSecondary,
              fontSize:   isCurrent ? 14 : 12,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign:     TextAlign.center,
        )..layout(maxWidth: 140);

        tp.paint(canvas, Offset(x - tp.width / 2, trackY + 22));
      }
    }

    // ── Anchor labels (first & last station, always visible) ───────────────
    if (stations.length >= 2) {
      // Left anchor
      final firstTp = TextPainter(
        text: TextSpan(
          text:  stations.first,
          style: const TextStyle(color: kDim, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      firstTp.paint(canvas, Offset(0, size.height - firstTp.height));

      // Right anchor
      final lastTp = TextPainter(
        text: TextSpan(
          text:  stations.last,
          style: const TextStyle(color: kDim, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      lastTp.paint(
        canvas,
        Offset(totalWidth - lastTp.width, size.height - lastTp.height),
      );
    }
  }

  @override
  bool shouldRepaint(RouteProgressPainter old) =>
      old.progress != progress ||
      old.currentStationIndex != currentStationIndex ||
      old.stations != stations;
}
