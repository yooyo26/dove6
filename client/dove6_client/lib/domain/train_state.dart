// All possible train operational states
enum TrainState {
  idle,
  routeSelected,
  atStation,
  departing,
  moving,
  coasting,
  arriving,
  endOfRoute,
  warning,
  manual,
  recovery,
}
