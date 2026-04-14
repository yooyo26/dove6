### Purpose
IDLE SCREEN 
The Idle screen is the default resting state displayed when no active journey is in progress.

It establishes ONCF brand presence, reassures passengers they are on the correct train, and creates a calm, welcoming atmosphere.

---

### Information Hierarchy

| Priority | Element                   | Role                          |
| -------- | ------------------------- | ----------------------------- |
| 1        | ONCF Logo                 | Institutional identity anchor |
| 2        | Organization Name         | Reinforces trust              |
| 3        | Welcome Message (FR + AR) | Emotional warmth              |
| 4        | Header Bar                | Operational context           |
| 5        | Clock                     | Utility                       |

---

### Layout Zones

#### Zone 1 — Header Bar

* Full width (~72px height)
* Left:

  * ONCF logo (48px)
  * Divider
  * Z2M · Train 204 · Voiture 3 · 1ère Classe
* Right:

  * Clock (HH:MM, pulsing colon)
* Bottom:

  * 1px subtle separator
* Padding:

  * 40px horizontal
  * 12px vertical

---

#### Zone 2 — Center Stage

* ONCF logo (112px, centered)
* Subtitle (8px below)
* Welcome message (16px below)
* Fully centered vertically and horizontally

---

#### Zone 3 — Footer (optional)

* Bottom-right
* Demo/debug only
* Removed in production

---

### Typography

| Element     | Size    | Weight      | Notes              |
| ----------- | ------- | ----------- | ------------------ |
| Clock       | 48px    | Medium      | Tabular            |
| Header Info | 16–18px | Bold/Medium | Wide spacing       |
| Subtitle    | 20px    | Medium      | Uppercase          |
| Welcome     | 30px    | Medium      | Main readable text |

---

### Colors

| Element     | Token                |
| ----------- | -------------------- |
| Background  | --pis-bg             |
| Accent      | --pis-accent         |
| Header Text | --pis-text-primary   |
| Subtitle    | --pis-text-secondary |
| Welcome     | --pis-text-tertiary  |
| Divider     | --pis-track          |

---

### Spacing & Alignment

* Full center alignment (X + Y)
* Logo → subtitle: 32px
* Subtitle → welcome: 16px
* Content block height: ~250px
* Generous negative space

---

### Emotional Tone

Peaceful · Trustworthy · Ready

The passenger should feel:
"I'm in the right place. Everything is working."

---

### Transition Behavior

* Entry: 800ms fade-in (ease-out)
* Exit: 400ms fade-out
* Clock colon: subtle pulse (3s loop)
* No other animation

---

### Accessibility

* Minimum text: 20px
* High contrast (WCAG AA+)
* Bilingual FR + AR (equal importance)
* Readable at 5m distance
* Warm background avoids eye fatigue

## 6.2 Route Selected Screen

### Purpose

Displayed immediately after a route is activated, confirming the **origin and destination** to all passengers.

This is the first active journey screen and must deliver clarity in under 2 seconds.

A passenger should instantly understand:
*"Where this train goes."*

---

### Information Hierarchy

| Priority | Element             | Role                  |
| -------- | ------------------- | --------------------- |
| 1        | Origin station      | Start point           |
| 2        | Destination station | End point             |
| 3        | Direction connector | Travel flow           |
| 4        | Arabic subtitles    | Bilingual inclusivity |
| 5        | Context label       | Screen identification |
| 6        | Stop count          | Journey scope         |
| 7        | Header              | Persistent context    |

---

### Layout Zones

#### Zone 1 — Header Bar

* Same as Idle screen
* ONCF logo + Train info + Clock
* Fixed height (~72px)

---

#### Zone 2 — Context Label

* Text: "Itinéraire · المسار"
* Centered
* Uppercase, tracked
* Muted color
* Margin-bottom: 32px

---

#### Zone 3 — Center Stage

Three-column horizontal layout (max-width: 1024px)

| Left                   | Center    | Right                      |
| ---------------------- | --------- | -------------------------- |
| Origin (right-aligned) | Connector | Destination (left-aligned) |
| Arabic subtitle        |           | Arabic subtitle            |

---

### Connector Structure

```text
● ——→
```

* Dot (origin)
* Line (route)
* Arrow (direction)

---

### Typography

| Element          | Size | Weight | Alignment                  |
| ---------------- | ---- | ------ | -------------------------- |
| Station names    | 60px | Bold   | Origin: right / Dest: left |
| Arabic subtitles | 24px | Medium | Match parent               |
| Context label    | 18px | Medium | Center                     |
| Stop count       | 24px | Medium | Center                     |

---

### Colors

