```
🚄 DOVE6 — Passenger Information Display System
```

---

## 🖥️ What is this app?

Dove6 is a passenger information display app for a train. It shows the current train state on a full-screen dark display — things like the current station, speed, next stop, and arrival progress.

It runs on a Linux laptop and reads live data from the Go server, or it can run a built-in simulation without any server at all.

---

## 📦 What you need installed

You need **Flutter** on your computer. Flutter is the tool that builds and runs this app.

Download it here: **https://flutter.dev**

> We recommend Flutter version **3.x or newer**. The download page will guide you through installation step by step.

---

## 🌐 How to configure the server IP address

Before running the app in live mode, you need to tell it where the Go server is running. Open the file `lib/main.dart` in any text editor.

Find this line near the top:

```dart
const String nvrIp = '127.0.0.1';
```

Replace `127.0.0.1` with your laptop's actual IP address. To find your IP address, open a terminal and run:

```bash
ip addr | grep "inet "
```

Look for a number that looks like `192.168.x.x` or `172.x.x.x` — that is your IP. After editing, the line should look something like this:

```dart
const String nvrIp = '192.168.1.42';
```

Save the file and you're ready to go. 🎉

---

## ▶️ How to run the app

Open a terminal, go into this folder, and run these two commands in order:

**Step 1** — download the app's dependencies:
```bash
flutter pub get
```

**Step 2** — launch the app:
```bash
flutter run -d linux
```

A window will open on your screen showing the full train display. That's it!

---

## 🔀 How to switch between simulation and real server

Open `lib/main.dart` and find this line:

```dart
const bool useLocalSimulation = false;
```

- Set it to **`true`** → the app runs a built-in fake journey. No server needed. Great for testing offline.
- Set it to **`false`** → the app reads real data from the Go server running on your laptop.

Just change the word and save the file. Then run the app again.

---

## 📺 What each screen shows

Here is what a passenger sees on each screen:

| State | What the passenger sees |
|---|---|
| 🟤 **Idle** | A clock showing the current time and a "Welcome aboard" message. |
| 🗺️ **Route Selected** | The full journey route from origin to destination, with all stops listed. |
| 🚉 **At Station** | The current station name in large letters, with the next stop and destination shown below. |
| 🚀 **Departing** | A "Welcome aboard" message and the name of the station the train is leaving. |
| ⚡ **Moving (speed)** | The train's current speed in huge gold numbers — shown for the first 5 seconds. |
| 📊 **Moving (progress)** | The percentage of the journey completed, with the route progress bar. |
| 🔵 **Arriving** | "Arriving at [station]" in large blue text, with a progress bar filling up. |
| 📍 **Arrived** | A location pin icon and "Arrived at [station]" — shown briefly for 3 seconds. |
| 🏁 **End of Route** | "Thank you for travelling with us" and the terminal station name. |

---

## 📁 Folder structure explained

Here is what each folder does in plain words:

| Folder | What it does |
|---|---|
| `lib/domain/` | Defines the basic building blocks — what a train state is, and what data each screen needs. |
| `lib/data/` | Handles getting that data — either from the fake simulation or by asking the Go server every 2 seconds. |
| `lib/presentation/` | Everything visual — the screens, colours, and the logic that decides which screen to show. |

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

Replace `"your message here"` with a short description of what you changed, like `"update server IP address"`.

---

## 🆘 Need help?

If something is not working or you have a question, contact the development team. We are happy to help! 😊
