# 🌿 SkyFresh E-Commerce & Fresh Produce App

A centralized full-stack mobile application designed to digitize premium grocery shopping, replacing traditional local shopping with a secure, highly responsive digital platform.
The system enables users to browse fresh produce, manage their cart, filter items in real-time, maintain delivery addresses, and track order history through a unified mobile interface.

## ✨ Features

### 🔐 Authentication & Authorization
* Secure JWT-based authentication
* Protected API routes
* Persistent login sessions via SharedPreferences
* OTP verification support (Backend ready)

### 👥 User Roles

#### 👑 Administrator (Backend)
* Manage user profiles
* Manage product catalog (Fruits, Juices, Fresh Cuts)
* View operational dashboards and sales analytics
* Monitor order fulfillments

#### 👤 Customer (Mobile App)
* Update profile and addresses
* Browse curated product catalogs
* Search and filter items in real-time
* Manage shopping cart and quantities
* Place orders and view history
* Interact with AI Shopping Assistant

## 📊 Modules
* User Authentication & Registration
* Driver/Delivery Profile (Extensible)
* Product Catalog & Real-time Search
* Category Filtering
* Cart & State Management
* Order Management
* Address Management
* AI Assistant Interface
* Notifications Interface
* User Profile Dashboard

## 🛠 Tech Stack

**Frontend (Mobile)**
* Flutter
* Dart
* Provider (State Management)
* SharedPreferences
* HTTP (API Integration)
* Material Design Theme

**Backend (Server)**
* Node.js
* Express.js
* MongoDB
* Mongoose
* JWT Authentication
* bcrypt
* Cors
* Dotenv

## 📁 Project Structure

```text
SkyFresh/
│
├── backend/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── server.js
│   ├── package.json
│   └── .env.example
│
├── frontend (Flutter)/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── api_service.dart
│   │   ├── cart_provider.dart
│   │   ├── theme.dart
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md

