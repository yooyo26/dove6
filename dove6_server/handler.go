// handler.go — HTTP endpoints for the DOVE6 NVR simulator
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"
)

// mu protects currentStep so reading and writing is safe
var (
	currentStep int
	mu          sync.RWMutex
)

// StateResponse wraps Step and adds bilingual station name fields.
type StateResponse struct {
	Step
	CurrentStationFr string `json:"current_station_fr"`
	CurrentStationAr string `json:"current_station_ar"`
	NextStationFr    string `json:"next_station_fr"`
	NextStationAr    string `json:"next_station_ar"`
	DestinationFr    string `json:"destination_fr"`
	DestinationAr    string `json:"destination_ar"`
}

func buildStateResponse(step Step) StateResponse {
	return StateResponse{
		Step:             step,
		CurrentStationFr: step.CurrentStation,
		CurrentStationAr: stationAr(step.CurrentStation),
		NextStationFr:    step.NextStation,
		NextStationAr:    stationAr(step.NextStation),
		DestinationFr:    activeRoute.Destination,
		DestinationAr:    activeRoute.DestinationAr,
	}
}

func currentStepData() Step {
	mu.RLock()
	defer mu.RUnlock()
	return journey[currentStep]
}

func setStep(n int) {
	mu.Lock()
	defer mu.Unlock()
	if n >= 0 && n < len(journey) {
		currentStep = n
	}
}

func setupRoutes() {

	// GET /state
	// The Flutter app calls this every 2 seconds.
	// FUTURE: replace with real NVR StateManager data — only this handler changes.
	http.HandleFunc("/state", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[DOVE6] %s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		json.NewEncoder(w).Encode(buildStateResponse(currentStepData()))
	})

	// GET /health
	// Flutter checks this on startup to confirm the server is reachable.
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[DOVE6] %s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Write([]byte(`{"status":"ok","server":"dove6_server"}`))
	})

	// GET /jump?step=N
	// Manually jump to any step during a demo.
	// Example: http://192.168.137.1:8080/jump?step=4
	http.HandleFunc("/jump", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[DOVE6] %s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)
		n, err := strconv.Atoi(r.URL.Query().Get("step"))
		if err != nil {
			http.Error(w, "usage: /jump?step=0", http.StatusBadRequest)
			return
		}
		setStep(n)
		mu.RLock()
		fmt.Printf("[DOVE6] Manual jump → Step %d/%d: %s\n",
			currentStep+1, len(journey), journey[currentStep].State)
		mu.RUnlock()
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Access-Control-Allow-Origin", "*")
		json.NewEncoder(w).Encode(buildStateResponse(currentStepData()))
	})
}
