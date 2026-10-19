# 🛒 Gadget World

<div align="center">

![Gadget World Banner](https://img.shields.io/badge/Gadget%20World-E--Commerce%20Platform-6C63FF?style=for-the-badge&logo=flutter&logoColor=white)

**A full-stack gadget e-commerce platform built with Flutter, Dart/Shelf & Next.js**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![Next.js](https://img.shields.io/badge/Next.js-16-black?style=flat-square&logo=next.js)](https://nextjs.org)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat-square&logo=supabase)](https://supabase.com)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat-square&logo=docker)](https://docker.com)

</div>

---

## 📖 About

**Gadget World** is a modern, feature-rich e-commerce marketplace designed for buying and selling electronic gadgets. The platform spans three separate applications — a **Flutter-based mobile/web storefront**, a **Dart/Shelf REST API backend**, and a **Next.js admin dashboard** — all powered by Supabase as the database and auth layer.

Whether you're a customer browsing the latest smartphones and laptops or an admin managing inventory and orders, Gadget World provides a seamless, end-to-end experience.

---

## ✨ Features

### 🛍️ Customer App (Flutter)

#### Onboarding & Authentication
- 📲 Beautiful onboarding flow introducing the app
- 🔐 Email/password login & registration
- 🔑 Google Sign-In (OAuth)
- 📧 OTP-based email verification via `smart_auth`
- 🔒 Secure session management with `shared_preferences`

#### Product Discovery
- 🏠 Rich Home screen with featured banners and category highlights
- 🔍 Full-text product search with real-time results (`search_results_screen`)
- 📂 Browse by category (Mobiles, Laptops, and more)
- ⭐ Best Sellers, New Arrivals & Featured Products sections
- 🖼️ High-quality images with `cached_network_image` for performance
- 📄 Detailed product pages with specs, reviews & related products

#### Shopping Cart & Checkout
- 🛒 Add to cart, adjust quantities, remove items
- 🎟️ Coupon/discount code support
- 📦 Multiple delivery address management (add, edit, select)
- 💳 Razorpay payment gateway integration (web-optimized via `razorpay_web`)
- 📑 PDF invoice generation with `pdf` & `printing` packages
- ✅ Order confirmation screen with summary

#### Orders & Tracking
- 📋 Full order history with status tracking
- 🔎 Detailed per-order view (items, pricing, timeline)
- 🔄 Reorder functionality for quick repeat purchases

#### User Profile
- 👤 View & edit personal profile with avatar upload (`image_picker`)
- 🏠 Manage saved addresses
- ⚙️ Settings screen (notifications, preferences, account management)
- 🔗 Share products via `share_plus`

#### UX & Design
- 🎨 Custom theme using Google Fonts & Phosphor Icons
- ✨ Lottie animations for loading & onboarding states
- 🕐 Human-readable timestamps with `timeago`
- 📱 Cross-platform: Android, iOS, Web, Windows, Linux, macOS

---

### ⚙️ Backend API (Dart / Shelf)

- 🚀 Lightweight REST API built with `shelf` & `shelf_router`
- 🔐 Auth endpoints (register, login, token validation)
- 🛍️ Products API (list, filter by category, search)
- 🛒 Cart management (add, update, remove)
- 📦 Orders API (create, list, detail)
- 👤 User profile & address management
- 🎟️ Coupons & discount validation
- 💳 Payment processing & Razorpay webhook handling
- 🗄️ Supabase integration for database operations
- 🔒 `crypto` package for secure hashing
- 🐳 Dockerized for easy deployment

---

### 🖥️ Admin Dashboard (Next.js)

- 🔒 Secure admin-only login via Supabase SSR auth
- 📊 Overview dashboard with real-time KPIs
- 📦 **Products Management** — Add, edit, delete products with images
- 🏷️ **Categories Management** — Organize product taxonomy
- 🏢 **Brands Management** — Manage gadget brands
- 📋 **Orders Management** — View, update, and process orders
- 👥 **Users Management** — Browse registered customers
- 🎟️ **Coupons Management** — Create and manage discount codes
- 🎧 **Support** — Customer support ticket management
- 🌐 Built with Next.js 16 (App Router), React 19, TypeScript & TailwindCSS v4

---

## 🏗️ Architecture

```
gadget-world/
├── frontend/               # Flutter app (Customer Storefront)
│   ├── lib/
│   │   ├── core/           # Theme, navigation, shared widgets
│   │   ├── features/
│   │   │   ├── auth/       # Login, registration, OTP
│   │   │   ├── home/       # Home screen, banners
│   │   │   ├── products/   # Product listing & details
│   │   │   ├── cart/       # Cart management
│   │   │   ├── checkout/   # Address, payment, confirmation
│   │   │   ├── orders/     # Order history & tracking
│   │   │   ├── payments/   # Razorpay integration
│   │   │   ├── profile/    # User profile & settings
│   │   │   ├── more/       # Misc features
│   │   │   └── onboarding/ # Intro screens
│   │   └── main.dart
│   └── assets/             # Images & Lottie animations
│
├── backend/                # Dart/Shelf REST API
│   ├── bin/server.dart     # Entry point
│   ├── lib/
│   │   ├── core/           # Middleware, utilities
│   │   └── features/
│   │       ├── auth/       # Auth routes & handlers
│   │       ├── products/   # Products routes
│   │       ├── cart/       # Cart routes
│   │       ├── payments/   # Payment & webhook routes
│   │       ├── coupons/    # Coupon routes
│   │       ├── address/    # Address routes
│   │       └── profile/    # Profile routes
│   └── Dockerfile
│
└── admin/                  # Next.js Admin Dashboard
    └── src/
        ├── app/
        │   ├── (dashboard)/
        │   │   └── admin/
        │   │       ├── products/
        │   │       ├── categories/
        │   │       ├── brands/
        │   │       ├── orders/
        │   │       ├── users/
        │   │       ├── coupons/
        │   │       └── support/
        │   ├── auth/
        │   └── login/
        ├── components/
        └── lib/
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile / Web App | Flutter (Dart) |
| State Management | Provider |
| Backend API | Dart + Shelf + Shelf Router |
| Admin Panel | Next.js 16, React 19, TypeScript |
| Database & Auth | Supabase (PostgreSQL) |
| Payment Gateway | Razorpay |
| Styling (Admin) | TailwindCSS v4 |
| Fonts & Icons | Google Fonts, Phosphor Icons |
| Containerization | Docker |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart ≥ 3.12)
- [Dart SDK](https://dart.dev/get-dart) (≥ 3.0)
- [Node.js](https://nodejs.org/) (≥ 18) & npm
- [Supabase](https://supabase.com) project credentials
- [Razorpay](https://razorpay.com) API keys

---

### 📱 Frontend (Flutter App)

```bash
cd frontend

# Install dependencies
flutter pub get

# Copy and configure environment variables
cp .env.example .env
# Fill in SUPABASE_URL, SUPABASE_ANON_KEY, RAZORPAY_KEY, BACKEND_URL

# Run on a connected device or emulator
flutter run

# Run on web (Chrome) at port 3000
flutter run -d chrome --web-port 3000

# Windows shortcut
.\\start.ps1
```

---

### 🔧 Backend (Dart / Shelf API)

```bash
cd backend

# Install dependencies
dart pub get

# Configure environment variables
cp .env.example .env
# Fill in SUPABASE_URL, SUPABASE_SERVICE_KEY, RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET

# Start the server
dart run bin/server.dart
```

**Docker deployment:**

```bash
cd backend
docker build -t gadget-world-backend .
docker run -p 8080:8080 --env-file .env gadget-world-backend
```

---

### 🖥️ Admin Dashboard (Next.js)

```bash
cd admin

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env.local
# Fill in NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY

# Run in development mode
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## 🌐 Environment Variables

### Frontend (`frontend/.env`)

| Variable | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous public key |
| `BACKEND_URL` | URL of the Dart backend API |
| `RAZORPAY_KEY` | Razorpay publishable key |

### Backend (`backend/.env`)

| Variable | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Supabase service role key |
| `RAZORPAY_KEY_ID` | Razorpay key ID |
| `RAZORPAY_KEY_SECRET` | Razorpay key secret |
| `PORT` | Server port (default: `8080`) |

### Admin (`admin/.env.local`)

| Variable | Description |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (server-side only) |

---

## 📦 Key Dependencies

### Flutter Frontend

| Package | Purpose |
|---|---|
| `supabase_flutter` | Database, auth & realtime |
| `provider` | State management |
| `razorpay_web` | Payment gateway |
| `google_sign_in` | OAuth login |
| `image_picker` | Avatar upload |
| `google_fonts` | Typography |
| `lottie` | Animations |
| `cached_network_image` | Performance image loading |
| `pdf` + `printing` | Invoice generation |
| `share_plus` | Product sharing |
| `smart_auth` | OTP verification |
| `timeago` | Relative timestamps |

### Dart Backend

| Package | Purpose |
|---|---|
| `shelf` + `shelf_router` | HTTP server & routing |
| `supabase` | Database operations |
| `crypto` | Secure hashing |
| `http` | HTTP client |
| `dotenv` | Environment config |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is private and proprietary. All rights reserved © Tensorik Tech.

---

<div align="center">
  Built with ❤️ by <a href="https://github.com/AnshikaMoudgil">AnshikaMoudgil</a> & the <strong>Tensorik Tech</strong> team
</div>
