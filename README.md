# 🍽️ SaveFood

**Save Food, Save Future.**

SaveFood is a food rescue marketplace mobile application built with Flutter & Dart. It connects food businesses with customers to reduce food waste. Restaurants, bakeries, cafes, and small culinary businesses can sell surplus food at discounted prices.

## 🎯 Key Features

- **Customers** — Browse discounted food, search by name/category, discover nearby merchants, place orders, and pick up directly from the merchant.
- **Merchants** — Upload surplus food listings, set discounted prices, manage stock and pickup deadlines, and handle incoming orders.
- **Admin** — Dashboard, user management, merchant verification, food listing moderation, and food rescue statistics.

## 🛠️ Technology Stack

| Layer | Technology | Repository |
|-------|-----------|------------|
| Mobile App | Flutter & Dart | This repo (`savefood`) |
| REST API | Laravel (PHP) | Separate project (`restAPI savefood`) |
| Database | MySQL | Via Laragon |
| Local Server | Laragon | — |

## 📁 Project Structure

```
savefood/                   ← Flutter Mobile App
├── lib/
│   ├── core/               (constants, theme, network, routing, utils)
│   ├── shared/             (reusable widgets, shared models)
│   ├── features/           (auth, customer, food, orders, merchant, admin, profile)
│   └── main.dart
├── assets/
│   ├── images/
│   └── fonts/
├── android/
├── ios/
├── docs/
│   ├── database-design/
│   └── api-documentation/
├── pubspec.yaml
└── README.md
```

## 🔗 Related Repository

The backend REST API is a separate Laravel project located at:
```
C:\laragon\www\restAPI savefood
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Android Emulator or physical device
- Backend REST API running (Laravel)

### Setup

```bash
flutter pub get
flutter run
```

## 📝 Transaction Model

**Pickup Only** — Customers must collect their orders directly from the merchant location.

## 👤 Authors

- RafiAF29

## 📄 License

This project is for educational purposes.
