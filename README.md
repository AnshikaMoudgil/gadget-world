# Tensorik GadgetWorld

A B2B gadget wholesale marketplace built with Flutter (frontend) and Dart/Shelf (backend).

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
flutter run
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
