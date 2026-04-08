# CLAUDECLIENT2.md — Fix overflow for 8 stations

## Mission
Fix two specific overflow problems that appear when the
route has more than 5 stations. Do NOT change anything
else. Logic, languages, colors, screens — all stay the same.

---

## CRITICAL RULES

- Only touch _shared.dart and route_selected_screen.dart
- Do NOT change any other file
- Do NOT change any color
- Do NOT change any screen logic
- Do NOT change display_mapper.dart
- Do NOT change RouteProgressPainter drawing logic
- Only fix the two overflow issues described below

---

## FIX 1 — Station card in route_selected_screen.dart

The station card currently uses a Row with
mainAxisAlignment.spaceEvenly. With 8 stations this
overflows off screen.

Find this widget in route_selected_screen.dart:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: ...
)
```

Replace it with a Wrap widget:

```dart
Wrap(
  spacing: 10,
  runSpacing: 8,
  children: (isArabic ? data.routeStationsAr : data.routeStationsFr)
      .map((s) {
    final isFirst = s == (isArabic
        ? data.routeStationsAr.first
        : data.routeStationsFr.first);
    final isLast = s == (isArabic
        ? data.routeStationsAr.last
        : data.routeStationsFr.last);
    return isArabic
        ? Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFirst || isLast ? kAccent : kDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                s,
                style: TextStyle(
                  color: isFirst || isLast
                      ? Colors.white : kSecondary,
                  fontSize: 13,
                  fontWeight: isFirst || isLast
                      ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFirst || isLast ? kAccent : kDim,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              s,
              style: TextStyle(
                color: isFirst || isLast
                    ? Colors.white : kSecondary,
                fontSize: 13,
                fontWeight: isFirst || isLast
                    ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
  }).toList(),
)
```

---

## FIX 2 — RouteProgressPainter in _shared.dart

When there are more than 5 stations the station name
labels below the dots overlap each other and become
unreadable.

Find the RouteProgressPainter paint method in _shared.dart.

Find the section that draws station name labels below
each dot. Replace that entire label-drawing section with
this smart logic:

```dart
// Smart label display
// When 5 or fewer stations: show all labels
// When more than 5 stations: show only 3 labels
//   - origin station (first) on the left
//   - current station in the middle in kAccent color
//   - destination (last) on the right

final int count = stations.length;
final bool manyStations = count > 5;

for (int i = 0; i < count; i++) {
  final double x = i * (size.width / (count - 1));

  if (manyStations) {
    // Only draw label for first, current, and last
    final bool isFirst = i == 0;
    final bool isCurrent = i == currentStationIndex;
    final bool isLast = i == count - 1;

    if (!isFirst && !isCurrent && !isLast) continue;

    final Color labelColor = isCurrent ? kAccent : kSecondary;
    final bool bold = isCurrent;

    final tp = TextPainter(
      text: TextSpan(
        text: stations[i],
        style: TextStyle(
          color: labelColor,
          fontSize: 11,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width / 3);

    // Position labels: first=left, last=right, current=center
    double labelX;
    if (isFirst) {
      labelX = 0;
    } else if (isLast) {
      labelX = size.width - tp.width;
    } else {
      labelX = x - tp.width / 2;
      labelX = labelX.clamp(0, size.width - tp.width);
    }

    tp.paint(canvas, Offset(labelX, trackY + 16));
  } else {
    // 5 or fewer stations — show all labels normally
    final bool isCurrent = i == currentStationIndex;
    final bool isPassed = progress >= (i / (count - 1));

    final Color labelColor = isCurrent
        ? kAccent
        : isPassed
            ? kAccent.withOpacity(0.7)
            : kSecondary;

    final tp = TextPainter(
      text: TextSpan(
        text: stations[i],
        style: TextStyle(
          color: labelColor,
          fontSize: 11,
          fontWeight: isCurrent
              ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width / count + 20);

    double labelX = x - tp.width / 2;
    labelX = labelX.clamp(0, size.width - tp.width);
    tp.paint(canvas, Offset(labelX, trackY + 16));
  }
}
```

---

## VERIFY

After implementing run:
```bash
flutter analyze
flutter run -d linux
```

Test in browser:
```
http://localhost:8080/jump?step=1
```

Route selected screen must show all 8 stations
as individual pills that wrap to the next line.
No overflow. No text cut off.

```
http://localhost:8080/jump?step=12
```

Station screen progress track must show only
3 labels: Marrakech on left, current station
in orange in middle, Fès on right.
No overlapping labels.

Report which files were modified.