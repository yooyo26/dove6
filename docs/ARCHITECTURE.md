# ARCHITECTURE — Dove6 Passenger Information Display System

**Project:** Dove6 — On-board Passenger Information Display
**Organisation:** AVIARAIL — Z2M Rail Renovation Programme
**Author:** Ayoub Nahji — Engineering Intern, ENSA Tanger
**Date:** April 2026
**Document type:** Technical Architecture Reference — Mémoire de Fin d'Études

---

## Section 1 — Project Summary

Morocco's national rail operator, the Office National des Chemins de Fer (ONCF), operates a fleet of intercity trains across the kingdom. Among these, the Z2M is a series of diesel multiple-unit trainsets that run on regional and intercity lines, connecting major cities including Marrakech, Casablanca, Rabat, Kénitra, and Tanger. These trains carry thousands of passengers every day, yet many of them travel without reliable access to real-time information about where the train currently is, which station is coming next, how far the journey has progressed, or what language the on-board announcements are being made in. This absence of clear, visible information is not a minor inconvenience — for passengers unfamiliar with the route, for travellers arriving from abroad, or for people with hearing difficulties who cannot rely on spoken announcements, it is a genuine barrier to using the rail network with confidence.

AVIARAIL is a technical company engaged in a systematic renovation programme for the Z2M fleet. The renovation programme, known internally as Z2M, covers multiple aspects of the trainset: mechanical, electrical, and digital. On the digital side, the programme installs a modern on-board computer system into each trainset. The central device in this system is the R6S Lanner, a rugged industrial computing unit known as an NVR (Network Video Recorder and processing unit). The R6S Lanner is mounted inside the train and acts as the train's digital brain: it reads data from physical sensors attached to the train, processes that data, and makes it available to other systems over a local network connection. It knows the train's current speed, its position on the route relative to the stations, the total number of passengers on board, and the current state of the journey (whether the train is moving, stopped at a station, or arriving at one). One of the systems that consumes data from the R6S Lanner is the passenger information display — the screen that passengers look at to understand what is happening with their journey.

The old system on the Z2M trainsets, where one existed at all, consisted of simple static signs or, at best, a basic LED matrix showing scrolling text. These displays required manual updating, were unreliable, displayed only one language, and could not adapt to the real-time state of the train. They were designed for a previous era of rail operation and are no longer adequate for the expectations of modern passengers or the operational standards of a renovated fleet. Beyond their functional limitations, they presented no design coherence and communicated the minimum possible information in the least clear possible way.

The Dove6 system replaces these legacy displays entirely. It consists of two software components: a server application running on the R6S Lanner that reads sensor data and exposes it through a standardised network interface, and a display application running on a dedicated screen mounted in the passenger cabin. The display application reads data from the server every second and renders the appropriate screen for the current state of the journey. It shows the current station, the next station, the speed, the progress along the route, a visual map of all stations on the line, and bilingual content in French and Arabic that synchronises automatically with the on-board audio announcements. Every passenger in the carriage — regardless of whether they speak French, Arabic, are hearing-impaired, or simply unfamiliar with the Moroccan rail network — benefits from seeing exactly where the train is and where it is going, at all times.

---

## Section 2 — System Overview

The Dove6 system is composed of several physical hardware components and two software applications. Understanding how these pieces connect to each other is the foundation for understanding how the system works.

```
  PHYSICAL TRAIN HARDWARE
  ─────────────────────────────────────────────────────────────────────

  [GPS Sensor]          [Speed Sensor]        [PCN Eurotechnic 1001]
       │                      │                         │
       │  position data        │  speed in km/h          │  passenger count
       └──────────────────────┴─────────────────────────┘
                              │
                              ▼
                   ┌──────────────────────┐
                   │    R6S Lanner NVR    │
                   │   (On-board Brain)   │
                   │                      │
                   │  dove6_server (Go)   │
                   │  Port 8080           │
                   └──────────┬───────────┘
                              │
                   HTTP over local network
                   (1 second polling interval)
                              │
                              ▼
                   ┌──────────────────────┐
                   │  Aeon Gene BT06      │
                   │  (Display Screen)    │
                   │                      │
                   │  dove6_client        │
                   │  (Flutter / Ubuntu)  │
                   └──────────────────────┘
                              │
                              ▼
                   Passenger sees current screen
```

**R6S Lanner NVR** — A rugged industrial computer mounted inside the train. It reads data from all physical sensors, determines the operational state of the journey, and runs the dove6_server application that makes all this information available to the display over the local network.

**GPS Sensor** — A satellite positioning receiver attached to the train. It provides the train's geographic location, which the NVR uses to determine which station the train is approaching and how far along the route it has travelled.

**Speed Sensor** — A physical sensor on the wheels or axle of the train. It measures the rotational speed of the wheel and converts it into a speed in kilometres per hour. The NVR reads this value and passes it to the display.

**PCN Eurotechnic 1001** — A passenger counting device installed at the train doors. It uses infrared beams to detect passengers entering and exiting the carriage and provides the NVR with a real-time count of how many people are on board.

**Aeon Gene BT06** — A compact embedded computing board with a connected display screen, mounted in the passenger cabin. It runs the Ubuntu Linux operating system and executes the dove6_client application. Passengers look at the screen attached to this board.

