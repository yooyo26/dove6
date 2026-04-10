# Train Onboard System Architecture

## Abbreviations

- rt (real time): Indicates that the data is not available at initialization and is determined
    during runtime.

## System Overview

A central NVR will collect the necessary data and control the displays


## Static Configuration

A configuration method must be defined to register external displays and peripherals. for example
a peripheral at 192.168.1.x may be designated as an external display, and a GPS at 192.168.1.y
may also be registerd this configuration service may not need running proccess for it maybe just
config file since those parameters don’t change that much and i don’t think internal displays need
any configuration the system will provide data endpoints, and the software running on the internal
displays will retrieve the data from these endpoints and process it as needed.

```
Example config
```
```
peripheral :
type : code_xyz # stands for gps
ip : a.b.c.d
port : ....
```
```
peripheral :
type : code_abc # stands for external display
ip : a.b.c.d
port : ....
```
```
data endpoints that is needed by internal displays
```
```
func dataEndpoint(dataOfIntreset, ...) {
```
### }

At this stage, the locations of the peripherlas are known, so the system can begin reading and


writing data to them, for example reading GPS and speed data, or sending output to external
displays. however the exact data to be exchanged still needs to be defined. some data such as time,
cabin temperature, is local the the train, while othere data, such as destination information, is not
local and cannot be configured once at setup

```
One possible approach is to have a server at each station that stores route information when the
train arrives? at that station it request it but that is expensive and i believe that there’s central
server that we will talk to and pass our train-id and he can give us this info
about arrives there might be trackside beacons that can give us the info
```
```
https://www.intertechrail.com/smart-rail-balises
```
```
Notes
```
- the central system is likely third-party so we need to adapt out integration to comply with
    its security requirements.
- we might expose train data for _telemetry_ or _live monitoring_ for example GPS and speed
    which might require another server that collects data from all trains.

## runtime config

Expose an API and optionally a frontend service on the station server to allow configuration
updates such as specifying audio announcements to play when the train is **approaching** a station.
we might make the service capable of providing custom commands config that the _train driver_ can
trigger such as playing a designated audio clip.


## NVR Responsibilty Overview [v0]

## Data collection

**Responsibilities**

- Ghater all sensor and peripheral data (gps, speed, door status,... )
- timestamp data
- store **local log**
- **error handling** might detect errors such as missing or incorrect data such going 20000km/h
- even triggers?: maybe add hooks for some data for example speed threshold passed we should
    notify someone or door is still open.

## Expose Api For Internal Display

**Responsibilities**

- each internal display has it’s own onboard PC, capable of pulling data
- the NVR exposes APIs the the internal display software can query
- the display pc requests only the data it needs such as:


**-** GPS location
**-** Speed
**-** Cabin temperature
**-**...

## Runtime Configuration API

**Responsibilities**

- allow updates to system behavior with restarting
- examples: audio announcements, custom operator commands
- interface with other modules that need this config such as (Scheduler)
- persistance: runtime config should survive reboot
- good error handling such as don’t allow invalid ip, or invalid audio path

## Task Scheduler

**Responsibilities**

- trigger actions based on events (e.g approaching station, door open, speed threshold)
- interface with runtime configuration module
- station detection logic
- prioritization: some tasks may have highter safety priority (e.g, alarm or emergency audio)

## External Display Driver

**Responsibilities**

- send visual output to external displays
- uses static config and runtime config (current content, alerts, ..)
- comm protocol?: does it also have ip or not


## NVR Responsibilty Overview [v1]

## Dive into Each Component and interactions

## Sensor Collector

The **SensorCollector’s** role is to periodically read data from the peripherals and update the
**StateManager**. To test it, we can create fake devices that simulate sensor values changing over
time. The **SensorCollector** should then send updates to the **StateManager** and in the test we
can print these updates to verify it works look at _./tests/sensor_collector.go_

## External Data Collector

The **ExternalDataCollector** is triggerd by events from **StateManager**. when triggered, it reads
the relevent configuration from the **StateManager** to know how to reach the external system. it
then fetches the required data from the outer world. Once the data is received, it updates the
**StateManager** accordingly take look at _./tests/external_data_collector.go_

## Action Engine

The Action Engine is responsible for controlling external hardware. it periodically queries the
**StateManager** to retrieve changing runtime values (e.g temperature, speed, ..) and subscribes to


```
relevant events using this information, it updates external displays and controls the microphone or
other peripherals
```
## API SERVER

```
Config API
```
This Component of the API Server handles configuration requests from external clients. Upon
receiving a request, it updates the configuration section of the **StateManager** changes might
trigger events that subscribers such as the **Action Engine** or **External Data Collector** can
adjust their behavior immediatly for example ip of centralhas changed or some threshold has
changed

```
Internal API
```
This Component of the API Server serves request from internal peripherals. When a device, such
as a display, request information, the API reads the current state from the **StateManager** and
returns the relevant data for the device to operate correctly

```
Telemetry API
```
This Component of the API server exposes a subset for the system state that is permitted to leave
the local environment. it retrieves data from the **StateManager** and formats it as needed to
optimize transimission to remote clients

## State Manager

The **StateManager** serves as the systems’s authoritive source of truth. It aggergates data
from sensors, configuration updates, and external sources, It provides thread-safe methods form
reading/writing state and broadcasts events to notify subscribers of change Maintaining stability
and consistency is crucial, as all other components relay on its data.


## NVR Responsibilty Overview [v1]

### NOTE ORANGE BOX IS NOT USED AT THIS POINT


## System States Diagram [v1]


