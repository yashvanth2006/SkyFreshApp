require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const admin = require('firebase-admin');

const paymentRoutes = require('./routes/paymentRoutes');
const { router: authRouter } = require('./routes/auth');

// Initialize Firebase Admin SDK (with fallback if service account is missing)
let firebaseAdmin = null;
try {
  const serviceAccount = require('./firebase-service-account.json');
  firebaseAdmin = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('Firebase Admin SDK initialized');
} catch (err) {
  console.log('Firebase Admin SDK not initialized (firebase-service-account.json not found)');
  console.log('FCM notifications will be disabled');
}

const app = express();

// Allow requests from React frontend ports (3000, 3001, etc.)
app.use(
  cors({
    origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:3001'],
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