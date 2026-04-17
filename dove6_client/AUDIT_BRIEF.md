# AUDIT_BRIEF.md — Dove6 Client Gap Analysis

## YOUR ROLE

You are auditing the dove6_client Flutter application against three 
authoritative references:

1. **The architecture document** (Dove6 system architecture, 13 sections, 
   describes the full system, state machine, API contract, and design 
   intent).
2. **The real NVR API contract** (what my colleague is actually 
   implementing on the R6S Lanner server — some fields and shapes differ 
   from what the architecture assumed).
3. **The UI redesign spec** (UI_REDESIGN.md — the final visual design 
   with exact pixel values, colors, fonts, and layouts per screen).

Your job is to find every mismatch between what these three documents 
specify and what the current code does. Then produce a structured gap 
report.

**YOU DO NOT MODIFY ANY CODE IN THIS PASS.** Audit only. A separate 
pass will fix the issues once I review your report.

---

## REFERENCE 1 — THE REAL NVR API CONTRACT

This is what the production server actually returns. All endpoints are 
relative to base URL `http://<nvr_ip>:3002/v0`.

### Endpoint shapes (EXACT)

| Endpoint | Method | Response shape |
|---|---|---|
| `/running-state` | GET | `{"current_state": "<string>"}` |
| `/audio-state` | GET | `{"audio_action": "<string>"}` |
| `/data/speed` | GET | `{"speed": <number>}` |
| `/data/distance-ratio` | GET | `{"ratio": <int 0-100>}` |
| `/data/current-route` | GET | `{"route_id": "<uuid>", "is_in_reverse": <bool>, "start_station_index": <int>}` |
| `/data/stations-in-route/{route_id}` | GET | `["<uuid>", "<uuid>", ...]` (BARE ARRAY) |
| `/data/station-info/{station_id}` | GET | `{"display_name": "<str>", "display_name_en": "<str>", "display_name_fr": "<str>"}` |
| `/sensors/human-counter` | GET | `{"count": <int>}` |

### Running-state possible values (case-sensitive)

- `operating_state_idle`
- `operating_state_routeselected`
- `operating_state_atstation`
- `operating_state_departing`
- `operating_state_moving`
- `operating_state_coasting`  → maps to same display state as moving
- `operating_state_arriving`
- `operating_state_endofroute`
- `operating_state_recovery`
- `operating_state_warning`
- `Operating_State_ManualHandling`  ← mixed case, firmware quirk

### Audio-state possible values

- `playing_default_audio`
- `playing_english_audio`
- `playing_french_audio`
- `no_audio_is_playing`

### Critical gaps in the real NVR contract vs. the architecture

- **No `display_name_ar` field** in station-info. The architecture 
  requires Arabic support. The client must gracefully fall back to 
  `display_name_fr` (or `display_name`) when `display_name_ar` is 
  absent, so the Arabic layout renders with placeholder text until the 
  server adds the field.
- **No `playing_arabic_audio`** in audio-state. The architecture uses 
  this signal to switch the display to Arabic. With the current 
  contract, Arabic display will never trigger from audio-state alone. 
  Flag this as a known integration gap.
- **No `/health` endpoint.** The architecture mentions it, the real 
  contract does not include it. Client should not depend on it.
- **`start_station_index` naming is ambiguous.** The architecture 
  describes a "current station index." The real field is named 
  `start_station_index`. Treat it as the live current-station index 
  for now (pending confirmation from the colleague), but flag every 
  usage site in the report so it can be renamed once confirmed.
- **`is_in_reverse: true`** means the station list returned by 
  `/data/stations-in-route/{route_id}` should be reversed client-side 
  before use. Verify if the current code handles this.

---

## REFERENCE 2 — THE STATE MACHINE (11 STATES + 3 OVERRIDES)

### Normal states (8)

idle, routeSelected, atStation, departing, moving, coasting, arriving, 
endOfRoute

### Priority override states (3)

warning, manual, recovery — these must be checked FIRST in the 
DisplayMapper, before any normal state. They interrupt regardless of 
journey phase.

### State-specific rules

- **moving + coasting** → render the same screen (MovingSpeedScreen for 
  first 5 seconds, then MovingProgressScreen).