**dove6_server (Go application)** — A lightweight HTTP server written in the Go programming language. It runs on the R6S Lanner, reads from the NVR's internal data bus, and responds to requests from the display application. During development, it runs on a laptop and simulates a complete train journey using a scripted sequence of steps.

**dove6_client (Flutter application)** — A graphical application written using the Flutter framework. It runs on the Aeon Gene BT06, polls the server every second, and renders the appropriate screen based on the current state of the journey. This is the software that passengers directly interact with — or rather, look at.

The two software components communicate over a standard HTTP network connection using a defined API contract — a shared language that both sides must agree on. The display application sends a request to the server, the server responds with data in a structured JSON format (a plain-text format for transmitting structured data), and the display application interprets that data and renders the correct screen. This communication happens automatically once per second without any human intervention.

---

## Section 3 — The State Machine

A state machine is a model used in engineering to describe a system that can only be in one condition at a time, where specific events cause it to transition from one condition to another. Think of a traffic light: it can be green, amber, or red, and it transitions between these states in a defined order. It is never in two states at once, and it cannot jump from red directly to amber without going through green. A state machine makes a system predictable and safe because every possible situation is named and its rules are explicit.

The Dove6 system uses a state machine with eleven states to model the complete lifecycle of a train journey. At any given moment, the train is in exactly one of these states, and the display application renders the screen that corresponds to that state.

```
  STATE MACHINE — DOVE6 JOURNEY LIFECYCLE
  ─────────────────────────────────────────────────────────────────────

         ┌─────────────────────────────────────────────┐
         │              PRIORITY OVERRIDES              │
         │  WARNING ──── MANUAL ──── RECOVERY           │
         │  (These interrupt the journey at any point)  │
         └─────────────────────────────────────────────┘

                              │
                              ▼

  ┌──────────┐    ┌───────────────────┐    ┌──────────────┐
  │  IDLE    │───▶│  ROUTE SELECTED   │───▶│  AT STATION  │
  └──────────┘    └───────────────────┘    └──────┬───────┘
                                                  │
                                                  ▼
                                          ┌──────────────┐
                                          │  DEPARTING   │
                                          └──────┬───────┘
                                                 │
                                                 ▼
                                          ┌──────────────┐
                                          │   MOVING     │◀──┐
                                          │  (2 phases)  │   │
                                          └──────┬───────┘   │
                                                 │           │
                                                 ▼           │
                                          ┌──────────────┐   │
                                          │  ARRIVING    │   │
                                          └──────┬───────┘   │
                                                 │           │
                                                 ▼           │
                                          ┌──────────────┐   │
                                          │  AT STATION  │───┘
                                          └──────┬───────┘   (repeats for
                                                 │            each stop)
                                                 ▼
                                          ┌──────────────┐
                                          │ END OF ROUTE │
                                          └──────────────┘
```

**The eleven states in detail:**

**1. idle**
What is happening on the train: The train is at rest and no route has been selected yet. The system is active but no journey is in progress.
What the passenger sees: The current time and date displayed in large numerals, a welcome message ("Bienvenue à bord" in French), and the ONCF identification. This is the neutral waiting screen.

**2. routeSelected**
What is happening on the train: The operator has just selected the route for this journey. The system has loaded the list of stations and confirmed the origin and destination. The train has not yet departed.
What the passenger sees: A confirmation that the route has been loaded, showing the origin and destination. This screen primarily serves as an operator confirmation that the correct route was activated before departure.

**3. atStation**
What is happening on the train: The train is stopped at a station. Doors may be open. Passengers are boarding and alighting.
What the passenger sees: The name of the current station in large text, the name of the next station, and the name of the final destination. The route progress bar at the bottom shows the train's position on the overall journey.

**4. departing**
What is happening on the train: The train has closed its doors and is beginning to move away from the station. Speed is low and increasing.
What the passenger sees: The name of the station being departed from, the next stop, and a departure indication. The screen confirms to seated passengers which station was just served.

**5. moving** (with two visual phases)
What is happening on the train: The train is travelling between stations at cruising speed.
What the passenger sees: For the first five seconds after entering this state, the screen shows the current speed in large numerals — a dramatic, clean presentation that communicates that the train is moving at full speed. After five seconds, the screen transitions to the progress view: the route map with all station dots, the current station name, the next station name, a station counter, and proximity dots indicating how close the train is to the next stop.

**6. coasting**
What is happening on the train: The train is in a coasting phase — the engines are at reduced power and the train is decelerating naturally before approaching a station. Electrically distinct from full-speed moving, but visually identical from the passenger's perspective.
What the passenger sees: The same progress screen as the moving state. The display mapper treats coasting identically to moving.

**7. arriving**
What is happening on the train: The train is actively slowing down as it approaches the next station. Brakes are applied. Speed is falling from cruising speed towards zero.
What the passenger sees: The name of the station being approached in large orange text, along with the route progress bar and the final destination reminder. The screen communicates anticipation — the next stop is imminent.

**8. atStation** (arrival flash — a timed sub-state)
What is happening on the train: The train has just stopped at a station, transitioning from the arriving state.
What the passenger sees: For exactly three seconds, the display shows a large arrival confirmation message — "Arrivée à [station name]" — before transitioning to the standard at-station screen. This brief flash is a deliberate design choice: it gives passengers a clear, unambiguous confirmation that the correct station has been reached.