| Element          | Token                |
| ---------------- | -------------------- |
| Background       | --pis-bg             |
| Station names    | --pis-text-primary   |
| Arabic subtitles | --pis-text-tertiary  |
| Context label    | --pis-text-secondary |
| Stop count       | --pis-text-secondary |
| Connector accent | --pis-accent         |
| Connector base   | --pis-track          |

---

### Spacing & Alignment

* Context → stations: 32px
* Station → Arabic: 8px
* Columns gap: 32px
* Stations → stop count: 40px

Connector:

* Line width: 144px
* Line height: 6px
* Dot: 16px
* Arrow: 28px
* Internal gap: 12px

All elements aligned on vertical midline.

---

### Emotional Tone

Clarity · Confidence · Direction

Passenger feeling:
*"Yes, this train goes where I need."*

---

### Transition Behavior

* Idle → Route Selected:

  * 400ms fade-out
  * 800ms fade-in

* Duration:

  * ~4 seconds

* Exit:

  * 400ms fade-out

No internal animation.

---

### Accessibility

* Station names readable at 5–8 meters
* No color dependency (arrow defines direction)
* Bilingual parity (FR + AR)
* Minimal cognitive load

---

### Production Notes

* Station names must not wrap
* Use ellipsis if too long
* Columns are flexible (flex-1)
* Connector is fixed-width and centered
* Connector is fully filled (100% progress visual)


## 6.3 At Station (Boarding) Screen

### Purpose

Displayed when the train is **stopped at a station with doors open**.

This is the most critical screen for **boarding passengers**, answering instantly:

* Where am I?
* Where is this train going?
* How far along is the journey?

---

### Information Hierarchy

| Priority | Element                 | Role                   |
| -------- | ----------------------- | ---------------------- |
| 1        | Current station         | Primary identity       |
| 2        | Arabic station          | Bilingual confirmation |
| 3        | Direction + destination | Travel intent          |
| 4        | Mini route map          | Journey position       |
| 5        | Context label           | Screen identity        |
| 6        | Header                  | Persistent context     |

---

### Layout Zones

#### Zone 1 — Header Bar

* Same as all screens (~72px)
* ONCF logo, Z2M, train info, clock

---

#### Zone 2 — Context Label

* Text: "Gare actuelle · المحطة الحالية"
* Centered
* Muted, uppercase
* Margin-bottom: 16px

---

#### Zone 3 — Station Identity

* Current station name (96px, largest in system)
* Arabic name below (30px)
* Centered
* Margin-bottom: 40px

---

#### Zone 4 — Direction Callout

* Rounded card container
* Horizontal layout:

```text
Direction → → Destination
```

* Destination highlighted (accent color)

---

#### Zone 5 — Mini Route Map

* Horizontal node-based diagram
* Shows full route
* Current node highlighted
* Passed vs future differentiated

---

### Typography

| Element         | Size | Weight | Alignment |
| --------------- | ---- | ------ | --------- |
| Station         | 96px | Bold   | Center    |
| Arabic          | 30px | Medium | Center    |
| Context         | 18px | Medium | Center    |
| Direction label | 24px | Medium | Left      |
| Destination     | 30px | Bold   | Right     |

---

### Colors

| Element     | Token                |
| ----------- | -------------------- |
| Background  | --pis-bg             |
| Station     | --pis-text-primary   |
| Arabic      | --pis-text-tertiary  |
| Context     | --pis-text-secondary |
| Destination | --pis-accent         |
| Card bg     | --pis-surface        |
| Arrow       | --pis-accent         |

Mini map:

* Current node: accent
* Passed nodes: muted
* Future nodes: neutral
* Passed line: accent
* Future line: track

---

### Spacing & Alignment

* Context → station: 16px
* Station → Arabic: 12px
* Arabic → card: 40px
* Card → route map: 40px

Mini map:

* Node sizes: 20px (current), 12px others
* Segment width: 40px
* Segment height: 4px
* All elements aligned on same horizontal axis

---

### Emotional Tone

Welcoming · Structured · Orienting

Passenger feeling:

"I'm in the right train, I know where I'm going."

---

### Transition Behavior

* Route Selected → At Station:

  * 400ms fade-out
  * 800ms fade-in

* Duration: ~4 seconds

* Exit: 400ms fade-out

* No animation (static clarity)

---

### Accessibility

* Station readable from 8+ meters

* Multi-layer reading:

  * glance: station
  * look: station + destination
  * study: route map

* No color-only logic (size + position used)

* Bilingual parity

---

### Production Notes

* Station names must not wrap
* Scale down if needed (96px → 84px)
* Route map geometry is fixed
* Nodes do not shift positions
* Edge case: if current = destination → skip to End screen


## 6.4 Moving — Speed View

### Purpose

A dynamic ambient screen communicating the train's current speed.