- **arriving → atStation transition** → render ArrivedMessageScreen for 
  exactly 3 seconds, then render StationScreen. Edge-triggered: the 
  flash must fire ONLY on this specific transition, not on 
  idle→atStation or routeSelected→atStation.
- **Timer cancellation**: if state changes away from moving/coasting 
  during the 5-second speed phase, the timer must be cancelled. If 
  state changes away from atStation during the 3-second arrived flash, 
  that timer must be cancelled.

---

## REFERENCE 3 — THE UI REDESIGN SPEC

The full UI redesign spec is in UI_REDESIGN.md. Read it in full before 
auditing the presentation layer. Key rules:

### Design tokens (EXACT values — no deviation)
- kBg: 0xFFE8E4DF
- kSurface: 0xFFD6CFC7
- kBorder: 0xFFC8C3BC
- kPrimary: 0xFF1A1A1A
- kSecondary: 0xFF5F5E5A
- kAccent: 0xFFE8650A
- kDim: 0xFFBFB9B1
- kCard: 0xFFD6CFC7

### Mandatory shared components
- **SharedHeader** (72px height, shown on every screen, includes 
  ClockWidget with pulsing colon every 500ms)
- **ScreenScaffold** (kBg background, SafeArea, 40px horizontal padding)
- **RouteConnector** (used in RouteSelectedScreen)
- **RouteProgressPainter** (redesigned — 6px track, all dots always 
  visible, orange fill from left, glow on current, hollow on next, 
  grey on future, labels only on current and next)

### Per-screen layouts
Nine screens, each with exact font sizes, weights, colors, and spacing 
specified in UI_REDESIGN.md. The spec is the authoritative source.

### Bilingual rules
- Never mix FR and AR on the same screen except bilingual labels 
  ("Gare actuelle · المحطة الحالية")
- All AR text wrapped in Directionality(TextDirection.rtl)
- All AR text with textAlign: TextAlign.right
- Default language: French
- isArabic flag drives the switch

---

## AUDIT PROCEDURE

Execute these steps in order. For each step, produce findings. Do not 
skip steps.

### Step 1 — Map the codebase

Produce a file tree of `lib/` with a one-line purpose note per file. 
Cover: main.dart, domain/, data/, presentation/, and especially every 
file in presentation/screens/.

Confirm these files exist (they must):
- lib/main.dart
- lib/domain/train_state.dart (or equivalent)
- lib/domain/display_data.dart (or equivalent)
- lib/data/data_service.dart (abstract interface)
- lib/data/fake_data_service.dart
- lib/data/nvr_data_service.dart
- lib/presentation/display_mapper.dart
- lib/presentation/screens/_shared.dart
- lib/presentation/screens/idle_screen.dart
- lib/presentation/screens/route_selected_screen.dart
- lib/presentation/screens/station_screen.dart
- lib/presentation/screens/departing_screen.dart
- lib/presentation/screens/moving_speed_screen.dart
- lib/presentation/screens/moving_progress_screen.dart
- lib/presentation/screens/arriving_screen.dart
- lib/presentation/screens/arrived_message_screen.dart
- lib/presentation/screens/end_of_route_screen.dart

Report any missing file.

### Step 2 — Audit the domain layer

Open domain files. Verify:
- TrainState enum exists and contains exactly these values: idle, 
  routeSelected, atStation, departing, moving, coasting, arriving, 
  endOfRoute, warning, manual, recovery.
- DisplayData class exists and contains (at minimum) fields for: 
  currentStation (FR), currentStationAr, nextStation (FR), 
  nextStationAr, destinationFr, destinationAr, speedKmh, 
  distanceRatio (normalized 0.0–1.0), routeStations (FR list), 
  routeStationsAr (AR list), audioLanguage (or isArabic flag), 
  humanCount, trainId, isInReverse, timestamp.
- Domain layer has NO imports of: dart:io, http, dio, flutter/material 
  (domain must be pure data). Report any such import as a violation.

### Step 3 — Audit the DataService abstraction

Open lib/data/data_service.dart. Verify:
- It is an abstract class or interface.
- It exposes: Stream<DisplayData> (or equivalent), start(), dispose().
- FakeDataService and NvrDataService both implement it.
- main.dart instantiates ONE of the two based on a single flag 
  (useLocalSimulation or similar).

Any coupling between presentation layer and a specific service 
implementation = architectural violation. Report file and line.

### Step 4 — Audit NvrDataService against the real NVR contract

