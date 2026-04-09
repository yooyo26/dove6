# ROUTES.md — Route Selector System

## Mission
Build a route selection system for dove6_server.
When the server starts it reads a config file called
routes.yaml that contains all available routes.
The operator picks which route to run by editing
one line in routes.yaml before starting the server.

---

## CRITICAL RULES
- Do NOT change the HTTP endpoints
- Do NOT change handler.go endpoint logic
- Do NOT change main.go startup box
- Only add new files and modify journey.go
- Standard library only — no external Go packages
- Use encoding/json and os packages only

---

## STEP 1 — Create routes.json

Create a new file called routes.json in dove6_server/:

```json
{
  "active_route": "marrakech_tanger",
  "routes": {
    "marrakech_tanger": {
      "name": "Marrakech → Tanger Ville",
      "destination": "Tanger Ville",
      "destination_ar": "طنجة المدينة",
      "stations_fr": [
        "Marrakech", "Youssoufia", "Benguerir", "Settat",
        "El Jadida", "Casa Oasis", "Casa Voyageurs",
        "Casa Ain Sebaa", "Mohammedia", "Rabat Agdal",
        "Rabat Ville", "Salé Tabriquet", "Salé Ville",
        "Kénitra", "Sidi Bouknadel", "Ksar El Kébir",
        "Asilah", "Tanger Ville"
      ],
      "stations_ar": [
        "مراكش", "اليوسفية", "بنكرير", "سطات",
        "الجديدة", "الدار البيضاء أويسيس",
        "الدار البيضاء المسافرين",
        "الدار البيضاء عين السبع", "المحمدية",
        "الرباط أكدال", "الرباط المدينة",
        "سلا طابريقت", "سلا المدينة", "القنيطرة",
        "سيدي بوقنادل", "القصر الكبير",
        "أصيلة", "طنجة المدينة"
      ]
    },
    "casa_fes": {
      "name": "Casa Voyageurs → Fès",
      "destination": "Fès",
      "destination_ar": "فاس",
      "stations_fr": [
        "Casa Voyageurs", "Rabat Agdal", "Rabat Ville",
        "Salé Ville", "Kénitra", "Meknès", "Fès"
      ],
      "stations_ar": [
        "الدار البيضاء المسافرين", "الرباط أكدال",
        "الرباط المدينة", "سلا المدينة",
        "القنيطرة", "مكناس", "فاس"
      ]
    },
    "casa_marrakech": {
      "name": "Casa Voyageurs → Marrakech",
      "destination": "Marrakech",
      "destination_ar": "مراكش",
      "stations_fr": [
        "Casa Voyageurs", "Settat", "Benguerir", "Marrakech"
      ],
      "stations_ar": [
        "الدار البيضاء المسافرين", "سطات",
        "بنكرير", "مراكش"
      ]
    }
  }
}
```

---

## STEP 2 — Create routes.go

Create a new file called routes.go in dove6_server/:

```go
package main

import (
	"encoding/json"
	"fmt"
	"os"
)

// RouteConfig holds all available routes
type RouteConfig struct {
	ActiveRoute string                 `json:"active_route"`
	Routes      map[string]RouteData   `json:"routes"`
}

// RouteData holds one route definition
type RouteData struct {
	Name          string   `json:"name"`
	Destination   string   `json:"destination"`
	DestinationAr string   `json:"destination_ar"`
	StationsFr    []string `json:"stations_fr"`
	StationsAr    []string `json:"stations_ar"`
}

// loadRoute reads routes.json and returns the active route
func loadRoute() RouteData {
	data, err := os.ReadFile("routes.json")
	if err != nil {
		fmt.Println("[DOVE6] WARNING: routes.json not found.")
		fmt.Println("[DOVE6] Using default 18-station route.")
		return defaultRoute()
	}

	var config RouteConfig
	if err := json.Unmarshal(data, &config); err != nil {
		fmt.Println("[DOVE6] WARNING: routes.json is invalid.")
		fmt.Println("[DOVE6] Using default 18-station route.")
		return defaultRoute()
	}

	route, ok := config.Routes[config.ActiveRoute]
	if !ok {
		fmt.Printf("[DOVE6] WARNING: route '%s' not found.\n",
			config.ActiveRoute)
		fmt.Println("[DOVE6] Using default 18-station route.")
		return defaultRoute()
	}

	fmt.Printf("[DOVE6] Route loaded: %s\n", route.Name)
	fmt.Printf("[DOVE6] Stations: %d\n", len(route.StationsFr))
	return route
}

// defaultRoute returns a safe fallback
func defaultRoute() RouteData {
	return RouteData{
		Name:          "Marrakech → Tanger Ville",
		Destination:   "Tanger Ville",
		DestinationAr: "طنجة المدينة",
		StationsFr: []string{
			"Marrakech", "Kénitra", "Tanger Ville",
		},
		StationsAr: []string{
			"مراكش", "القنيطرة", "طنجة المدينة",
		},
	}
}
```

---

## STEP 3 — Update journey.go

Replace the hardcoded routeFr and routeAr variables
with dynamic ones loaded from routes.json.

At the top of journey.go add:

```go
// activeRoute is loaded from routes.json at startup
var activeRoute RouteData
```

Remove the hardcoded routeFr and routeAr variables.

Update fillJourney() to use activeRoute:

```go
func fillJourney() {
	for i := range journey {
		journey[i].TrainID        = "DOVE-6"
		journey[i].Destination    = activeRoute.Destination
		journey[i].DestinationFr  = activeRoute.Destination
		journey[i].DestinationAr  = activeRoute.DestinationAr
		journey[i].RouteStations  = activeRoute.StationsFr
		journey[i].RouteStationsFr = activeRoute.StationsFr
		journey[i].RouteStationsAr = activeRoute.StationsAr
	}
}
```

Also update the handler for /data/stations-in-route
and /data/station-info to use activeRoute.StationsFr
and activeRoute.StationsAr instead of hardcoded routeFr
and routeAr.

---

## STEP 4 — Update main.go

In the main() function add this BEFORE fillJourney():

```go
// Load route from routes.json
activeRoute = loadRoute()
```

Update the startup box to show the active route:

```go
fmt.Printf("[DOVE6] Active route: %s\n", activeRoute.Name)
```

---

## STEP 5 — Create README-ROUTES.md

Create a file called README-ROUTES.md in dove6_server/:

```markdown
# How to change the route

## Step 1 — Open routes.json
Edit the file routes.json in this folder.

## Step 2 — Change active_route
Find this line at the top:
  "active_route": "marrakech_tanger"

Change the value to any route key listed in "routes".
Available routes:
  marrakech_tanger   — Marrakech → Tanger Ville (18 stations)
  casa_fes           — Casa Voyageurs → Fès (7 stations)
  casa_marrakech     — Casa Voyageurs → Marrakech (4 stations)

Example — to run Casa → Fès:
  "active_route": "casa_fes"

## Step 3 — Add a new route (optional)
Copy any existing route block inside "routes".
Give it a new key.
Fill in the station names in French and Arabic.
Set active_route to your new key.

## Step 4 — Start the server
cd dove6_server
go run .

The server will print which route it loaded.
```

---

## VERIFY

Run:
```bash
go run .
```

You should see:
```
[DOVE6] Route loaded: Marrakech → Tanger Ville
[DOVE6] Stations: 18
[DOVE6] Active route: Marrakech → Tanger Ville
```

Test switching routes:
1. Open routes.json
2. Change active_route to "casa_fes"
3. Stop server with Ctrl+C
4. Run go run . again
5. Should print: Route loaded: Casa Voyageurs → Fès
6. Run: curl http://localhost:8080/data/stations-in-route/dove6-route-001
7. Should return 7 station IDs not 18

Report which files were created and modified.