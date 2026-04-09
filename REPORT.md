# DOVE6 — Project Report
# File Map and How to Run

Generated automatically from the project structure.

---

## Repository location
~/dove6/

---

## Top-level structure

| Folder/File | What it is |
|---|---|
| client/ | Flutter passenger display app |
| server/ | Go NVR simulation server |
| docs/ | All documentation files |
| scripts/ | Helper scripts |
| README.md | Project overview |
| CLAUDE.md | AI session context file |
| REPORT.md | This file |
| .gitignore | Git ignore rules |

---

## The Flutter app (client/)

### Location
~/dove6/client/

### How to run in development
```bash
cd ~/dove6/client
flutter pub get
flutter run -d linux
```

### How to build for production
```bash
cd ~/dove6/client
flutter build linux --release
```

### Where the binary is after build
~/dove6/client/build/linux/x64/release/bundle/dove6_client

### How to configure
Open client/lib/main.dart and find:
  const bool useLocalSimulation = false;
  const String nvrBaseUrl = 'http://127.0.0.1:8080';

Set useLocalSimulation = true for offline testing.
Set nvrBaseUrl to your laptop IP when testing with server.

### Folder structure inside client/
```
client/lib/
  main.dart                       App entry point
  domain/
    train_state.dart              11-state enum
    display_data.dart             Core data model
    language.dart                 FR/AR language enum
  data/
    data_service.dart             Abstract interface
    fake_data_service.dart        Local simulation
    nvr_data_service.dart         Real server polling
  presentation/
    display_mapper.dart           Routes state to screen
    screens/
      _shared.dart                Colors, painter, widgets
      idle_screen.dart            Train waiting screen
      route_selected_screen.dart  Route confirmation screen
      station_screen.dart         At station screen
      departing_screen.dart       Departure screen
      moving_speed_screen.dart    Speed display screen
      moving_progress_screen.dart Progress display screen
      arriving_screen.dart        Arriving screen
      arrived_message_screen.dart Arrival confirmation
      end_of_route_screen.dart    Journey complete screen
```

---

## The Go server (server/)

### Location
~/dove6/server/

### How to run
```bash
cd ~/dove6/server
go run .
```

### How to stop
Press Ctrl+C in the terminal

### Available endpoints
| Endpoint | What it returns |
|---|---|
| GET /running-state | Current train state |
| GET /audio-state | Active audio language |
| GET /data/speed | Current speed in km/h |
| GET /data/distance-ratio | Progress 0 to 100 |
| GET /data/current-route | Route ID and station index |
| GET /data/stations-in-route/{id} | List of station IDs |
| GET /data/station-info/{id} | Station name FR and AR |
| GET /sensors/human-counter | Passenger count |
| GET /health | Server is alive check |
| GET /jump?step=N | Jump to any journey step |

### How to test endpoints
```bash
curl http://localhost:8080/health
curl http://localhost:8080/running-state
curl http://localhost:8080/data/speed
```

### How to change the simulated route
1. Open server/routes.json
2. Change the value of active_route
3. Available routes are listed in the routes object
4. Stop the server with Ctrl+C
5. Run go run . again

### How to add a new route
Open server/routes.json and add a new entry:
```json
"your_route_key": {
  "name": "Origin → Destination",
  "destination": "Destination City",
  "destination_ar": "اسم المدينة",
  "stations_fr": ["Station1", "Station2", "Station3"],
  "stations_ar": ["المحطة1", "المحطة2", "المحطة3"]
}
```
Then set active_route to your_route_key.

### File structure inside server/
```
server/
  main.go       Server entry point and startup
  handler.go    All HTTP endpoint handlers
  journer.go    Journey simulation script
  routes.go     Route loading from routes.json
  routes.json   Route definitions — edit this to change route
  go.mod        Go module definition
```

---

## Documentation files (docs/)

| File | What it contains |
|---|---|
| ARCHITECTURE.md | Complete system architecture explanation |
| CLAUDE.md | AI session context for docs |

---

## Helper scripts (scripts/)

| Script | What it does |
|---|---|
| start_server.sh | Starts the Go server |
| build_client.sh | Builds Flutter app for Linux |

### How to use scripts
```bash
# Start server
bash scripts/start_server.sh

# Build Flutter app
bash scripts/build_client.sh
```

---

## Archived versions

Old versions are preserved in Git branches.
To access them:
```bash
git branch -a
git checkout archive/drafts
```

Available archive branches:
Run git branch -a to see all archived versions.

---

## Running the complete system

### Step 1 — Open two terminal tabs in VSCode

### Step 2 — Terminal 1: start the server
```bash
cd ~/dove6/server
go run .
```
Wait for the startup box to appear.

### Step 3 — Terminal 2: run the Flutter app
```bash
cd ~/dove6/client
flutter pub get
flutter run -d linux
```
Wait for the app window to open.

### Step 4 — Control the simulation
Open your browser and use:
http://localhost:8080/jump?step=N
Replace N with any step number to jump to that state.

Key step numbers:
  0  → IDLE
  1  → ROUTE_SELECTED
  2  → AT_STATION (first station)
  3  → DEPARTING
  4  → MOVING (speed phase)
  After 5 seconds → MOVING (progress phase)

---

## Switching between routes

1. Open server/routes.json in VSCode
2. Change "active_route" value
3. Stop server with Ctrl+C
4. Run go run . again
5. Flutter app adapts automatically — no restart needed

---

## System requirements

Server:
- Go 1.21 or higher
- Ubuntu Linux (WSL works)
- Port 8080 must be free

Client:
- Flutter 3.x or higher
- Ubuntu Linux or WSL with Linux desktop support
- GTK3 libraries installed

Install GTK3 if needed:
```bash
sudo apt install -y clang cmake ninja-build \
  pkg-config libgtk-3-dev
```