This is the highest-priority section of the audit. For each endpoint, 
verify:

**Base URL:** Confirm the code uses `/v0` as a path prefix. If the base 
URL is hardcoded as `http://127.0.0.1:8080` with no `/v0`, that breaks 
production. The base URL should be a single constant, and all endpoint 
paths are appended to it.

**Per-endpoint checks** — for each of the 8 endpoints, report:
- URL path used by the code
- JSON parsing: does it extract the wrapped key (e.g. `json['speed']`) 
  or does it assume a bare value?
- Type: int vs double vs string vs bool — mismatches cause runtime 
  crashes in Dart
- Whether distance-ratio is divided by 100 AFTER parsing (so the client 
  uses 0.0–1.0 internally)
- Whether `/data/stations-in-route/...` is parsed as a bare list (it 
  returns a JSON array, not an object)

**State-string mapping** — in NvrDataService, find the string → 
TrainState mapping. Verify all 11 strings are handled, including the 
mixed-case `Operating_State_ManualHandling`. Report behaviour on 
unknown strings (should emit recovery, not silently fall back to idle).

**Audio-state handling** — verify:
- `/audio-state` is called only on state change, not every tick
- `playing_arabic_audio` is recognized in the code even though the real 
  NVR never sends it (so Arabic still works once the server adds it)
- Fallback behaviour when only fr/en/default/none are received

**Station cache** — verify:
- `/data/stations-in-route/{route_id}` is called only when route_id 
  changes
- `/data/station-info/{station_id}` is called once per station per 
  route, results cached
- Cache invalidates when route_id changes mid-journey
- `is_in_reverse: true` causes the station list to be reversed 
  client-side before caching

**Arabic fallback** — verify: when `display_name_ar` is missing from 
the JSON response, the code does NOT crash. It should fall back to 
`display_name_fr` (or `display_name`) and store that as the Arabic 
value, so RTL layout still renders something readable.

**Error handling** — verify: HTTP 500, timeout, malformed JSON, and 
unreachable host all cause the stream to emit TrainState.recovery. The 
poll loop must NOT give up; it must keep retrying so the client 
auto-recovers when the NVR returns.

### Step 5 — Audit the DisplayMapper

Open lib/presentation/display_mapper.dart. Verify:

- **Priority overrides checked first**: warning, manual, and recovery 
  are evaluated BEFORE any normal state in the render logic. If they 
  appear as switch cases alongside normal states without priority, 
  that's a bug.
- **moving + coasting both route to the same screen path** (speed 
  phase, then progress phase).
- **Speed-phase timer (5 seconds)**: when state enters moving or 
  coasting, a 5-second timer starts. During those 5 seconds, 
  MovingSpeedScreen renders. After 5 seconds, MovingProgressScreen 
  renders. The timer must be cancelled if state leaves moving/coasting 
  before expiry.
- **Arrived-flash timer (3 seconds)**: edge-triggered on arriving → 
  atStation. ArrivedMessageScreen renders for exactly 3 seconds, then 
  StationScreen. Timer cancelled if state changes away from atStation 
  during those 3 seconds. The flash does NOT fire on 
  idle→atStation or routeSelected→atStation.
- **No memory leaks**: all timers are cancelled in dispose().

### Step 6 — Audit the presentation layer against UI_REDESIGN.md

Read UI_REDESIGN.md in full. Then open each screen file and verify.

For `_shared.dart`:
- All 8 design token color constants present with EXACT hex values.
- SharedHeader widget: 72px height, ONCF text + divider + trainId, 
  ClockWidget on right.
- ClockWidget: HH:MM format, colon pulses every 500ms between opacity 
  1.0 and 0.2, uses tabularFigures for fixed-width digits.
- ScreenScaffold: kBg background, SafeArea, 40px horizontal padding.
- RouteConnector: circle + line + arrow, kAccent.
- RouteProgressPainter: matches the exact implementation in 
  UI_REDESIGN.md — 6px track, 6px orange fill, dot radii 8/12/18 with 
  glow, hollow next, grey future, labels on current and next only, 
  origin/destination anchors at corners.

For each of the 9 screens (idle, route_selected, station, departing, 
moving_speed, moving_progress, arriving, arrived_message, end_of_route):