**9. endOfRoute**
What is happening on the train: The train has reached its final destination. The journey is complete.
What the passenger sees: A thank-you message ("Merci de voyager avec nous"), the name of the terminal station in orange, and the route progress bar showing all station dots in orange — every dot filled, the entire journey completed.

**10. warning** (priority override)
What is happening on the train: An operational alert condition has been triggered. This could be a door fault, a sensor error, or any condition the NVR classifies as requiring attention.
What the passenger sees: A full-screen alert with a warning icon and the text "WARNING — Operational alert, stand by." This screen interrupts any other screen immediately and remains until the condition clears.

**11. manual** (priority override)
What is happening on the train: The train has been placed under manual control. Automatic journey progression has been suspended.
What the passenger sees: A full-screen notice with an icon and the text "MANUAL MODE — Train under manual control." This informs passengers that automatic information is temporarily suspended.

**12. recovery** (priority override)
What is happening on the train: The display application has lost its connection to the NVR server. Network communication has failed.
What the passenger sees: A full-screen notice with a reconnecting icon and the text "CONNECTION LOST — Attempting to reconnect." The application continues polling the server every second and will restore normal operation as soon as the connection is re-established.

The three priority states — warning, manual, and recovery — override all other states regardless of the journey phase. They are checked first in the display logic before any normal state is evaluated. This design decision ensures that safety-critical or connectivity-critical conditions are always visible and can never be masked by normal operational screens.

---

## Section 4 — The Server (dove6_server)

The dove6_server is a small HTTP server written in the Go programming language. An HTTP server is a program that listens for requests on a network address and responds with data when asked — the same basic mechanism that makes web pages work, but here the "pages" are structured data packets rather than visual content. The display application is the only client of this server; no human ever opens a web browser and navigates to it in normal operation.

During development, the dove6_server runs on a laptop and simulates a complete train journey step by step, automatically advancing through each moment of the journey every fifteen seconds. This allows the display application to be developed, tested, and demonstrated without needing to be physically on a train. In production, the same server — or its equivalent written by the colleague responsible for the NVR backend — runs on the R6S Lanner computer inside the train, reading from real sensors instead of a simulated script.

**The nine HTTP endpoints:**

**GET /running-state**
Returns the current operational state of the train as a string, for example "operating_state_atstation" or "operating_state_moving". The display application polls this endpoint every second. When the state changes, the display transitions to the appropriate screen. This is the primary heartbeat of the entire system — if this endpoint stops responding, the display enters the recovery state.

**GET /audio-state**
Returns the current audio action as a string, for example "playing_french_audio" or "playing_arabic_audio". The display application calls this endpoint only when the state changes, not every second. The response tells the display application which language the on-board speaker is currently announcing in, so the screen can switch to match. This is the mechanism behind bilingual synchronisation.

**GET /data/speed**
Returns the current speed of the train in kilometres per hour as a number. The display application polls this every second. The value is shown in the header of most screens and displayed prominently in the speed phase of the moving screen.

**GET /data/distance-ratio**
Returns the train's progress along the current route as an integer between 0 and 100, representing a percentage. The display application divides this by 100 to obtain a decimal between 0.0 and 1.0. This value drives the proximity dots in the information panel and the general progress state. It is polled every second.

**GET /data/current-route**
Returns a JSON object containing the route identifier, a flag indicating whether the train is travelling in reverse, and the index of the current station within the route. The display application calls this endpoint whenever a poll cycle runs, but only reloads the full station list if the route identifier has changed since the last call. This avoids unnecessary data fetching on every second.

**GET /data/stations-in-route/{route_id}**
Returns a list of station identifiers for a given route, for example ["st-001", "st-002", "st-003", ...]. The display application calls this when it first learns a route identifier, or when the route identifier changes. The identifiers in this list are then used to call the station-info endpoint for each station.

**GET /data/station-info/{station_id}**
Returns the display names for a single station in multiple languages. For example, for station "st-001" it might return: display_name "marrakech", display_name_fr "Marrakech", display_name_ar "مراكش". The display application calls this once for each station when a route is first loaded, building a complete bilingual list of all station names for the route.

**GET /sensors/human-counter**
Returns the current passenger count as reported by the PCN Eurotechnic 1001 counting device. The display application stores this value in the DisplayData snapshot. It is available for future screens but is not yet prominently displayed in the current version.

**GET /health**
Returns a simple confirmation that the server is running: {"status":"ok","server":"dove6_server"}. The display application can call this on startup to verify connectivity before beginning normal polling. Useful during commissioning and troubleshooting.

**GET /jump?step=N** (development only)
Immediately sets the server's current journey step to step number N. This endpoint is only used during development and demonstrations. By opening a web browser on the same machine and typing "http://localhost:8080/jump?step=14", a developer can instantly jump to the fourteenth step of the journey to test a specific screen without waiting for the automatic progression. This endpoint does not exist on the real NVR and will not be present in production.

**The routes.json system:**

The server does not have any route information compiled into its code. Instead, when it starts, it reads a file called routes.json from the same folder. This file contains a list of all available routes, each with its name, destination, and the full bilingual list of stations in French and Arabic. One key in the file, called "active_route", tells the server which route to use for this session.

