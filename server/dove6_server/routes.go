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
		fmt.Printf("[DOVE6] WARNING: route '%s' not found.\n", config.ActiveRoute)
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
