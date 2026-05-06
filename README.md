# Vehicle Rental Service Platform — Vehicle Management Component

**Module:** SE1020 – Object Oriented Programming
**Student:** Sankalpa T.W.K.S.D — **IT22564290** (Member 22)
**Component:** Vehicle Management

## Overview
Individual contribution to the group project **Vehicle Rental Service Platform**.
This module manages the rental fleet — Cars, Bikes and Vans — with full CRUD
operations backed by **file read/write** (no database), as required by the
assignment brief.

## CRUD Operations Implemented
| Operation | Description | File |
|-----------|-------------|------|
| **Create** | Add a new vehicle | `vehicles.txt` (append) |
| **Read**   | List all & search by brand/model/type/id | `vehicles.txt` (read) |
| **Update** | Modify vehicle details (rate, availability, specs) | `vehicles.txt` (rewrite) |
| **Delete** | Remove a vehicle from the fleet | `vehicles.txt` (rewrite) |

## OOP Concepts Applied
- **Encapsulation** — `Vehicle` keeps fields `private` with getters/setters.
- **Inheritance** — `Car`, `Bike`, `Van` all extend the abstract `Vehicle` class.
- **Polymorphism** — `getDisplayInfo()` and `toFileString()` are overridden per
  subclass, so `List<Vehicle>` rendering / persistence works without `instanceof`.
- **Abstraction** — `Vehicle` is `abstract`; `VehicleDAO` hides file-handling
  details from the servlet.

## UI Pages (≥ 3 — assignment requirement)
1. `index.jsp` — Home / dashboard
2. `listVehicles.jsp` — Vehicle listing + search (Read)
3. `addVehicle.jsp` — Add new vehicle (Create)
4. `editVehicle.jsp` — Edit existing vehicle (Update)

## Tech Stack
- Java 11, Servlet 4.0, JSP 2.3
- Bootstrap 5 (CDN) for responsive UI
- Maven (`war` packaging)
- Tomcat 9 / 10 for deployment

## Data File Location
On startup the servlet creates / reads:
```
<USER_HOME>/vrp_data/vehicles.txt
```
A sample copy is provided at `data/vehicles.txt` — copy it there before first run
to demo with seeded records.

### File format
Pipe-delimited; first column is the subclass discriminator:
```
Type|id|brand|model|year|dailyRate|available|extra1|extra2
Car|C001|Toyota|Aqua|2019|6500.0|true|5|Automatic
Bike|B001|Yamaha|FZ|2022|2500.0|true|150|Sport
Van|V001|Toyota|HiAce|2018|12000.0|true|800|12
```

## How to Build & Run
1. Open the `VehicleRentalPlatform` folder in **IntelliJ IDEA** as a Maven project.
2. Build the WAR:
   ```
   mvn clean package
   ```
3. Deploy `target/VehicleRentalPlatform.war` to **Tomcat 9**.
4. Open <http://localhost:8080/VehicleRentalPlatform/>.

## Project Structure
```
VehicleRentalPlatform/
├── pom.xml
├── data/vehicles.txt              <- sample data
├── src/main/java/com/vrp/
│   ├── model/   Vehicle, Car, Bike, Van
│   ├── dao/     VehicleDAO   (file I/O CRUD)
│   └── servlet/ VehicleServlet (front controller)
└── src/main/webapp/
    ├── index.jsp
    ├── listVehicles.jsp
    ├── addVehicle.jsp
    ├── editVehicle.jsp
    ├── css/style.css
    └── WEB-INF/web.xml
```

## Class Diagram (textual)
```
            ┌──────────────┐
            │  «abstract»  │
            │   Vehicle    │
            ├──────────────┤
            │ - id         │
            │ - brand      │
            │ - model      │
            │ - year       │
            │ - dailyRate  │
            │ - available  │
            ├──────────────┤
            │ + getType()           «abstract»
            │ + getDisplayInfo()    «abstract»
            │ + toFileString()      «abstract»
            └──────┬───────┘
        ┌─────────┼─────────┐
        ▼         ▼         ▼
    ┌───────┐ ┌───────┐ ┌───────┐
    │  Car  │ │ Bike  │ │  Van  │
    ├───────┤ ├───────┤ ├───────┤
    │ seats │ │engCC  │ │cargo  │
    │ trans │ │bType  │ │paxCap │
    └───────┘ └───────┘ └───────┘

    ┌────────────────┐         ┌─────────────────┐
    │ VehicleServlet │ ──────▶ │   VehicleDAO    │
    │ (front ctrl)   │         │ (file CRUD)     │
    └────────────────┘         └─────────────────┘
```
