require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const paymentRoutes = require('./routes/paymentRoutes');
const { router: authRouter } = require('./routes/auth');

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

const PORT = process.env.PORT || 5000;

// Connect to MongoDB & Start Server
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/skyfresh';
mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch((err) => console.error('MongoDB connection error:', err));