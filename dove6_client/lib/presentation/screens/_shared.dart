// Shared colours, scaffold, and reusable widgets used by all screens
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

// ── Typography helpers ────────────────────────────────────────────────────────
TextStyle pisStationHero({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 96, fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 96, height: 1.1, color: color);

TextStyle pisStationPrimary({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 60, fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 60, height: 1.15, color: color);

TextStyle pisStationCallout({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 36, fontWeight: FontWeight.w700,
    height: 1.2, color: color);

TextStyle pisDirectionName({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 30, fontWeight: FontWeight.w700,
    height: 1.3, color: color);

TextStyle pisArabicLarge({Color color = kDim}) =>
  GoogleFonts.dmSans(
    fontSize: 30, fontWeight: FontWeight.w500,
    height: 1.4, color: color);

TextStyle pisArabicMedium({Color color = kDim}) =>
  GoogleFonts.dmSans(
    fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.4, color: color);

TextStyle pisContextLabel({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w500,
    letterSpacing: 0.04 * 18, height: 1.3, color: color);

TextStyle pisInfoLabel({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 24, fontWeight: FontWeight.w500,
    height: 1.3, color: color);

TextStyle pisMegaDisplay({Color color = kPrimary}) =>
  GoogleFonts.inter(
    fontSize: 120, fontWeight: FontWeight.w300,
    letterSpacing: -0.02 * 120, height: 1.0, color: color,
    fontFeatures: [const FontFeature.tabularFigures()]);

TextStyle pisClock({Color color = kPrimary}) =>
  GoogleFonts.inter(
    fontSize: 48, fontWeight: FontWeight.w500,
    letterSpacing: -0.02 * 48, height: 1.0, color: color,
    fontFeatures: [const FontFeature.tabularFigures()]);

TextStyle pisHeaderTrainId({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    letterSpacing: 0.1, height: 1.2, color: color);

TextStyle pisHeaderMeta({Color color = kDim}) =>
  GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w500,
    height: 1.2, color: color);

TextStyle pisProgressCurrent({Color color = kAccent}) =>
  GoogleFonts.dmSans(
    fontSize: 20, fontWeight: FontWeight.w700,
    height: 1.2, color: color);

TextStyle pisProgressNext({Color color = kPrimary}) =>
  GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    height: 1.2, color: color);

TextStyle pisProgressOther({Color color = kSecondary}) =>
  GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w600,
    height: 1.2, color: color);

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
        style: pisClock(),
        children: [
          TextSpan(text: h),
          TextSpan(
            text: ':',
            style: TextStyle(
              color: kPrimary.withValues(alpha: _colonVisible ? 1.0 : 0.6),
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
              // ── Left: ONCF | Z2M · trainId | pills ───────────────────────
              Row(
                children: [
                  Image.asset(
                    'assets/images/Logo-oncf.png',
                    height: 48,
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 32, color: kBorder),
                  const SizedBox(width: 16),
                  Text('Z2M', style: pisHeaderTrainId(color: kSecondary)),
                  const SizedBox(width: 4),
                  Text('· ${data.trainId}', style: pisHeaderMeta(color: kDim)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Voiture 3',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kDim),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0x1FE8650A), // kAccent.withValues(alpha: 0.12)
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '1ère Classe',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kAccent),
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

  String _shortenLabel(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 12) return trimmed;

    final words = trimmed.split(' ');
    if (words.length >= 2) {
      final first = words.first;
      final second = words[1];
      if (first.length <= 5) {
        final shortSecond = second.length > 3 ? second.substring(0, 3) : second;
        return '$first $shortSecond.';
      }
      final shortFirst = first.length > 8 ? first.substring(0, 8) : first;
      return '$shortFirst.';
    }

    final shortText = trimmed.length > 10 ? trimmed.substring(0, 10) : trimmed;
    return '$shortText…';
  }

  double _nodeX(int index, int lastIdx, double width) {
    if (lastIdx <= 0) return width / 2;
    if (index == 0) return 0;
    if (index == lastIdx) return width;
    return width * index / lastIdx;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (stations.isEmpty) return;

    final int lastIdx = stations.length - 1;
    final double trackY = 20;
    final double labelTop = 42;
    final double clampedProgress = progress.clamp(0.0, 1.0);

    final Paint baseTrack = Paint()
      ..color = kBorder
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint fillTrack = Paint()
      ..color = kAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, trackY),
      Offset(size.width, trackY),
      baseTrack,
    );

    canvas.drawLine(
      Offset(0, trackY),
      Offset(size.width * clampedProgress, trackY),
      fillTrack,
    );

    for (int i = 0; i <= lastIdx; i++) {
      final double x = _nodeX(i, lastIdx, size.width);
      final Offset center = Offset(x, trackY);

      final bool isPast = i < currentStationIndex;
      final bool isCurrent = i == currentStationIndex;
      final bool isFuture = i > currentStationIndex;

      if (isCurrent) {
        canvas.drawCircle(
          center,
          14,
          Paint()
            ..color = kAccent.withOpacity(0.14)
            ..style = PaintingStyle.fill,
        );

        canvas.drawCircle(
          center,
          10,
          Paint()
            ..color = kAccent
            ..style = PaintingStyle.fill,
        );
      } else if (isPast) {
        canvas.drawCircle(
          center,
          7,
          Paint()
            ..color = kAccent
            ..style = PaintingStyle.fill,
        );
      } else if (isFuture) {
        canvas.drawCircle(
          center,
          7,
          Paint()
            ..color = kBg
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          center,
          7,
          Paint()
            ..color = kDim
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }

      final double slotWidth =
          lastIdx == 0 ? size.width : size.width / stations.length;
      final double maxLabelWidth = (slotWidth * 0.92).clamp(52.0, 110.0);

      final String stationLabel = _shortenLabel(stations[i]);

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: stationLabel,
          style: TextStyle(
            color: isCurrent ? kAccent : (isPast ? kSecondary : kDim),
            fontSize: isCurrent ? 12.5 : 10.5,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            height: 1.15,
          ),
        ),
        maxLines: 1,
        ellipsis: '…',
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: maxLabelWidth);

      double labelX = x - (labelPainter.width / 2);
      if (labelX < 0) labelX = 0;
      if (labelX + labelPainter.width > size.width) {
        labelX = size.width - labelPainter.width;
      }

      labelPainter.paint(canvas, Offset(labelX, labelTop));
    }
  }

  @override
  bool shouldRepaint(covariant RouteProgressPainter oldDelegate) {
    return oldDelegate.stations != stations ||
        oldDelegate.progress != progress ||
        oldDelegate.currentStationIndex != currentStationIndex ||
        oldDelegate.isArabic != isArabic;
  }
}