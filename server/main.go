package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	// Load route from routes.json
	activeRoute = loadRoute()
	fillJourney()
	setupRoutes()

	// This goroutine advances the journey step automatically
	go func() {
		for {
			time.Sleep(stepDuration)
			mu.Lock()
			currentStep = (currentStep + 1) % len(journey)
			step := journey[currentStep]
			idx  := currentStep
			mu.Unlock()
			fmt.Printf("[DOVE6] Step %2d/%d  %-16s  %s  %.0f km/h\n",
				idx+1,
				len(journey),
				step.State,
				step.CurrentStation,
				step.SpeedKmh,
			)
		}
	}()

	fmt.Println("┌──────────────────────────────────────────────────┐")
	fmt.Println("│         DOVE6 NVR Server v2.0                    │")
	fmt.Println("│         Matching real NVR API contract           │")
	fmt.Println("│                                                  │")
	fmt.Printf( "│  Active route: %-34s│\n", activeRoute.Name)
	fmt.Println("│  GET /running-state          current state       │")
	fmt.Println("│  GET /audio-state            audio language      │")
	fmt.Println("│  GET /data/speed             current speed       │")
	fmt.Println("│  GET /data/distance-ratio    route progress      │")
	fmt.Println("│  GET /data/current-route     route info          │")
	fmt.Println("│  GET /data/stations-in-route/:id  station ids   │")
	fmt.Println("│  GET /data/station-info/:id  station names       │")
	fmt.Println("│  GET /sensors/human-counter  passenger count     │")
	fmt.Println("│  GET /health                 connectivity        │")
	fmt.Println("│  GET /jump?step=N            demo control        │")
	fmt.Println("│                                                  │")
	fmt.Println("│  Listening on http://0.0.0.0:8080                │")
	fmt.Println("└──────────────────────────────────────────────────┘")

	// Shutdown cleanly when you press Ctrl+C
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-quit
		fmt.Println("\n[DOVE6] Server stopped cleanly.")
		os.Exit(0)
	}()

	if err := http.ListenAndServe("0.0.0.0:8080", nil); err != nil {
		fmt.Println("Error starting server:", err)
		os.Exit(1)
	}
}