This design means that adding a new route, or changing which route is active, requires only editing this text file — no programming knowledge and no code recompilation are needed. An operator or a technician can configure the server before departure by changing one line in routes.json. The current file contains three routes: Marrakech to Tanger Ville (18 stations), Casa Voyageurs to Fès (7 stations), and Casa Voyageurs to Marrakech (4 stations). Any number of additional routes can be added in the same format.

**The journey simulation script:**

The scripted journey in the development server is defined as a sequence of steps in the journer.go file. Each step represents one moment in the journey: a specific state, a current station, a next station, a speed, a progress ratio, a message, and an audio language. The server automatically advances to the next step every fifteen seconds, cycling through the entire journey from idle through to end of route and back to idle. The steps cover every transition: idle waiting, route selected, stopped at each of the 18 stations, departing each station, two moving steps between each pair of stations (one at lower speed, one at cruising speed), arriving at each station, and finally the end of route. The full simulated journey from Marrakech to Tanger Ville is represented by over 70 steps.

---

## Section 5 — The Display Application (dove6_client)

Flutter is a software development framework created by Google that allows a single codebase to produce applications that run natively on multiple platforms — desktop, mobile, and web — without modification. For this project, Flutter was used to build a Linux desktop application that runs on Ubuntu Linux on the Aeon Gene BT06 screen hardware.

Flutter was chosen for three reasons. First, it produces applications that run entirely on the device without requiring a web browser — the application is compiled to native machine code, which means it is fast, reliable, and does not depend on any internet connectivity beyond the local train network. Second, its rendering system gives precise, pixel-level control over every visual element, which is essential for designing a display that must be legible from a distance and adhere to a strict design language. Third, the layer-based architecture that Flutter encourages — separating data from logic from presentation — maps directly onto the engineering principles used in this project.

**The three architectural layers:**

```
  DATA FLOW — FROM SERVER TO SCREEN
  ─────────────────────────────────────────────────────────────────────

  R6S Lanner NVR                      dove6_client (Flutter)
  ─────────────                        ─────────────────────

  HTTP endpoints                       DATA LAYER
  (/running-state)    ──HTTP poll──▶   NvrDataService
  (/data/speed)                        (polls every 1 second,
  (/data/distance-ratio)               fetches station names,
  (/audio-state)                       parses states)
  (/data/current-route)                      │
  (/data/station-info/:id)                   │ emits DisplayData
                                             ▼
                                       DOMAIN LAYER
                                       DisplayData (snapshot)
                                       TrainState (enum)
                                       (pure data — no logic,
                                        no network, no UI)
                                             │
                                             │ stream
                                             ▼
                                       PRESENTATION LAYER
                                       DisplayMapper
                                       (decides which screen
                                        to show, handles timers)
                                             │
                                             ▼
                                       Screen Widgets
                                       (IdleScreen,
                                        StationScreen,
                                        MovingProgressScreen,
                                        etc.)
                                             │
                                             ▼
                                       Aeon Gene BT06 screen
                                       (what the passenger sees)
```

**Domain layer** — This layer contains the data structures that the rest of the application uses. The two most important are TrainState, an enumeration of the eleven possible journey states, and DisplayData, a snapshot object that contains every piece of information any screen might need: the current station name in French and Arabic, the next station, the destination, the speed, the progress ratio, the full list of stations on the route in both languages, the audio language, and a timestamp. The domain layer contains no network code, no rendering code, and no logic — it is purely data definitions. This separation means that the domain model can be tested, inspected, and reasoned about in complete isolation from how data is fetched or how it is displayed.

**Data layer** — This layer is responsible for obtaining data from the outside world and translating it into the domain types. It contains an abstract interface called DataService, which defines a contract: any data source must provide a stream of DisplayData objects and must implement start and dispose methods. Two concrete implementations exist. FakeDataService runs entirely within the application using a scripted sequence of states — it requires no server and is used for isolated development. NvrDataService connects to the real NVR server over HTTP, polls all the relevant endpoints every second, manages the station list cache, handles errors by emitting a recovery state, and maps all the NVR string values ("operating_state_atstation") into the proper TrainState enumeration values.

**Presentation layer** — This layer is responsible entirely for what the passenger sees. It contains the DisplayMapper, a component that subscribes to the DataService stream and decides which screen to render based on the current state. It also manages two timers: one that switches from the speed phase to the progress phase after five seconds of being in the moving state, and one that shows the arrived-message flash screen for three seconds when transitioning from arriving to atStation. Below the DisplayMapper are the individual screen widgets — one per state — each of which receives a DisplayData snapshot and a boolean indicating whether to display Arabic, and renders the appropriate visual content. No screen widget contains any logic, any network code, or any state management. They are purely visual.

**The DataService abstraction and why it matters:**

The DataService interface is defined as three lines: a data stream, a start method, and a dispose method. Every other component in the application depends only on this interface, never on a specific implementation. The consequence of this design is that switching from the fake server to the real NVR requires changing exactly one line in main.dart — the line that instantiates the service. Everything else in the application is completely unchanged. When the colleague finishes the real NVR backend, the integration is not a migration or a refactoring effort: it is a one-line change and a test.

---

## Section 6 — The Screens

