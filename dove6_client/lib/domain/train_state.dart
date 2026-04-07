// All possible train operational states
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
