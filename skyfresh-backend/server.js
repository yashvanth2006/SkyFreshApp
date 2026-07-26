require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { initializeApp, cert } = require('firebase-admin/app');

const paymentRoutes = require('./routes/paymentRoutes');
const { router: authRouter } = require('./routes/auth');

// Initialize Firebase Admin SDK (with fallback if service account is missing)
let firebaseAdmin = null;
try {
  let serviceAccount;
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    // Parse the JSON string from Render environment variables
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    console.log('Firebase Admin SDK initialized via environment variable');
  } else {
    // Fallback for local development
    serviceAccount = require('./firebase-service-account.json'); // Ensure this is a relative path now!
    console.log('Firebase Admin SDK initialized via local file');
  }

  firebaseAdmin = initializeApp({
    credential: cert(serviceAccount)
  });
} catch (err) {
  console.error('Firebase Admin SDK initialization error:', err.message);
  console.log('FCM notifications will be disabled');
}

const app = express();

// Allow requests from React frontend ports and production admin panel
app.use(
  cors({
    origin: ['http://localhost:3000', 'https://skyfresh-admin.onrender.com'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
);

app.use(express.json());

// API Routes
app.use('/api/payments', paymentRoutes);
app.use('/api/auth', authRouter);
app.use('/api/users', authRouter); // Uses authRouter correctly
app.use('/api/products', require('./routes/products'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/ai', require('./routes/ai'));
app.use('/api/notifications', require('./routes/notifications'));

// Make firebase admin available globally for routes
global.firebaseAdmin = firebaseAdmin;

const PORT = process.env.PORT || 5000;

// Connect to MongoDB & Start Server
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/skyfresh';
mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err);
    console.log('Attempting to start server anyway...');
    app.listen(PORT, () => console.log(`Server running on port ${PORT} (without database)`));
  });