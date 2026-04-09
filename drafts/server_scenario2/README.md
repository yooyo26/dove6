```
🚄 DOVE6 — Passenger Information Display System
```

---

## 🖥️ What is this server?

This is a fake train data server that runs on a laptop and simulates a full train journey from Casa Voyageurs to Tanger Ville. It plays through each step of the journey automatically and the Flutter display app reads from it every 2 seconds.

Think of it as a pretend train brain — it tells the display app exactly what is happening at every moment of the trip.

---

## 📦 What you need installed

You need the **Go** programming language on your computer.

Download it here: **https://go.dev**

If you are on Ubuntu Linux, you can also install it with this command:

```bash
sudo apt install golang-go
```

---

## ▶️ How to run the server

Open a terminal and run these two commands in order:

**Step 1** — go into the server folder:
```bash
cd dove6_server
```

**Step 2** — start the server:
```bash
go run .
```

You will see a box appear in your terminal like this:

```
┌─────────────────────────────────────────┐
│         DOVE6 NVR Server v1.0           │
│                                         │
│  GET /state        current train state  │
│  GET /health       connectivity check   │
│  GET /jump?step=N  jump to step N       │
│                                         │
│  Listening on http://0.0.0.0:8080       │
└─────────────────────────────────────────┘
```

This means the server is running and ready. It will automatically move through each step of the journey every 5 seconds, and print a line to your terminal each time it advances.

---

## 🌐 How to find your laptop IP address

The Flutter app needs to know your laptop's IP address to connect to this server. Run this command in a terminal:

```bash
ip addr | grep "inet "
```

Look for a number in the output that looks like `192.168.x.x` or `172.x.x.x` — that is your IP address. Copy that number and paste it into the Flutter app's `lib/main.dart` file as the `nvrIp` value.

---

## 🔌 The three endpoints explained

An "endpoint" is just a web address the app can call. Here are the three this server provides:

**`GET /state`**
This is what the Flutter app calls every 2 seconds to get the current train data — the state, speed, station names, and journey progress. You don't need to call this yourself.

**`GET /health`**
A quick check to confirm the server is alive and responding. It just replies with `{"status":"ok"}`. Useful for troubleshooting connection problems.

**`GET /jump?step=N`**
Lets you jump to any step of the journey instantly — great for demos. Open your browser and type the address with a step number at the end.

---

## 🎬 How to demo a specific screen

To jump to any screen instantly, open a web browser while the server is running and type one of these addresses:

```
http://localhost:8080/jump?step=0
```

Replace `0` with the step number you want. Here is the full list:

| Step | State | What it shows |
|---|---|---|
| 0 | `IDLE` | Welcome screen with clock |
| 1 | `ROUTE_SELECTED` | Route overview before departure |
| 2 | `AT_STATION` | Stopped at Casa Voyageurs |
| 3 | `DEPARTING` | Leaving Casa Voyageurs |
| 4 | `MOVING` | Travelling at 120 km/h |
| 5 | `MOVING` | Travelling at 175 km/h |
| 6 | `ARRIVING` | Slowing down for Rabat Agdal |
| 7 | `AT_STATION` | Stopped at Rabat Agdal |
| 8 | `DEPARTING` | Leaving Rabat Agdal |
| 9 | `MOVING` | Travelling at 150 km/h |
| 10 | `MOVING` | Travelling at 185 km/h |
| 11 | `ARRIVING` | Slowing down for Kenitra |
| 12 | `AT_STATION` | Stopped at Kenitra |
| 13 | `DEPARTING` | Leaving Kenitra |
| 14 | `MOVING` | Travelling at 160 km/h |
| 15 | `MOVING` | Travelling at 195 km/h |
| 16 | `ARRIVING` | Slowing down for Tanger Ville |
| 17 | `AT_STATION` | Stopped at Tanger Ville (final) |
| 18 | `END_OF_ROUTE` | Thank you screen |

---

## ✏️ How to change the route

The only file you need to edit is `journer.go`. Open it in any text editor.

At the top you will find the list of stations:

```go
var route = []string{
    "Casa Voyageurs",
    "Rabat Agdal",
    "Kenitra",
    "Tanger Ville",
}
```

Add or remove station names here to change the route. Each name must be inside double quotes and separated by a comma.

To make the journey steps advance faster or slower, find this line near the very top of the file:

```go
const stepDuration = 5 * time.Second
```

Change `5` to a smaller number (like `2`) to speed it up, or a larger number (like `10`) to slow it down.

---

## ⏹️ How to stop the server

Simply press **Ctrl + C** in the terminal where the server is running. You will see:

```
[DOVE6] Server stopped cleanly.
```

That's it — the server is off. 👍

---

## 💾 How to save your work to GitHub

Run these three commands in order from the project folder:

```bash
git add .
```
```bash
git commit -m "your message here"
```
```bash
git push
```

Replace `"your message here"` with a short description of what you changed, like `"add new station to route"`.

---

## 🆘 Need help?

If something is not working or you have a question, contact the development team. We are happy to help! 😊
