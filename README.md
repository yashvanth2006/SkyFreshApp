🌿 SkyFresh E-Commerce & Fresh Produce App
A centralized full-stack mobile application designed to digitize premium grocery shopping, replacing traditional local shopping with a secure, highly responsive digital platform.
The system enables users to browse fresh produce, manage their cart, filter items in real-time, maintain delivery addresses, and track order history through a unified mobile interface.

✨ Features
🔐 Authentication & Authorization
Secure JWT-based authentication

Protected API routes

Persistent login sessions via SharedPreferences

OTP verification support (Backend ready)

👥 User Roles
👑 Administrator (Backend)
Manage user profiles

Manage product catalog (Fruits, Juices, Fresh Cuts)

View operational dashboards and sales analytics

Monitor order fulfillments

👤 Customer (Mobile App)
Update profile and addresses

Browse curated product catalogs

Search and filter items in real-time

Manage shopping cart and quantities

Place orders and view history

Interact with AI Shopping Assistant

📊 Modules
User Authentication & Registration

Driver/Delivery Profile (Extensible)

Product Catalog & Real-time Search

Category Filtering

Cart & State Management

Order Management

Address Management

AI Assistant Interface

Notifications Interface

User Profile Dashboard

🛠 Tech Stack
Frontend (Mobile)

Flutter

Dart

Provider (State Management)

SharedPreferences

HTTP (API Integration)

Material Design Theme

Backend (Server)

Node.js

Express.js

MongoDB

Mongoose

JWT Authentication

bcrypt

Cors

Dotenv

📁 Project Structure
Plaintext
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
⚙️ Prerequisites
Before running the application, ensure the following are installed:

Flutter SDK

Node.js (v18 or later recommended)

npm

MongoDB (Local or Atlas)

Android Studio / Xcode (for mobile emulators)

🚀 Installation
1. Clone Repository

Bash
git clone <repository-url>
cd SkyFresh
2. Install Backend Dependencies

Bash
cd backend
npm install
3. Install Frontend Dependencies

Bash
cd ../frontend
flutter pub get
🔧 Environment Configuration
Both frontend and backend require environment configuration.

Backend

Bash
cd backend
cp .env.example .env
Fill in your MONGO_URI, PORT, and JWT_SECRET.

Frontend

Open lib/api_service.dart.

Update the baseUrl to point to your local machine (e.g., [http://10.0.2.2:5000/api](http://10.0.2.2:5000/api) for Android emulators, or your local IP for physical devices).

Do not commit your .env files to version control.

▶️ Running the Project
Backend

Bash
cd backend
npm run dev
Frontend

Bash
cd frontend
flutter run
📦 Available Scripts
Frontend (Flutter)

flutter run - Runs the application on a connected device/emulator.

flutter build apk - Creates a production Android build.

flutter build ios - Creates a production iOS build.

flutter clean - Clears the build cache.

Backend (Node.js)

npm run dev - Starts the backend server with nodemon.

npm start - Starts the backend server in production mode.

🔐 Security Features
JWT Authentication

Password Hashing using bcrypt

Protected API Routes

Server-side query sanitization (MongoDB $regex)

Environment Variable Configuration

CORS Protection

📱 Mobile Architecture
The frontend leverages Flutter's cross-platform capabilities, utilizing Provider for reactive state management (Cart UI updates instantly) and debounced search inputs to optimize backend API calls.

📈 Core Functionalities
Real-time debounced product search

Server-side category filtering

Persistent shopping cart

Secure checkout and order placement

Dynamic address book

Skeleton loaders for seamless UI/UX

🧪 Development Workflow
Start MongoDB

Configure environment variables

Start backend Express server

Launch iOS/Android emulator

Start Flutter frontend

Login or register as a premium member

Access full-stack cart and checkout modules

🚀 Future Enhancements
Payment Gateway Integration (Stripe/Razorpay)

Real-time Delivery Tracking (WebSockets)

Push Notifications (Firebase Cloud Messaging)

Admin Web Panel (React.js)

Email/SMS Order Confirmations

Advanced Sales Analytics

🤝 Contributing
Fork the repository

Create a feature branch:

Bash
git checkout -b feature/new-feature
Commit your changes:

Bash
git commit -m "Add new feature"
Push the branch:

Bash
git push origin feature/new-feature
Open a Pull Request  

📄 License  
This project is intended for educational and commercial use. Add an appropriate license if you plan to distribute it publicly.  

👨‍💻 Author  
Your Name/Handle
Full Stack Mobile Developer
Flutter | Node.js | Express.js | MongoDB  

⭐ If you found this project useful, consider giving it a star on GitHub.
