🌿 SkyFresh
SkyFresh is a premium full-stack e-commerce application designed for purchasing fresh fruits, juices, and fresh cuts. It features a modern, highly responsive Flutter frontend and a fast, scalable Node.js/Express backend powered by MongoDB.

✨ Features
Premium User Interface: A beautiful, responsive Flutter UI with custom animations, skeleton loaders, and intuitive navigation.

Server-Side Search & Filtering: Case-insensitive, debounced real-time search and category filtering to minimize local processing and reduce data usage.

Cart & State Management: Seamless cart additions and total calculations managed via Provider.

User Profiles: Authenticated user profiles with order history and address management.

AI Integration: A dedicated AI screen for smart, personalized shopping assistance.

🛠️ Tech Stack
Frontend (Mobile App)
Framework: Flutter / Dart

State Management: Provider

Local Storage: Shared Preferences

API Integration: Standard Dart http package

Backend (Server)
Environment: Node.js

Framework: Express.js

Database: MongoDB

ODM: Mongoose

🚀 Getting Started
Follow these instructions to set up the project locally on your machine.

Prerequisites
Ensure you have the following installed:

Flutter SDK

Node.js

MongoDB (Local instance or MongoDB Atlas URI)

1. Backend Setup
Navigate to the backend directory:


cd backend
Install dependencies:


npm install
Create a .env file in the root of the backend directory and configure your environment variables:

Code snippet
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret_key
Start the server:


npm run dev
# or
node server.js
2. Frontend Setup
Navigate to the Flutter app directory:


cd skyfresh
Fetch the Flutter packages:

Bash
flutter pub get
Update the API Base URL:
Open lib/api_service.dart and ensure the base URL points to your local machine's IP address (if testing on a physical device) or localhost/10.0.2.2 (if using an emulator).

Run the app:


flutter run


📁 Project Structure
Frontend (/lib)
/models: Data models (e.g., user_profile.dart)

/screens: UI screens (home_screen.dart, cart_screen.dart, profile_screen.dart, etc.)

api_service.dart: Handles all HTTP requests to the backend.

cart_provider.dart: Global state management for the shopping cart.

theme.dart: Centralized app styling, colors, and gradients.

Backend
/controllers: Logic for handling incoming requests (auth, products, users).

/models: Mongoose database schemas.

/routes: Express route definitions.

server.js: Application entry point.