**Screen 1 — IdleScreen**
Appears when: TrainState.idle — the train is at rest with no route selected.
What the passenger sees: The current time in large light numerals (80px), the full date below it, a welcome message "Bienvenue à bord" in the lower portion of the screen, and the ONCF identification text. This screen communicates that the system is active and the journey has not yet begun. The time display was chosen because idle waiting is the one moment passengers most benefit from a clear clock.

**Screen 2 — RouteSelectedScreen**
Appears when: TrainState.routeSelected — a route has been selected and the train is about to depart.
What the passenger sees: A confirmation display showing the selected route with its origin and destination, and the complete list of stations. This screen is primarily a technical confirmation for the operator and for observant passengers that the correct journey has been loaded into the system. It appears only briefly before departure and establishes the journey's context.

**Screen 3 — StationScreen**
Appears when: TrainState.atStation — the train is stopped at an intermediate station (not the final destination).
What the passenger sees: The name of the current station in the largest text on the screen (48px, bold), the name of the next station in orange below a divider, the final destination reminder, and the route progress bar showing all stations with the current position highlighted. This is the screen passengers most need: a clear answer to "where are we?" A stopped train means they have time to read, so the information density is moderate.

**Screen 4 — ArrivedMessageScreen** (timed flash)
Appears when: Transitioning from TrainState.arriving to TrainState.atStation, for exactly three seconds.
What the passenger sees: A large, centred arrival confirmation — "Arrivée à [station name]" — filling the screen. This brief flash is deliberate: the arriving screen shows the destination approach, and there is a moment of ambiguity when the train stops as to whether it has reached the correct station or stopped unexpectedly. The flash resolves that ambiguity instantly. After three seconds it dissolves into the standard StationScreen.

**Screen 5 — DepartingScreen**
Appears when: TrainState.departing — the train has closed its doors and is beginning to move.
What the passenger sees: The name of the station being departed, the name of the next station, and a departure status indicator. This screen covers the transitional moment when the train is leaving and passengers may still be settling into their seats. It reinforces the journey context before the train reaches cruising speed.

**Screen 6 — MovingSpeedScreen**
Appears when: TrainState.moving or TrainState.coasting, for the first five seconds after entering that state.
What the passenger sees: The current speed in very large numerals (100px or larger), centred on the screen, with "km/h" in smaller text beside it, and a subtle reference to the next station. This is the most dramatic screen in the system. The large speed number captures attention at the moment passengers most want to know — how fast is this train going? The five-second duration is long enough to be readable from across the carriage, and short enough that it does not overstay its welcome.

**Screen 7 — MovingProgressScreen**
Appears when: TrainState.moving or TrainState.coasting, after five seconds in that state — the sustained journey view.
What the passenger sees: A header with the train identifier chip and the current speed. The route map showing all station dots. A divider line. Below the divider, a two-column information panel: on the left, the current station name in large dark text with a station counter (e.g., "4 / 18 stations"); on the right, the next station name in large orange text with proximity dots showing how close the approach is. At the bottom, small labels for the origin and the final destination. This is the screen passengers will look at most during a long journey. Every element answers a different question: where are we, where are we going, how far, how close to the next stop.

**Screen 8 — ArrivingScreen**
Appears when: TrainState.arriving — the train is decelerating toward the next station.
What the passenger sees: The text "ARRIVÉE À" above the name of the approaching station in large orange text (52px), the route progress bar, and the final destination reminder. The large orange station name is intentional: during deceleration, passengers who are planning to disembark need to confirm quickly that this is their stop. The orange colour and large size make this impossible to miss.

**Screen 9 — EndOfRouteScreen**
Appears when: TrainState.endOfRoute — the train has reached its final destination.
What the passenger sees: A farewell message "Merci de voyager avec nous" in a light, generous 46px font, the terminal station name in orange, and the route progress bar showing every dot in orange — the entire route illuminated. The visual metaphor of all dots orange communicates completion without requiring any text to say "you have arrived at the end of the journey." The screen is calm and unhurried, respecting the moment.

---

## Section 7 — The Progress Bar Design

The route progress bar is the most carefully designed element in the Dove6 display system. It appears at the bottom of multiple screens and is the visual representation of the entire journey — all 18 stations, their relative positions on the route, and the train's current location among them.

The design philosophy is borrowed from the best passenger information displays in the world — Eurostar, the TGV, and the Shinkansen — and distilled into three principles for the specific constraints of this project.

**Principle 1: The track shows position, not progress.**
On lesser displays, a coloured fill line moves from left to right as the train progresses, showing how much of the route has been covered. This looks dynamic and satisfying, but it is visually dishonest: the fill line represents distance or time elapsed, not the train's position among stations. Passengers boarding at an intermediate station see a half-filled bar that tells them nothing useful about how many stops remain. In Dove6, there is no fill line. The grey horizontal track is purely structural — a visual rail. Position is communicated entirely through the dot states. A passenger looks at the dots and immediately understands: the filled orange dots are stops already made, the large glowing dot is here, the hollow dot is next, the grey dots are future stops. This is unambiguous and station-centric.