It provides a **simple, reassuring signal of motion** without requiring cognitive effort.

Passenger feeling:
*"We are moving normally."*

---

### Information Hierarchy

| Priority | Element              | Role                 |
| -------- | -------------------- | -------------------- |
| 1        | Speed value          | Dominant information |
| 2        | Unit (km/h)          | Context              |
| 3        | Next station callout | Forward awareness    |
| 4        | Context label        | Screen identity      |
| 5        | Header               | Persistent context   |

---

### Layout Zones

#### Zone 1 — Header Bar

* Same as all screens (~72px)

---

#### Zone 2 — Context Label

* "Vitesse · السرعة"
* Centered, muted
* Margin-bottom: 16px

---

#### Zone 3 — Speed Display

* Speed value (160px, ultra-large)
* Unit "km/h" baseline-aligned
* Centered vertically

---

#### Zone 4 — Next Station Callout

* Rounded surface card
* Layout:

```text
Prochain arrêt → [Station Name]
```

---

### Typography

| Element       | Size  | Weight      |
| ------------- | ----- | ----------- |
| Speed         | 160px | Light (300) |
| Unit          | 30px  | Light       |
| Context       | 18px  | Medium      |
| Callout label | 24px  | Medium      |
| Station name  | 30px  | Bold        |

---

### Colors

| Element      | Token               |
| ------------ | ------------------- |
| Speed        | --pis-text-primary  |
| Unit         | --pis-text-tertiary |
| Callout bg   | --pis-surface       |
| Arrow        | --pis-accent        |
| Station name | --pis-accent        |

---

### Spacing & Alignment

* Context → speed: 16px
* Speed → callout: 48px
* Center aligned
* Baseline alignment between number and unit

---

### Emotional Tone

Dynamic · Calm · Reassuring

---

### Transition Behavior

* Entry: 800ms fade-in
* Duration: ~4s
* Exit: 400ms fade-out
* Speed updates: instant (no animation)

---

### Accessibility

* Single data point → zero cognitive load
* Large typography → readable at distance
* No color dependency

---

---

## 6.5 Moving — Progress View

### Purpose

The primary long-duration screen.

Provides a **complete spatial model of the journey**:

* where the train has been
* where it is now
* what comes next

Passenger feeling:
*"I know exactly where I am."*

---

### Information Hierarchy

| Priority | Element                 | Role               |
| -------- | ----------------------- | ------------------ |
| 1        | Progress bar            | Main visual        |
| 2        | Current station         | Position anchor    |
| 3        | Next station            | Actionable info    |
| 4        | Station labels          | Context            |
| 5        | Direction + destination | Confirmation       |
| 6        | Arabic labels           | Bilingual support  |
| 7        | Header                  | Persistent context |

---

### Layout Zones

#### Zone 1 — Header Bar

* Same as all screens (~72px)

---

#### Zone 2 — Direction Label

* Destination highlighted
* Margin-bottom: 40px

---

#### Zone 3 — Progress Bar (CORE COMPONENT)

##### Track Line

* Full-width (max 1100px)
* Height: 4px
* Base: grey
* Progress fill: orange (left → right)

---

##### Station Nodes

* Positioned evenly across the line
* Perfect alignment on line axis

Node types:

* Current: 24px, accent, glow
* Passed: 16px, muted
* Future: 16px, outlined

---

##### Station Labels

* Centered under nodes
* Arabic only for current + next

---

#### Zone 4 — Next Station Callout

* Surface card
* Layout:

```text
Prochain arrêt | Station Name
```

---

### Typography

| Element         | Size | Weight |
| --------------- | ---- | ------ |
| Direction       | 18px | Medium |
| Destination     | 30px | Bold   |
| Current station | 20px | Bold   |
| Next station    | 18px | Bold   |
| Other stations  | 14px | Medium |
| Arabic          | 16px | Medium |
| Callout station | 36px | Bold   |

---

### Colors

| Element       | Token             |
| ------------- | ----------------- |
| Track base    | --pis-track       |
| Progress fill | --pis-accent      |
| Current node  | --pis-accent      |
| Passed nodes  | muted             |
| Future nodes  | outlined          |
| Labels        | varying hierarchy |
| Callout bg    | --pis-surface     |

---

### Spacing & Alignment

* Direction → bar: 40px
* Bar height: 130px
* Node spacing: equal distribution
* Node alignment: EXACT center on line axis
* Labels below nodes: 24px gap
* Bar → callout: 16px

---

### Critical Alignment Rule

All nodes MUST satisfy:

```text
node_center_y == track_center_y
```

No offset allowed.

---

### Emotional Tone

Precise · Engineered · Satisfying

---

### Transition Behavior

