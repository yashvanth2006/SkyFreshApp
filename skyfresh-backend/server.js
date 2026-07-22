require('dotenv').config();
const express = require('express');
const paymentRoutes = require('./routes/paymentRoutes'); 
const mongoose = require('mongoose');
const cors = require('cors');


const app = express();

app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:3001'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));

app.use(express.json());
app.use('/api/payments', paymentRoutes);

// Routes
const { router: authRouter } = require('./routes/auth');
app.use('/api/auth', authRouter);
app.use('/api/products', require('./routes/products'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/serviceability', require('./routes/serviceability'));
app.use('/api/users', require('./routes/auth')); // Or wherever your users route is located

app.get('/', (req, res) => {
  res.json({ message: 'SKYfresh API is running smoothly 🌿' });
});

mongoose.connect(process.env.MONGODB_URI || process.env.MONGO_URI || 'mongodb://localhost:27017/skyfresh')
  .then(() => {
    console.log('✅ MongoDB connected successfully');
    app.listen(process.env.PORT || 5000, '0.0.0.0', () => {
      console.log(`🚀 Server running on port ${process.env.PORT || 5000}`);
    });
  })
  .catch((err) => {
    console.log('❌ MongoDB error:', err.message);
    console.log('🔄 Trying local MongoDB connection...');
    mongoose.connect('mongodb://localhost:27017/skyfresh')
      .then(() => {
        console.log('✅ Connected to local MongoDB');
        app.listen(process.env.PORT || 5000, '0.0.0.0', () => {
          console.log(`🚀 Server running on port ${process.env.PORT || 5000}`);
        });
      })
      .catch((localErr) => {
        console.error('❌ Local MongoDB connection failed:', localErr.message);
        console.log('💡 Make sure MongoDB is running locally');
      });
  });