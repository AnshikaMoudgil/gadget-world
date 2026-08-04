# Tensorik GadgetWorld

A modern gadget e-commerce marketplace built with Flutter (frontend) and Dart/Shelf (backend).

## Tech Stack

- **Frontend**: Flutter (Dart) — 32+ screens covering onboarding, auth, product browsing, cart, checkout, orders, profile, and more
- **Backend**: Dart with Shelf framework — REST API scaffolding

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK

### Frontend

```bash
cd frontend
flutter pub get

# To run on desktop or mobile device
flutter run

# To run on web using the provided script (Windows)
.\start.ps1

# Or manually run on web
flutter run -d chrome --web-port 3000
```

### Backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

## Project Structure

```
gadget-world/
├── backend/          # Dart Shelf API server
│   └── bin/server.dart
├── frontend/         # Flutter mobile/web app
│   ├── lib/
│   │   ├── core/     # Theme, shared widgets
│   │   ├── screens/  # 32 screens
│   │   └── main.dart
│   └── test/
└── README.md
```
