# DYNAMIC.md — Make Client Fully Dynamic

## Rule
dove6_client must never hardcode any route information.
The server decides everything. The client only displays.

## Fix 1 — moving_progress_screen.dart
Find any hardcoded number of stations.
For example: '/ 18 stations' or '18' alone.
Replace with: '/ ${data.routeStations.length} stations'

## Fix 2 — route_selected_screen.dart
Find the hardcoded string 'Z2M · ONCF'.
Replace with this logic:
The trainId field already comes from the server.
Add a subtitle line below trainId that reads:
  data.trainId contains 'DOVE-6'
  The line 'Z2M · ONCF' should become a constant
  defined at the top of main.dart:
  const String kTrainLine = 'Z2M · ONCF';
  Pass kTrainLine to RouteSelectedScreen as a
  parameter called trainLine.
  Display it below trainId.

## Fix 3 — verify all screens
Search every screen file for any hardcoded:
- Station names (Marrakech, Tanger, etc)
- Numbers like 18, 17, 4
- Route lengths
- Any string that should come from DisplayData

Replace every one with the correct dynamic value
from DisplayData.

## Fix 4 — end_of_route_screen.dart
Verify destination name comes from:
  data.destinationFr or data.destinationAr
Not hardcoded 'Tanger Ville'.

## Fix 5 — RouteProgressPainter in _shared.dart
Verify the painter uses stations.length for spacing.
Never assumes a fixed number of stations.
Must work correctly with 4 stations or 22 stations.

## After fixing run
flutter analyze
flutter run -d linux

Test with short route — in dove6_server journey.go
temporarily change routeFr to only 4 stations and
verify the app adapts perfectly.
Then restore the 18-station route.

Report every hardcoded value found and fixed.