- Font sizes match the spec (e.g. StationScreen current station = 96px)
- Font weights match (w200, w400, w500, w700, w800)
- Colors used are the design tokens, not inline hex
- Padding and spacing match the spec (SizedBox heights, card padding)
- SharedHeader is present on every screen
- ScreenScaffold wraps every screen
- Bilingual labels where specified (e.g. "Gare actuelle · المحطة 
  الحالية")
- Arabic text wrapped in Directionality(rtl) where the spec requires it
- Progress bar present on StationScreen, MovingProgressScreen, and 
  EndOfRouteScreen (with progress=1.0 on end-of-route)
- Progress bar ABSENT on DepartingScreen, MovingSpeedScreen, 
  ArrivingScreen, ArrivedMessageScreen, IdleScreen, RouteSelectedScreen

Report each deviation with: file, line, what the spec says, what the 
code does.

### Step 7 — Audit the fake server (dove6_server)

Open dove6_server/. Verify the fake server response shapes match the 
real NVR contract exactly:

- Wrapped objects for single-value endpoints (e.g. `{"speed": 18.5}` 
  not `18.5`)
- Bare array for `/data/stations-in-route/{route_id}`
- UUID-style IDs for routes and stations (not human-readable like 
  "st-001" or "marrakech_tanger") — so development catches bugs that 
  would only appear in production
- `/v0` path prefix on all endpoints
- Field names match exactly: `current_state`, `audio_action`, `speed`, 
  `ratio`, `route_id`, `is_in_reverse`, `start_station_index`, 
  `display_name`, `display_name_fr`, `display_name_en`, `count`

If the fake server currently uses different shapes (as the architecture 
doc's examples did), flag every deviation.

Also verify `routes.json`:
- Structure includes bilingual station lists (fr + ar)
- Contains at least the three routes mentioned in the architecture: 
  Marrakech↔Tanger, Casa↔Fès, Casa↔Marrakech
- active_route key present

### Step 8 — Audit main.dart

Open lib/main.dart. Verify:
- Single flag `useLocalSimulation` (bool const) that switches between 
  FakeDataService and NvrDataService.
- Single constant `nvrBaseUrl` used for production URL. For local dev 
  with the fake server, it should point to `http://127.0.0.1:8080` (no 
  `/v0` — fake server is simpler). For real NVR, it should be 
  `http://<nvr_ip>:3002/v0`.
- The one-line switch principle is preserved: changing one flag and 
  one URL is the only difference between dev and prod.

### Step 9 — Produce the final report

Output a single markdown report titled `AUDIT_REPORT.md` in the repo 
root with these sections:

1. **File tree** — one line per relevant file in lib/ and 
   dove6_server/.

2. **Implemented correctly** — bullet list of what matches the three 
   references.

3. **API contract mismatches** (highest priority) — for each 
   endpoint, the bug, the file, the line, the severity.

4. **State machine and timer bugs** — priority override checks, 
   timer cancellation, edge-triggered flash.

5. **UI spec deviations** — per screen, listed as: screen file, 
   what spec says, what code does, severity.

6. **Architectural violations** — any presentation-layer or domain 
   imports that break layer separation.

7. **Fake-server shape mismatches** — everything in dove6_server/ 
   that doesn't match the real NVR shape.

8. **Missing features** — things in the three references with no 
   corresponding code.

9. **Risky patterns** — things that currently work but are likely to 
   break (timer leaks, missing null checks on optional fields like 
   display_name_ar, unhandled enum values, etc.).

10. **Top 10 recommended fixes in priority order** — what I should 
    tackle first. For each: one sentence of what and why, plus the 
    file(s) affected.

**Severity scale:**
- CRITICAL: breaks production integration with real NVR, or crashes 
  the client
- MAJOR: visible UI defect, wrong data displayed, or user-facing bug
- MINOR: cosmetic deviation, dead code, naming inconsistency

---

## HARD CONSTRAINTS

- **Do not modify any code.** Audit only.
- **Do not run `flutter run` or `flutter analyze`.** File inspection 
  only — I'll run those myself after the fix pass.
- **Read each reference in full** before writing findings. Partial 
  reading leads to false positives.
- **Cite file and line number** for every finding. Vague findings are 
  not actionable.
- **If something is ambiguous** between the three references, list it 
  in a separate "Ambiguities to resolve with architect/colleague" 
  section at the end of the report rather than guessing.