// routes.go — loads routes.json and exposes the active route config
package main

import (
	"encoding/json"
	"log"
	"os"
)

type RouteConfig struct {
	Name          string   `json:"name"`
	Destination   string   `json:"destination"`
	DestinationAr string   `json:"destination_ar"`
	StationsFr    []string `json:"stations_fr"`
	StationsAr    []string `json:"stations_ar"`
}

type RoutesFile struct {
	ActiveRoute string                 `json:"active_route"`
	Routes      map[string]RouteConfig `json:"routes"`
}

var activeRoute RouteConfig

func loadRoutes() {
	data, err := os.ReadFile("routes.json")
	if err != nil {
		log.Fatalf("[DOVE6] Failed to read routes.json: %v", err)
	}
	var rf RoutesFile
	if err := json.Unmarshal(data, &rf); err != nil {
		log.Fatalf("[DOVE6] Failed to parse routes.json: %v", err)
	}
	r, ok := rf.Routes[rf.ActiveRoute]
	if !ok {
		log.Fatalf("[DOVE6] Active route %q not found in routes.json", rf.ActiveRoute)
	}
	activeRoute = r
}

// stationAr returns the Arabic name matching the given French station name.
func stationAr(stationFr string) string {
	for i, fr := range activeRoute.StationsFr {
		if fr == stationFr && i < len(activeRoute.StationsAr) {
			return activeRoute.StationsAr[i]
		}
	}
	return stationFr
}