**Principle 2: The current station name is never truncated.**
Earlier prototype versions of the progress bar showed station labels under each dot on the track. With 18 stations spread across a screen width, there is simply not enough space for full names, and abbreviating "Casa Voyageurs" to "Casa Vo." is worse than showing no name at all — it creates confusion rather than resolving it. In the final design, the track carries only two labels: the origin station at the far left and the destination station at the far right. These two labels define the journey's endpoints and never need to be abbreviated because they are given the full width. The current station name is shown prominently in the information zone below the divider, at 36px, where it has all the space it needs. It is never shortened.

**Principle 3: The next stop gets equal visual weight to the current stop.**
The most common question a moving-train passenger asks is not "where am I?" but "when is my stop?" On the Dove6 progress screen, the next station name is displayed in orange at exactly the same font size (36px) as the current station name. It occupies the right column of the information panel with the same visual weight as the current station on the left. This is a deliberate departure from conventional designs that emphasise the current station and relegate the next stop to secondary text. Both pieces of information are equally important to a passenger who needs to decide whether to start gathering their belongings.

**The eighteen station dots:**

Every station on the route is always drawn, never hidden. The dots are spaced evenly across the full width of the track, with the origin at the far left and the destination at the far right. Each dot has one of four states:

Past stations (already served) are drawn as small solid orange circles, radius 5 pixels. They are orange because the train has been to them — they are part of the completed journey.

The current station is drawn as a large solid orange circle, radius 10 pixels, surrounded by a soft orange glow ring at radius 16 pixels with 13% opacity. The larger size makes the current position immediately obvious from a distance, and the glow ring adds a halo effect that draws the eye without being aggressive. This is the hero element of the progress bar.

The next station is drawn as a hollow circle — a kBg-coloured fill with an orange border of 2.5 pixels width, radius 6 pixels. The hollow style is the visual language for "destination not yet reached but actively heading toward." It is distinct from both the solid past dots and the grey future dots.

Future stations (all stations beyond the next) are drawn as small solid grey circles, radius 4 pixels, in the kDim colour. They recede into the background, communicating that they exist but are not yet relevant.

**Proximity dots:**

The proximity dots are five small circles that appear in the right column of the MovingProgressScreen, next to the "Approche" label. They indicate, in a simple dot-count metaphor, how close the train is to the next station. The number of filled (orange) dots is calculated by multiplying the current progress value by 5 and rounding to the nearest integer. When the train has just departed a station, all five dots are grey. As the train travels, dots fill in from left to right. When all five dots are orange, the next station is imminent. This metaphor is immediately intuitive — it works the same way a battery indicator works — and requires no numeric values or percentages.

---

## Section 8 — Bilingual Support (French and Arabic)

Morocco's official languages are Arabic and French. Both languages are used daily by ONCF passengers, and both are present in spoken on-board announcements. A passenger information display that shows only French excludes Arabic-speaking passengers. A display that shows both languages simultaneously creates visual clutter and reduces legibility. The solution is synchronised bilingual display: one language at a time, always matching what the speaker is announcing.

French is the default language. When no audio announcement is being made — when the train is between announcements — the display shows French. This is the baseline state and is always safe to fall back to.

The audio synchronisation mechanism works as follows. When the NVR begins an audio announcement, it sets the active_audio_lang field in the data package. The display application polls the /audio-state endpoint whenever the train state changes and reads the audio_action field. If the value is "playing_arabic_audio", the display application sets its language flag to Arabic. On the next state transition — for example, when the train transitions from departing to moving — the display updates to Arabic. When the audio_action returns to any other value ("playing_french_audio", "no_audio_is_playing"), the language flag returns to French on the next state change.

The synchronisation is deliberately tied to state changes rather than continuous polling. Changing the display language mid-screen would be disorienting. The language transition happens at natural screen transitions, which means the display and the spoken announcement are in the same language from the beginning of that screen's display period.

Arabic text presents a specific technical requirement: right-to-left text direction. In the Latin-script world, all text flows from left to right. In Arabic, text flows from right to left, meaning that the beginning of a sentence is at the right side of the screen and the end is at the left. If this is not handled correctly, Arabic text is rendered in the wrong visual order and becomes illegible. The Flutter framework supports right-to-left text through a Directionality widget, and every screen in Dove6 that shows Arabic station names or messages wraps those text elements in a Directionality widget configured for right-to-left rendering. The text alignment is set to right-aligned to match the reading direction. This ensures that Arabic text is rendered identically to how it would appear in print or on a bilingual sign.

---

## Section 9 — The NVR API Contract

An API, or Application Programming Interface, is a formal agreement between two software systems about how they will communicate. It defines what questions one system can ask the other, in what format the questions must be posed, and in what format the answers will be given. An API contract is the written specification of this agreement — a document that both sides commit to and that neither side may break without the other's knowledge.

The Dove6 API contract was established between the dove6_client display application and the NVR backend being developed by a colleague. The contract defines a set of HTTP endpoints, the structure of the JSON responses, and the exact string values that represent each possible state. Both sides must implement this contract faithfully. If the NVR sends "operating_state_atStation" (with a capital S) instead of the contracted "operating_state_atstation" (all lowercase), the display application will not recognise the value and will default to idle — the passenger sees the wrong screen. The contract must be precise.

**The state string naming convention:**

The NVR communicates operational states using strings in the format "operating_state_[statename]". The complete mapping is:

- "operating_state_idle" maps to the idle display state
- "operating_state_routeselected" maps to the route-selected display state
- "operating_state_atstation" maps to the at-station display state
- "operating_state_departing" maps to the departing display state
- "operating_state_moving" maps to the moving display state
- "operating_state_coasting" maps to the moving display state (same visual, different NVR semantic)
- "operating_state_arriving" maps to the arriving display state
- "operating_state_endofroute" maps to the end-of-route display state
- "operating_state_recovery" maps to the recovery priority state
- "operating_state_warning" maps to the warning priority state
- "Operating_State_ManualHandling" maps to the manual priority state (note: this one uses mixed case as specified by the NVR firmware)

The audio action strings follow a similar pattern:

- "playing_french_audio" means the speaker is making a French announcement — display stays in French
- "playing_arabic_audio" means the speaker is making an Arabic announcement — display switches to Arabic
- "playing_english_audio" means the speaker is making an English announcement — display stays in French (English display not yet implemented)
- "playing_default_audio" — display stays in French
- "no_audio_is_playing" — display stays in current language, defaults to French

**The station data pipeline:**

Station names are not hardcoded in the display application. The display fetches them dynamically from the NVR through a three-step process. First, it calls /data/current-route to learn the current route identifier and the current station index. Second, if the route identifier is new, it calls /data/stations-in-route/{route_id} to get the list of station identifiers. Third, for each station identifier, it calls /data/station-info/{station_id} to get the bilingual names. This three-call sequence is performed only when the route identifier changes — typically once per journey — and the results are cached for the duration of that route. This design means the display application has no knowledge of Morocco's rail geography at compile time. It learns the route from the NVR, and it would work correctly on any rail line in any country as long as the NVR provides the correct station data.

A current open item in the API contract is the Arabic station name field. The display application expects a "display_name_ar" field in the station-info response. As of the writing of this document, this field has been implemented in the dove6_server development server and is present in routes.json, but its inclusion in the real NVR firmware has been requested and is pending confirmation from the colleague responsible for that system.

---

## Section 10 — Route Management

The routes.json file is the single source of truth for all route information in the system. It is a plain-text file in the JSON format, readable and editable in any text editor without any programming knowledge. The file has a simple structure: a key called "active_route" that holds the name of the route to use, and a "routes" dictionary where each key is a route identifier and each value is a route definition containing the route's display name, its final destination in French and Arabic, and the complete ordered list of all stations in French and Arabic.

The current file contains three routes. The active route at the time of this writing is "casa_fes" — the Casa Voyageurs to Fès line with 7 stations. To change to the Marrakech to Tanger Ville route, an operator would change the value of "active_route" from "casa_fes" to "marrakech_tanger" and restart the server. No code changes, no recompilation, no developer involvement.

Adding a new route — for example, a new Agadir to Marrakech service — requires adding one new block to the routes dictionary in the same format as the existing entries: a route identifier key, a display name, a destination in both languages, and the ordered station lists in French and Arabic. The server reads this file fresh every time it starts. The display application never needs to be modified, recompiled, or redeployed for a new route to work — it discovers the route dynamically through the API contract.

A simplified example of adding a new Agadir to Casablanca route would follow the same format as the existing entries: providing the route name, destination names in both languages, and the complete ordered lists of stations in French and Arabic. The principle is the same regardless of how many stations the route contains or what cities it serves.

This architecture reflects a fundamental principle of the system's design: the display application is a generic passenger information renderer, and the NVR is the source of all route-specific knowledge. The display application does not know which country it is in, which rail operator it serves, or which cities are on the route. It only knows how to render states, names, and numbers that are given to it. This makes the system portable to any future AVIARAIL project on any rail network without modification to the display codebase.

---

## Section 11 — Development Setup

The complete Dove6 system can be run on a single laptop for development and demonstration purposes. The following instructions assume a laptop running Ubuntu Linux or Windows Subsystem for Linux (WSL). WSL is a compatibility layer built into Windows that allows Linux programs to run directly on a Windows computer. Because the final deployment target is Ubuntu Linux on the Aeon Gene BT06, developing in a Linux environment — even a simulated one — ensures that the application behaves identically in development and production.

**Step 1 — Install the required tools**

The server requires the Go programming language, version 1.21 or later. Install it with:

    sudo apt install golang-go

The display application requires the Flutter framework with Linux desktop support enabled. Download Flutter from flutter.dev and add it to your PATH. Then install the Linux build dependencies:

    sudo apt install cmake ninja-build libgtk-3-dev

Verify that Flutter can build for Linux:

    flutter doctor

**Step 2 — Get the source code**

Clone the repository from GitHub:

    git clone https://github.com/ayoubnahji/dove6.git
    cd dove6

The repository contains two folders: dove6_server and dove6_client.

**Step 3 — Start the server**

Open a terminal and run:

    cd dove6_server
    go run .

You will see a banner printed to the terminal showing the active route and all available endpoints. The server will begin advancing through the journey automatically, printing one line per step every fifteen seconds.

**Step 4 — Configure the client**

Open dove6_client/lib/main.dart in a text editor. Verify that these two lines are set correctly for development:

    const bool useLocalSimulation = false;
    const String nvrBaseUrl = 'http://127.0.0.1:8080';

The first line tells the application to connect to a real server rather than the built-in simulation. The second line points to the server running on the same machine (127.0.0.1 is the address that always means "this machine").

