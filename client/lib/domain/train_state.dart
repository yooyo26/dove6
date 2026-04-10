// All possible train operational states
// coasting is NOT a separate state — it maps to moving at parse layer
enum TrainState {
  idle,
  routeSelected,
  atStation,
  departing,
  moving,
  arriving,
  endOfRoute,
  warning,
  manual,
  recovery,
}
