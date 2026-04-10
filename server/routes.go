package main

import (
	"encoding/json"
	"fmt"
	"os"
)

// RouteConfig holds all available routes
type RouteConfig struct {
	ActiveRoute string               `json:"active_route"`
	Routes      map[string]RouteData `json:"routes"`
}

// RouteData holds one route definition
type RouteData struct {
	Name          string   `json:"name"`
	RouteID       string   `json:"route_id"`
	Destination   string   `json:"destination"`
	DestinationAr string   `json:"destination_ar"`
	StationIDs    []string `json:"station_ids"`
	StationsFr    []string `json:"stations_fr"`
	StationsAr    []string `json:"stations_ar"`
}

// stationIDIndex maps station UUID → 0-based index in the active route
var stationIDIndex map[string]int

// loadRoute reads routes.json and returns the active route
func loadRoute() RouteData {
	data, err := os.ReadFile("routes.json")
	if err != nil {
		fmt.Println("[DOVE6] WARNING: routes.json not found. Using default 3-station route.")
		return defaultRoute()
	}

	var config RouteConfig
	if err := json.Unmarshal(data, &config); err != nil {
		fmt.Println("[DOVE6] WARNING: routes.json is invalid. Using default 3-station route.")
		return defaultRoute()
	}

	route, ok := config.Routes[config.ActiveRoute]
	if !ok {
		fmt.Printf("[DOVE6] WARNING: route key '%s' not found. Using default 3-station route.\n", config.ActiveRoute)
		return defaultRoute()
	}

	fmt.Printf("[DOVE6] Route loaded: %s (%s)\n", route.Name, route.RouteID)
	fmt.Printf("[DOVE6] Stations: %d\n", len(route.StationsFr))
	return route
}

// buildStationIndex builds the UUID → index lookup table.
// Must be called after loadRoute().
func buildStationIndex() {
	stationIDIndex = make(map[string]int, len(activeRoute.StationIDs))
	for i, id := range activeRoute.StationIDs {
		stationIDIndex[id] = i
	}
}

// defaultRoute returns a safe 3-station fallback
func defaultRoute() RouteData {
	return RouteData{
		Name:          "Marrakech → Tanger Ville",
		RouteID:       "00000000-0000-0000-0000-000000000000",
		Destination:   "Tanger Ville",
		DestinationAr: "طنجة المدينة",
		StationIDs: []string{
			"00000000-0000-0000-0000-000000000001",
			"00000000-0000-0000-0000-000000000002",
			"00000000-0000-0000-0000-000000000003",
		},
		StationsFr: []string{"Marrakech", "Kénitra", "Tanger Ville"},
		StationsAr: []string{"مراكش", "القنيطرة", "طنجة المدينة"},
	}
}