* Entry: 800ms fade-in
* Duration: 5–6s
* Progress animation: smooth width transition (1s)
* Current node glow: subtle pulse (2s loop)
* Exit: 400ms fade-out

---

### Accessibility

* Multi-distance readability
* Shape + size + color encoding
* Redundant next-station display
* Minimal text clutter

---

### Production Notes

* Progress = real distance ratio (not station index)
* Node spacing must remain constant
* Long station names may require scaling or staggering
* Arabic labels limited to key stations
* Design optimized for 5–9 station routes


## 6.6 Arriving Screen

### Purpose

Displayed shortly before reaching the destination.

Its role is to **capture attention** and prepare passengers to disembark.

Passenger feeling:
*"My stop is coming — I need to get ready."*

---

### Information Hierarchy

| Priority | Element             | Role                   |
| -------- | ------------------- | ---------------------- |
| 1        | Destination station | Primary focus          |
| 2        | Arabic name         | Bilingual confirmation |
| 3        | "Arrivée · الوصول"  | Context label          |
| 4        | Header              | Persistent context     |

---

### Layout Zones

#### Zone 1 — Header Bar

* Same as all screens (~72px)

---

#### Zone 2 — Context Label

* "ARRIVÉE · الوصول"
* Centered
* Small accent divider above
* Margin-bottom: 16px

---

#### Zone 3 — Destination Display

* Destination name (very large, ~80–96px)
* Arabic name below (~30px)
* Centered vertically and horizontally

---

### Typography

| Element     | Size    | Weight |
| ----------- | ------- | ------ |
| Destination | 80–96px | Bold   |
| Arabic      | 30px    | Medium |
| Context     | 18px    | Medium |

---

### Colors

| Element         | Token               |
| --------------- | ------------------- |
| Destination     | --pis-text-primary  |
| Arabic          | --pis-text-tertiary |
| Accent dividers | --pis-accent        |

---

### Spacing & Alignment

* Divider → label: 12px
* Label → destination: 16px
* Destination → Arabic: 12px
* Perfect center alignment

---

### Emotional Tone

Attention · Clarity · Anticipation

---

### Transition Behavior

* Entry: 800ms fade-in
* Duration: ~3–4s
* Exit: fade to At Station (arrival state)

---

### Accessibility

* Very large typography
* Minimal content
* Instant readability

---

---

## 6.7 Arrived / Welcome Screen

### Purpose

Displayed when the train has reached the station and doors are open.

Acts as a **friendly confirmation + welcome message**.

Passenger feeling:
*"We have arrived. Welcome."*

---

### Information Hierarchy

| Priority | Element         | Role                 |
| -------- | --------------- | -------------------- |
| 1        | Station name    | Primary confirmation |
| 2        | Arabic name     | Bilingual support    |
| 3        | Welcome message | Emotional tone       |
| 4        | Header          | Context              |

---

### Layout Zones

#### Zone 1 — Header Bar

* Same as all screens

---

#### Zone 2 — Context Label

* "BIENVENUE · مرحبا"
* Centered
* Margin-bottom: 16px

---

#### Zone 3 — Station Display

* Station name (accent color)
* Arabic name below
* Welcome sentence below

---

### Typography

| Element      | Size    | Weight |
| ------------ | ------- | ------ |
| Station      | 80–96px | Bold   |
| Arabic       | 30px    | Medium |
| Welcome text | 24–30px | Medium |

---

### Colors

| Element      | Token                |
| ------------ | -------------------- |
| Station      | --pis-accent         |
| Arabic       | --pis-text-tertiary  |
| Welcome text | --pis-text-secondary |

---

### Spacing

* Label → station: 16px
* Station → Arabic: 12px
* Arabic → message: 16px

---

### Emotional Tone

Warm · Friendly · Human

---

### Transition Behavior

* Entry: smooth fade-in
* Duration: ~4–5s
* Exit: loop or move to Idle / next route

---

### Accessibility

* Clear hierarchy
* Large readable text
* Calm layout

---

---

## 6.8 End of Route Screen

### Purpose

Final state of the journey.

Confirms completion and gently reminds passengers to exit.

Passenger feeling:
*"Journey complete — time to leave safely."*

---

### Information Hierarchy

| Priority | Element            | Role         |
| -------- | ------------------ | ------------ |
| 1        | Final station      | Confirmation |
| 2        | Completion message | Instruction  |
| 3        | Header             | Context      |

---

### Layout

* Same structure as Arrived screen
* Additional safety/reminder text

---

### Example Message

* "Terminus — Merci de votre voyage"
* "المرجو التأكد من عدم نسيان أمتعتكم"

---

### Emotional Tone

Closure · Safety · Satisfaction

---

### Notes

* Should feel like a **closing scene**
* No dynamic elements
* Calm, respectful exit experience
