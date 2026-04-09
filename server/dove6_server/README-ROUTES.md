# How to change the route

## Step 1 — Open routes.json
Edit the file routes.json in this folder.

## Step 2 — Change active_route
Find this line at the top:
  "active_route": "marrakech_tanger"

Change the value to any route key listed in "routes".
Available routes:
  marrakech_tanger   — Marrakech → Tanger Ville (18 stations)
  casa_fes           — Casa Voyageurs → Fès (7 stations)
  casa_marrakech     — Casa Voyageurs → Marrakech (4 stations)

Example — to run Casa → Fès:
  "active_route": "casa_fes"

## Step 3 — Add a new route (optional)
Copy any existing route block inside "routes".
Give it a new key.
Fill in the station names in French and Arabic.
Set active_route to your new key.

## Step 4 — Start the server
cd dove6_server
go run .

The server will print which route it loaded.