**Step 5 — Start the display application**

Open a second terminal and run:

    cd dove6_client
    flutter run -d linux

Flutter will compile the application and open a window on the screen. The application will connect to the server and begin displaying the journey. You will see the idle screen first, and the display will update every fifteen seconds as the server advances to the next step.

**Step 6 — Control the demonstration**

To jump to any specific screen instantly, open a web browser and type:

    http://localhost:8080/jump?step=2

Replace "2" with any step number. Step 2 shows the train stopped at Marrakech. Step 4 shows the train moving. Step 70 shows the end of route. The server prints the new step to its terminal window so you can confirm the jump was received.

---

## Section 12 — Production Deployment

Deploying the system to a real train involves replacing the fake development server with the real NVR firmware, pointing the display application at the real NVR's network address, and configuring the display application to start automatically when the Aeon Gene BT06 screen powers on.

**The one-line change:**

The entire difference between a development deployment and a production deployment, from the display application's perspective, is the NvrBaseUrl constant in main.dart. In development it is 'http://127.0.0.1:8080'. In production, it becomes the IP address of the R6S Lanner NVR on the train's internal network — for example 'http://192.168.1.50:3002/v0'. No other change is required. The DataService abstraction was designed precisely for this moment.

**Building for Ubuntu Linux:**

The display application is compiled for Ubuntu Linux using Flutter's Linux build target:

    flutter build linux --release

This produces a self-contained executable in the build/linux/x64/release/bundle folder. This folder, including its companion library files, is copied to the Aeon Gene BT06. The application runs without any network connection to the internet — the only network communication it performs is within the train's internal network.

**The Aeon Gene BT06:**

The Aeon Gene BT06 is a compact embedded computing board in the Mini-ITX form factor, designed for industrial applications where reliability, low power consumption, and physical compactness are important. It runs Ubuntu Linux and has DisplayPort output for the passenger screen, Ethernet for connection to the train's internal network, and USB ports for installation and maintenance. Its small size allows it to be mounted behind the display panel in the carriage ceiling or at the end of the carriage.

**Automatic startup:**

The application can be configured to launch automatically when the BT06 powers on using a systemd service — a Linux mechanism for programs that should start with the operating system. A service file is created in /etc/systemd/system/dove6.service describing the application's executable path and stating that it should restart automatically if it crashes. The command:

    sudo systemctl enable dove6

registers this service so it survives a power cycle. When the train receives power, the BT06 boots Ubuntu, Ubuntu starts the dove6 service, and within seconds the passenger screen is showing the current state of the journey.

---

## Section 13 — Future Improvements

The current system is a functional, well-architected prototype that meets all requirements for the Z2M renovation programme. The following improvements would be undertaken in a future iteration to move from prototype quality to fully production-hardened quality.

**WebSocket instead of HTTP polling**

Currently the display application sends a new HTTP request to the server every second, even if nothing has changed. This polling approach is simple and reliable, but it creates unnecessary load on both the server and the network. The correct long-term architecture is WebSocket: a persistent connection where the server pushes data to the display only when something changes. This would reduce latency from up to one second to near-zero, reduce network traffic by approximately ninety percent, and allow the server to push emergency alerts immediately rather than waiting for the next poll. The DataService abstraction in the current code is already designed to support this migration — only the data service implementation would change.

**Authentication on the NVR API**

The current API has no authentication. Any device on the train's internal network that knows the server address can query it. For the controlled environment of a single train carriage, this is acceptable. For a fleet of trains where multiple screens may be connected, adding a shared secret or token-based authentication would prevent unauthorised devices from consuming NVR data.

**Watchdog timer for automatic app restart**

If the display application crashes due to an unexpected error, the screen goes blank. A watchdog is a small background process that checks every few seconds whether the application is still running and restarts it if not. On Linux, this functionality can be implemented as part of the systemd service configuration using the Restart and RestartSec directives. With this in place, any crash is recovered within seconds without human intervention.

**Offline data persistence for recovery**

If the connection to the NVR is lost while the train is between stations, the display currently shows the "CONNECTION LOST" recovery screen. An improvement would be to persist the last known good state on the Aeon Gene BT06's local storage and continue displaying it during brief connection interruptions, while indicating that the data may be slightly out of date. This would make the recovery state invisible to passengers for short network disruptions.

**Automated test suite**

The current codebase has no automated tests. A test suite for the DisplayMapper would verify that every state transition produces the correct screen, that the Arabic language flag is set and cleared correctly, that the speed timer fires after exactly five seconds, and that the arrived-message flash lasts exactly three seconds. Tests for the NvrDataService would verify that each API response format is parsed correctly and that connection failures correctly trigger the recovery state.

**Brightness control for day and night**

The current display uses a fixed colour palette that was designed for a well-lit carriage environment. Night-time passengers in a darkened carriage would benefit from a reduced brightness mode. This could be implemented by linking the display brightness to the time of day, or by adding a brightness endpoint to the NVR API that reflects the ambient light sensor reading from the R6S Lanner hardware.

---

*This document describes the Dove6 system as implemented and deployed during the internship period at AVIARAIL, April 2026. The architecture decisions documented here represent the professional judgement of the development team and are intended to serve as a reference for the mémoire de fin d'études jury and for any engineer who works on this system in the future.*
