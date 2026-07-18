# SKYfresh - Complete Project Structure Documentation

## Project Overview
SKYfresh is a fresh fruits and juices delivery application consisting of three main components:
- **Backend**: Node.js/Express API with MongoDB
- **Frontend**: Flutter mobile/web application
- **Admin Panel**: React.js dashboard for management

## Directory Structure

```
SkyFreshApp/
├── skyfresh-backend/          # Node.js/Express Backend API
│   ├── models/               # MongoDB Schemas
│   ├── routes/               # API Routes
│   ├── server.js             # Main Server File
│   ├── seed.js               # Database Seeding Script
│   └── package.json          # Backend Dependencies
├── skyfresh-frontend/        # Flutter Mobile/Web App
│   ├── lib/
│   │   ├── screens/         # UI Screens
│   │   ├── models/          # Data Models
│   │   ├── api_service.dart # API Integration
│   │   ├── cart_provider.dart # State Management
│   │   ├── theme.dart       # App Theme
│   │   └── main.dart        # App Entry Point
│   ├── pubspec.yaml         # Flutter Dependencies
│   └── web/
│       └── index.html       # Web Entry Point
└── skyfresh-admin/          # React Admin Panel
    ├── src/
    │   ├── components/      # React Components
    │   ├── pages/          # Admin Pages
    │   ├── App.js          # Main App Component
    │   └── index.js        # Entry Point
    └── package.json        # Admin Dependencies
```

---

## Backend (Node.js/Express)

### package.json
```json
{
  "name": "skyfresh-backend",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "type": "commonjs",
  "dependencies": {
    "bcryptjs": "^3.0.3",
    "cors": "^2.8.6",
    "dotenv": "^17.4.2",
    "express": "^5.2.1",
    "jsonwebtoken": "^9.0.3",
    "mongoose": "^9.7.3",
    "razorpay": "^2.9.8"
  }
}
```

### server.js
```javascript
require('dotenv').config();
const express = require('express');
const paymentRoutes = require('./routes/paymentRoutes'); 
const mongoose = require('mongoose');
const cors = require('cors');


const app = express();

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use('/api/payments', paymentRoutes);

// Routes
const { router: authRouter } = require('./routes/auth');
app.use('/api/auth', authRouter);
app.use('/api/products', require('./routes/products'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/serviceability', require('./routes/serviceability'));

app.get('/', (req, res) => {
  res.json({ message: 'SKYfresh API is running smoothly 🌿' });
});

mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB connected successfully');
    app.listen(process.env.PORT, () => {
      console.log(`🚀 Server running on port ${process.env.PORT}`);
    });
  })
  .catch((err) => console.log('❌ MongoDB error:', err));
```

### seed.js
```javascript
// Remove the hardcoded string and read from process.env
const PEXELS_KEY = process.env.PEXELS_KEY;
require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('./models/Product');

const PEXELS_KEY = 'dHPIVC9kk0FHyUKzNNMzaAa45UWwqJ1GQTsxMbTdBKwCjsczHIbniwWg';

async function getImage(query) {
  const encodedQuery = encodeURIComponent(query);
  const res = await fetch(
    `https://api.pexels.com/v1/search?query=${encodedQuery}&per_page=3&orientation=square`,
    { headers: { Authorization: PEXELS_KEY } }
  );
  const data = await res.json();

  if (!data.photos || data.photos.length === 0) {
    console.log(`⚠️  No image found for query: "${query}"`);
    return '';
  }

  return data.photos[0]?.src?.medium || '';
}

const products = [
  { name: 'Fresh Mango',       price: 60,  unit: '250g',  emoji: '🥭', category: 'Fruits',     stock: 50, color: '#FFF3CD', query: 'mango fruit closeup' },
  { name: 'Watermelon',        price: 40,  unit: '500g',  emoji: '🍉', category: 'Fresh Cuts', stock: 30, color: '#FFE4E4', query: 'watermelon slice fruit' },
  { name: 'Orange Juice',      price: 80,  unit: '300ml', emoji: '🍊', category: 'Juices',     stock: 25, color: '#FFEDD5', query: 'orange juice glass drink' },
  { name: 'Fresh Apple',       price: 50,  unit: '200g',  emoji: '🍎', category: 'Fruits',     stock: 40, color: '#FFE4E4', query: 'red apple fruit closeup' },
  { name: 'Mango Juice',       price: 90,  unit: '300ml', emoji: '🥭', category: 'Juices',     stock: 20, color: '#FFF3CD', query: 'mango juice smoothie glass' },
  { name: 'Pineapple',         price: 70,  unit: '300g',  emoji: '🍍', category: 'Fruits',     stock: 35, color: '#FFFDE7', query: 'pineapple fruit whole' },
  { name: 'Green Juice',       price: 100, unit: '300ml', emoji: '🥬', category: 'Juices',     stock: 15, color: '#DCFCE7', query: 'green vegetable juice glass' },
  { name: 'Mixed Fruit Bowl',  price: 120, unit: '400g',  emoji: '🍱', category: 'Fresh Cuts', stock: 20, color: '#EDE9FE', query: 'mixed fruit salad bowl' },
  { name: 'Banana',            price: 30,  unit: '200g',  emoji: '🍌', category: 'Fruits',     stock: 60, color: '#FFFDE7', query: 'banana fruit bunch' },
  { name: 'Pomegranate Juice', price: 110, unit: '300ml', emoji: '🍷', category: 'Juices',     stock: 18, color: '#FFE4E4', query: 'pomegranate juice glass red' },
];

mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    console.log('📸 Fetching images from Pexels...');

    const productsWithImages = await Promise.all(
      products.map(async (p) => {
        const image = await getImage(p.query);
        console.log(`✅ ${p.name} → ${image ? 'image fetched' : 'NO IMAGE (using emoji fallback)'}`);
        const { query, ...rest } = p;
        return { ...rest, image };
      })
    );

    await Product.deleteMany();
    await Product.insertMany(productsWithImages);
    console.log('✅ Products seeded with real images!');
    process.exit();
  })
  .catch(err => {
    console.log('❌ Error:', err);
    process.exit();
  });
```

### Models

#### models/Product.js
```javascript
const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  price: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    required: true
  },
  emoji: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: ['Fruits', 'Juices', 'Fresh Cuts'],
    required: true
  },
  stock: {
    type: Number,
    default: 50
  },
  color: {
    type: String,
    default: '#FFF3CD'
  },
  image: {
  type: String,
  default: ''
  },
  isAvailable: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
```

#### models/Order.js
```javascript
const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  name:     { type: String, required: true },
  price:    { type: Number, required: true }, // price per unit at time of order
  quantity: { type: Number, required: true },
  unit:     { type: String },
  emoji:    { type: String },
}, { _id: false });

const orderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  items: {
    type: [orderItemSchema],
    required: true,
    validate: v => Array.isArray(v) && v.length > 0,
  },
  subtotal:     { type: Number, required: true },
  deliveryFee:  { type: Number, required: true, default: 0 },
  total:        { type: Number, required: true },
  address:      { type: String, required: true },
  status: {
    type: String,
    enum: ['placed', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'placed',
  },
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
```

#### models/user.js
```javascript
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  otp: {
    type: String,
    default: null
  },
  otpExpiry: {
    type: Date,
    default: null
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  addresses: [{
    label: { type: String, default: 'Home', trim: true },
    line: { type: String, required: true, trim: true },
    isDefault: { type: Boolean, default: false },
  }],
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
```

### Routes

#### routes/auth.js
```javascript
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Order = require('../models/Order');

function getToken(req) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  return authHeader.split(' ')[1];
}

function requireAuth(req, res, next) {
  const token = getToken(req);
  if (!token) return res.status(401).json({ success: false, message: 'No token provided' });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

// Helper middleware to check if user is admin
async function requireAdmin(req, res, next) {
  try {
    const user = await User.findById(req.user.id);
    // Standard gate: First user or a designated number can act as admin
    if (!user || user.phone !== '8870682988') { 
      return res.status(403).json({ success: false, message: 'Access denied. Admins only.' });
    }
    next();
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server authorization error' });
  }
}

function formatUser(user, stats = {}) {
  return {
    id: user._id,
    name: user.name,
    phone: user.phone,
    joinedAt: user.createdAt,
    addresses: (user.addresses || []).map((a) => ({
      id: a._id, label: a.label, line: a.line, isDefault: a.isDefault,
    })),
    orderCount: stats.orderCount ?? 0,
  };
}

router.post('/register', async (req, res) => {
  try {
    const { name, phone, password } = req.body;
    const existing = await User.findOne({ phone });
    if (existing) return res.json({ success: false, message: 'Phone number already registered' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000);

    const user = new User({ name, phone, password: hashedPassword, otp, otpExpiry });
    await user.save();

    // Simulating production SMS gateway log
    console.log(`\n====================================`);
    console.log(`📲 SMS GATEWAY OUTBOX [TO: ${phone}]`);
    console.log(`Your SKYfresh verification OTP is: ${otp}`);
    console.log(`====================================\n`);

    res.json({ success: true, message: 'OTP sent successfully to your phone number.' });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    const user = await User.findOne({ phone });
    if (!user) return res.json({ success: false, message: 'User not found' });
    if (user.otp !== otp) return res.json({ success: false, message: 'Invalid OTP' });
    if (user.otpExpiry < new Date()) return res.json({ success: false, message: 'OTP expired' });

    user.isVerified = true;
    user.otp = null;
    user.otpExpiry = null;
    await user.save();

    const token = jwt.sign({ id: user._id, phone: user.phone }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ success: true, message: 'Phone verified successfully', token, user: { id: user._id, name: user.name, phone: user.phone } });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    const user = await User.findOne({ phone });
    if (!user) return res.json({ success: false, message: 'Phone number not registered' });
    if (!user.isVerified) return res.json({ success: false, message: 'Please verify your phone first' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.json({ success: false, message: 'Wrong password' });

    const token = jwt.sign({ id: user._id, phone: user.phone }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ success: true, message: 'Login successful', token, user: { id: user._id, name: user.name, phone: user.phone } });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('name phone createdAt addresses');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const orderCount = await Order.countDocuments({ user: user._id });

    res.json({ success: true, user: formatUser(user, { orderCount }) });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.post('/addresses', requireAuth, async (req, res) => {
  try {
    const { label, line, isDefault } = req.body;
    if (!line || !line.trim()) return res.json({ success: false, message: 'Address is required' });

    const user = await User.findById(req.user.id);
    if (!user) return res.json({ success: false, message: 'User not found' });

    if (isDefault || user.addresses.length === 0) user.addresses.forEach((a) => { a.isDefault = false; });

    user.addresses.push({ label: (label || 'Home').trim(), line: line.trim(), isDefault: isDefault === true || user.addresses.length === 0 });
    await user.save();

    const orderCount = await Order.countDocuments({ user: user._id });

    res.json({ success: true, message: 'Address saved', user: formatUser(user, { orderCount }) });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.delete('/addresses/:id', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.json({ success: false, message: 'User not found' });

    const address = user.addresses.id(req.params.id);
    if (!address) return res.json({ success: false, message: 'Address not found' });

    const wasDefault = address.isDefault;
    address.deleteOne();

    if (wasDefault && user.addresses.length > 0) user.addresses[0].isDefault = true;
    await user.save();

    const orderCount = await Order.countDocuments({ user: user._id });

    res.json({ success: true, message: 'Address removed', user: formatUser(user, { orderCount }) });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.patch('/addresses/:id/default', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.json({ success: false, message: 'User not found' });

    const address = user.addresses.id(req.params.id);
    if (!address) return res.json({ success: false, message: 'Address not found' });

    user.addresses.forEach((a) => { a.isDefault = false; });
    address.isDefault = true;
    await user.save();

    const orderCount = await Order.countDocuments({ user: user._id });

    res.json({ success: true, message: 'Default address updated', user: formatUser(user, { orderCount }) });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = { router, requireAuth, requireAdmin };
```

#### routes/orders.js
```javascript
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Order = require('../models/Order');
const User = require('../models/User');

// ── Auth middleware: verifies JWT and attaches user info to req.user
function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id, phone }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

// ── PLACE ORDER
router.post('/', requireAuth, async (req, res) => {
  try {
    const { items, subtotal, deliveryFee, total, address } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.json({ success: false, message: 'Cart is empty' });
    }
    if (!address || !address.trim()) {
      return res.json({ success: false, message: 'Delivery address is required' });
    }

    const order = new Order({
      user: req.user.id,
      items,
      subtotal,
      deliveryFee,
      total,
      address: address.trim(),
    });
    await order.save();

    const user = await User.findById(req.user.id);
    if (user) {
      const trimmed = address.trim();
      const exists = user.addresses.some((a) => a.line === trimmed);
      if (!exists) {
        if (user.addresses.length === 0) {
          user.addresses.push({ label: 'Home', line: trimmed, isDefault: true });
        } else {
          user.addresses.push({ label: 'Saved', line: trimmed, isDefault: false });
        }
        await user.save();
      }
    }

    res.json({ success: true, message: 'Order placed successfully', order, orderId: order._id });

  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── GET MY ORDERS (order history for logged-in user)
router.get('/my', requireAuth, async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── GET ALL ORDERS (for admin panel)
router.get('/', async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 }).populate('user', 'name phone');
    res.json({ success: true, orders });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── UPDATE ORDER STATUS (for admin panel)
router.patch('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ['placed', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.json({ success: false, message: 'Invalid status value' });
    }

    const order = await Order.findByIdAndUpdate(req.params.id, { status }, { new: true });
    if (!order) {
      return res.json({ success: false, message: 'Order not found' });
    }

    res.json({ success: true, message: 'Order status updated', order });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = router;
```

#### routes/products.js
```javascript
const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { requireAuth, requireAdmin } = require('./auth');

// Public route: Everyone can view products
router.get('/', async (req, res) => {
  try {
    const products = await Product.find();
    res.json({ success: true, products });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// Protected Route: Only Admins can append to the catalog
router.post('/add', requireAuth, requireAdmin, async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.json({ success: true, product });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// Protected Route: Only Admins can remove items from catalog
router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Product successfully deleted by admin.' });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

module.exports = router;
```

#### routes/paymentRoutes.js
```javascript
const express = require('express');
const Razorpay = require('razorpay');
const router = express.Router();

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Route to create a payment order
router.post('/create-order', async (req, res) => {
  try {
    const { amount } = req.body; // Amount from frontend

    const options = {
      amount: amount * 100, // Razorpay expects amount in paise (multiply by 100)
      currency: 'INR',
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);
    
    res.json({
      success: true,
      order: order,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Failed to create order' });
  }
});

module.exports = router;
```

#### routes/serviceability.js
```javascript
const express = require('express');
const router = express.Router();

// Coimbatore city center coordinates
const COIMBATORE_CENTER = {
  lat: 11.0168,
  lng: 76.9558
};

// Maximum serviceable radius in kilometers
const MAX_RADIUS_KM = 30; // Using 30km to cover all over Coimbatore including outskirts

// Haversine formula to calculate distance between two coordinates
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

// GET /api/serviceability/check?lat=X&lng=Y
router.get('/check', (req, res) => {
  try {
    res.json({
      serviceable: true,
      distance: 0,
      city: 'Global',
      message: 'Location is serviceable.'
    });
  } catch (error) {
    console.error('Serviceability check error:', error);
    res.status(500).json({ error: 'Failed to check serviceability' });
  }
});

module.exports = router;
```

---

## Frontend (Flutter)

### pubspec.yaml
```yaml
name: skyfresh
description: SKYfresh - Fresh fruits and juices
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  pin_code_fields: ^8.0.1
  cupertino_icons: ^1.0.6
  http: ^1.6.0
  shared_preferences: ^2.5.5
  cached_network_image: ^3.3.1
  provider: ^6.1.1
  geolocator: ^14.0.3
  geocoding: ^5.0.0
  url_launcher: ^6.3.1
  razorpay_flutter: ^1.4.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/screens/splash_screen.dart';

void main() {
  runApp(const SKYfreshApp());
}

class SKYfreshApp extends StatelessWidget {
  const SKYfreshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'SKYfresh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppTheme.bg,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.textMain),
            titleTextStyle: TextStyle(color: AppTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
```

### lib/theme.dart
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFF8FBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F8F5);
  static const Color surfaceMuted = Color(0xFFEAF4EA);
  static const Color surfaceAlt = Color(0xFFF0FDF4);

  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF86EFAC);

  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF4B5563);
  static const Color border = Color(0xFFD1D5DB);

  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1A10B981),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 24,
    offset: Offset(0, 10),
  );
}
```

### lib/api_service.dart
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyfresh/models/user_profile.dart'; 

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> login({String? phone, String? password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone ?? '', 'password': password ?? ''}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Login connection failed'};
    }
  }

  static Future<Map<String, dynamic>> registerUser(String name, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Registration connection failed'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Verification connection failed'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  static Future<UserProfile?> getProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return UserProfile.fromJson(data['user'] ?? data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['products'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['orders'] != null) {
        return List<Map<String, dynamic>>.from(data['orders']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // FIXED: Added "String? line" to the parameters and the fallback map!
  static Future<Map<String, dynamic>> addAddress({
    Map<String, dynamic>? addressData,
    String? address,
    String? addressLine,
    String? line, 
    String? title,
    String? label, 
    String? name,
    String? landmark,
    bool? isDefault,
  }) async {
    try {
      final token = await getToken();
      final Map<String, dynamic> finalBody = addressData ?? {
        'label': label ?? title ?? 'Home',
        'line': line ?? address ?? addressLine ?? '',
        'isDefault': isDefault,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(finalBody),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to add address'};
    }
  }

  static Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/addresses/$addressId/default'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to set default address'};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/addresses/$addressId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete address'};
    }
  }

  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required num subtotal,
    required num deliveryFee,
    required num total,
    required String address,
    String? paymentMethod, 
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'total': total,
          'address': address,
          'paymentMethod': paymentMethod ?? 'Cash on Delivery',
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Order placement failed'};
    }
  }
}
```

### lib/cart_provider.dart
```dart
import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String price;
  final String emoji;
  final String unit;
  final String weight;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.emoji,
    required this.unit,
    required this.weight,
    this.quantity = 1,
  });

  int get priceInt => int.parse(price.replaceAll('₹', ''));
  int get total => priceInt * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(Map<String, dynamic> product, {String? weight}) {
    final selectedWeight = weight ?? (product['category'] == 'Fruits' ? '250g' : product['unit'].toString());
    final baseWeight = _gramsIn(product['unit'].toString());
    final requestedWeight = _gramsIn(selectedWeight);
    final basePrice = int.parse(product['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
    final selectedPrice = baseWeight > 0 && requestedWeight > 0
        ? (basePrice * requestedWeight / baseWeight).round()
        : basePrice;
    final existing = _items.where((i) => i.name == product['name'] && i.weight == selectedWeight);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(
        name:  product['name'],
        price: '₹$selectedPrice',
        emoji: product['emoji'],
        unit:  product['unit'],
        weight: selectedWeight,
      ));
    }
    notifyListeners();
  }

  int _gramsIn(String value) {
    final match = RegExp(r'(\d+)\s*g', caseSensitive: false).firstMatch(value);
    if (match != null) return int.parse(match.group(1)!);
    final kg = RegExp(r'(\d+)\s*kg', caseSensitive: false).firstMatch(value);
    return kg == null ? 0 : int.parse(kg.group(1)!) * 1000;
  }

  void removeItem(String name, String weight) {
    _items.removeWhere((i) => i.name == name && i.weight == weight);
    notifyListeners();
  }

  void increment(String name, String weight) {
    final item = _items.firstWhere((i) => i.name == name && i.weight == weight);
    item.quantity++;
    notifyListeners();
  }

  void decrement(String name, String weight) {
    final item = _items.firstWhere((i) => i.name == name && i.weight == weight);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```

### lib/models/user_profile.dart
```dart
class UserAddress {
  final String id;
  final String label;
  final String line;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.label,
    required this.line,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      label: json['label'] as String? ?? 'Home',
      line: json['line'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final DateTime joinedAt;
  final List<UserAddress> addresses;
  final int orderCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinedAt,
    this.addresses = const [],
    this.orderCount = 0,
  });

  String? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address.line;
    }
    return addresses.isNotEmpty ? addresses.first.line : null;
  }

  String get formattedJoinDate {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[joinedAt.month - 1]} ${joinedAt.day}, ${joinedAt.year}';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final addressesJson = json['addresses'];
    return UserProfile(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      addresses: addressesJson is List
          ? addressesJson
              .map((a) => UserAddress.fromJson(Map<String, dynamic>.from(a)))
              .toList()
          : const [],
      orderCount: json['orderCount'] as int? ?? 0,
    );
  }
}

String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} week${diff.inDays ~/ 7 == 1 ? '' : 's'} ago';
  return UserProfile(
    id: '',
    name: '',
    phone: '',
    joinedAt: dateTime,
  ).formattedJoinDate;
}

String formatOrderStatus(String status) {
  switch (status) {
    case 'placed':
      return 'Placed';
    case 'confirmed':
      return 'Confirmed';
    case 'out_for_delivery':
      return 'Out for delivery';
    case 'delivered':
      return 'Delivered';
    case 'cancelled':
      return 'Cancelled';
    default:
      return status;
  }
}
```

### lib/razorpay_wrapper.dart
```dart
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayWrapper {
  Razorpay _razorpay = Razorpay();
  
  RazorpayWrapper() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void open(Map<String, dynamic> options) {
    _razorpay.open(options);
  }
  
  void clear() {
    _razorpay.clear();
  }
  
  void onPaymentSuccess(Function(PaymentSuccessResponse) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handler);
  }
  
  void onPaymentError(Function(PaymentFailureResponse) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handler);
  }
  
  void onExternalWallet(Function(ExternalWalletResponse) handler) {
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handler);
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handler will be set by the screen
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    // Handler will be set by the screen
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handler will be set by the screen
  }
}
```

### lib/razorpay_web.dart
```dart
import 'dart:html' as html;
import 'dart:js' as js;

class RazorpayWrapper {
  dynamic _razorpayInstance;
  
  RazorpayWrapper() {
    // Initialize Razorpay JS will be done when opening
  }
  
  void open(Map<String, dynamic> options) {
    try {
      // Convert options to JS object
      var jsOptions = js.JsObject.jsify({
        'key': options['key'],
        'amount': options['amount'],
        'name': options['name'],
        'description': options['description'],
        'prefill': options['prefill'],
        'theme': options['theme'],
        'handler': (response) {
          _handlePaymentSuccess(response);
        },
        'modal': {
          'ondismiss': () {
            _handlePaymentDismiss();
          }
        }
      });
      
      // Get Razorpay from window
      var razorpay = js.context['Razorpay'];
      if (razorpay != null) {
        _razorpayInstance = js.JsObject(razorpay, [jsOptions]);
        _razorpayInstance.callMethod('open');
      } else {
        print('Razorpay JS not loaded');
        _handlePaymentError('Razorpay not available');
      }
    } catch (e) {
      print('Error opening Razorpay: $e');
      _handlePaymentError(e.toString());
    }
  }
  
  void clear() {
    // No cleanup needed for web
  }
  
  void onPaymentSuccess(Function(dynamic) handler) {
    _paymentSuccessHandler = handler;
  }
  
  void onPaymentError(Function(String) handler) {
    _paymentErrorHandler = handler;
  }
  
  void onExternalWallet(Function(dynamic) handler) {
    _externalWalletHandler = handler;
  }
  
  Function(dynamic)? _paymentSuccessHandler;
  Function(String)? _paymentErrorHandler;
  Function(dynamic)? _externalWalletHandler;
  
  void _handlePaymentSuccess(dynamic response) {
    if (_paymentSuccessHandler != null) {
      _paymentSuccessHandler!(response);
    }
  }
  
  void _handlePaymentError(String error) {
    if (_paymentErrorHandler != null) {
      _paymentErrorHandler!(error);
    }
  }
  
  void _handlePaymentDismiss() {
    if (_paymentErrorHandler != null) {
      _paymentErrorHandler!('Payment cancelled');
    }
  }
}
```

### Screens Directory
The screens directory contains the following UI screens:
- `splash_screen.dart` - App splash screen
- `login_screen.dart` - User login
- `register_screen.dart` - User registration
- `otp_screen.dart` - OTP verification
- `home_screen.dart` - Main product catalog
- `cart_screen.dart` - Shopping cart
- `checkout_screen.dart` - Order checkout with Razorpay integration
- `order_success_screen.dart` - Order confirmation
- `my_orders_screen.dart` - Order history
- `my_addresses_screen.dart` - Address management
- `profile_screen.dart` - User profile
- `notifications_screen.dart` - User notifications
- `help_support_screen.dart` - Help and support
- `location_check_screen.dart` - Location serviceability check
- `ai_screen.dart` - AI-powered recommendations

---

## Admin Panel (React)

### package.json
```json
{
  "name": "skyfresh-admin",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/dom": "^10.4.1",
    "@testing-library/jest-dom": "^6.9.1",
    "@testing-library/react": "^16.3.2",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.18.1",
    "react": "^19.2.7",
    "react-dom": "^19.2.7",
    "react-router-dom": "^7.18.0",
    "react-scripts": "5.0.1",
    "recharts": "^3.9.0",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

### src/index.js
```javascript
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
```

### src/App.js
```javascript
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Products from './pages/Products';
import Orders from './pages/Orders';

export default function App() {
  return (
    <BrowserRouter>
      <div style={styles.container}>
        <Sidebar />
        <main style={styles.main}>
          <Routes>
            <Route path="/"         element={<Dashboard />} />
            <Route path="/products" element={<Products />}  />
            <Route path="/orders"   element={<Orders />}    />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}

const styles = {
  container: {
    display: 'flex',
    minHeight: '100vh',
  },
  main: {
    marginLeft: 240,
    flex: 1,
    minHeight: '100vh',
    background: '#F8FAFC',
  },
};  
```

### src/components/Sidebar.js
```javascript
import React from 'react';
import { NavLink } from 'react-router-dom';

const links = [
  { to: '/',         icon: '📊', label: 'Dashboard' },
  { to: '/products', icon: '🍎', label: 'Products'  },
  { to: '/orders',   icon: '📦', label: 'Orders'    },
  { to: '/users',    icon: '👥', label: 'Users'     },
];

export default function Sidebar() {
  return (
    <div style={styles.sidebar}>
      {/* Logo */}
      <div style={styles.logo}>
        <span style={styles.logoIcon}>🌿</span>
        <div>
          <div style={styles.logoText}>
            <span style={styles.sky}>SKY</span>fresh
          </div>
          <div style={styles.logoSub}>Admin Panel</div>
        </div>
      </div>

      {/* Links */}
      <nav style={styles.nav}>
        {links.map(link => (
          <NavLink
            key={link.to}
            to={link.to}
            end={link.to === '/'}
            style={({ isActive }) => ({
              ...styles.link,
              background: isActive ? 'linear-gradient(90deg, #0EA5E9, #38BDF8)' : 'transparent',
              color: isActive ? '#fff' : '#64748B',
              boxShadow: isActive ? '0 4px 12px rgba(14,165,233,0.3)' : 'none',
            })}
          >
            <span style={styles.linkIcon}>{link.icon}</span>
            {link.label}
          </NavLink>
        ))}
      </nav>

      {/* Bottom */}
      <div style={styles.bottom}>
        <div style={styles.adminBadge}>
          <span style={{ fontSize: 20 }}>👤</span>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700 }}>Admin</div>
            <div style={{ fontSize: 11, color: '#94A3B8' }}>SKYfresh</div>
          </div>
        </div>
      </div>
    </div>
  );
}

const styles = {
  sidebar: {
    width: 240,
    minHeight: '100vh',
    background: '#fff',
    borderRight: '1px solid #E2E8F0',
    display: 'flex',
    flexDirection: 'column',
    padding: '24px 16px',
    position: 'fixed',
    top: 0, left: 0, bottom: 0,
  },
  logo: {
    display: 'flex', alignItems: 'center', gap: 12,
    marginBottom: 32, padding: '0 8px',
  },
  logoIcon: {
    fontSize: 32,
    background: 'linear-gradient(135deg, #0EA5E9, #38BDF8)',
    borderRadius: 12, padding: 8,
  },
  logoText: {
    fontSize: 20, fontWeight: 800, color: '#0C1A2E',
  },
  sky: { color: '#0EA5E9' },
  logoSub: { fontSize: 11, color: '#94A3B8', letterSpacing: 1 },
  nav: { display: 'flex', flexDirection: 'column', gap: 6, flex: 1 },
  link: {
    display: 'flex', alignItems: 'center', gap: 12,
    padding: '12px 16px', borderRadius: 14,
    textDecoration: 'none', fontSize: 14, fontWeight: 600,
    transition: 'all 0.2s',
  },
  linkIcon: { fontSize: 18 },
  bottom: { borderTop: '1px solid #E2E8F0', paddingTop: 16 },
  adminBadge: {
    display: 'flex', alignItems: 'center', gap: 10,
    padding: '10px 12px', background: '#F8FAFC',
    borderRadius: 12,
  },
};
```

### src/pages/Dashboard.js
```javascript
import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const stats = [
  { label: 'Total Users',    value: '1,240', icon: '👥', color: '#0EA5E9', bg: '#F0F9FF' },
  { label: 'Total Orders',   value: '856',   icon: '📦', color: '#16A34A', bg: '#F0FDF4' },
  { label: 'Total Products', value: '48',    icon: '🍎', color: '#F97316', bg: '#FFF7ED' },
  { label: 'Revenue',        value: '₹84,200', icon: '💰', color: '#7C3AED', bg: '#FAF5FF' },
];

const chartData = [
  { day: 'Mon', orders: 40 },
  { day: 'Tue', orders: 65 },
  { day: 'Wed', orders: 50 },
  { day: 'Thu', orders: 80 },
  { day: 'Fri', orders: 95 },
  { day: 'Sat', orders: 110 },
  { day: 'Sun', orders: 75 },
];

const recentOrders = [
  { id: '#001', customer: 'Yashvanth', items: 'Mango, Orange Juice', total: '₹150', status: 'Delivered' },
  { id: '#002', customer: 'Rahul',     items: 'Apple, Green Juice',  total: '₹180', status: 'Pending'   },
  { id: '#003', customer: 'Priya',     items: 'Watermelon',          total: '₹40',  status: 'Delivered' },
  { id: '#004', customer: 'Karthik',   items: 'Mixed Fruit Bowl',    total: '₹120', status: 'Processing'},
];

export default function Dashboard() {
  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Dashboard 📊</h1>
          <p style={styles.sub}>Welcome back, Admin! Here's what's happening.</p>
        </div>
        <div style={styles.dateBadge}>📅 Today, {new Date().toLocaleDateString()}</div>
      </div>

      {/* Stats */}
      <div style={styles.statsGrid}>
        {stats.map((s, i) => (
          <div key={i} style={styles.statCard}>
            <div style={{ ...styles.statIcon, background: s.bg, color: s.color }}>
              {s.icon}
            </div>
            <div>
              <div style={styles.statValue}>{s.value}</div>
              <div style={styles.statLabel}>{s.label}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={styles.row}>
        {/* Chart */}
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Orders This Week</h2>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F1F5F9" />
              <XAxis dataKey="day" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="orders" fill="#0EA5E9" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Recent Orders */}
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Recent Orders</h2>
          <table style={styles.table}>
            <thead>
              <tr>
                {['ID', 'Customer', 'Items', 'Total', 'Status'].map(h => (
                  <th key={h} style={styles.th}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {recentOrders.map((o, i) => (
                <tr key={i} style={styles.tr}>
                  <td style={styles.td}>{o.id}</td>
                  <td style={styles.td}>{o.customer}</td>
                  <td style={styles.td}>{o.items}</td>
                  <td style={styles.td}>{o.total}</td>
                  <td style={styles.td}>
                    <span style={{
                      ...styles.badge,
                      background: o.status === 'Delivered' ? '#DCFCE7' : 
                                  o.status === 'Pending' ? '#FEF9C3' : '#DBEAFE',
                      color: o.status === 'Delivered' ? '#16A34A' : 
                             o.status === 'Pending' ? '#CA8A04' : '#1D4ED8',
                    }}>
                      {o.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

const styles = {
  page: { padding: 28 },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 },
  title: { fontSize: 26, fontWeight: 800, color: '#0C1A2E' },
  sub: { fontSize: 13, color: '#94A3B8', marginTop: 4 },
  dateBadge: { background: '#F0F9FF', color: '#0EA5E9', padding: '8px 16px', borderRadius: 20, fontSize: 13, fontWeight: 600 },
  statsGrid: { display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 24 },
  statCard: { background: '#fff', borderRadius: 18, padding: '20px 16px', display: 'flex', alignItems: 'center', gap: 14, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  statIcon: { width: 52, height: 52, borderRadius: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, flexShrink: 0 },
  statValue: { fontSize: 22, fontWeight: 800, color: '#0C1A2E' },
  statLabel: { fontSize: 12, color: '#94A3B8', marginTop: 2 },
  row: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 },
  card: { background: '#fff', borderRadius: 18, padding: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  cardTitle: { fontSize: 16, fontWeight: 700, marginBottom: 16, color: '#0C1A2E' },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', fontSize: 12, color: '#94A3B8', fontWeight: 600, paddingBottom: 10, borderBottom: '1px solid #F1F5F9' },
  tr: { borderBottom: '1px solid #F8FAFC' },
  td: { padding: '10px 0', fontSize: 13, color: '#0C1A2E' },
  badge: { padding: '3px 10px', borderRadius: 20, fontSize: 11, fontWeight: 700 },
};
```

### src/pages/Products.js
```javascript
import React, { useState, useEffect } from 'react';

const Products = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Form State
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [unit, setUnit] = useState('1 kg');
  const [emoji, setEmoji] = useState('🍎');
  const [category, setCategory] = useState('Fruits');
  const [stock, setStock] = useState(50);
  const [color, setColor] = useState('#FFF3CD');

  const API_URL = 'http://localhost:5000/api/products';
  
  // Custom headers including token verification
  const getAdminHeaders = () => {
    const token = localStorage.getItem('adminToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };
  };

  // Fetch all live products from the MongoDB database
  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch(API_URL);
      const data = await response.json();
      if (data.success) {
        setProducts(data.products);
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError('Could not connect to the backend server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, []);

  // Handle adding a new product to the database
  const handleAddProduct = async (e) => {
    e.preventDefault();
    const newProduct = { name, price: Number(price), unit, emoji, category, stock: Number(stock), color };

    try {
      const response = await fetch(`${API_URL}/add`, {
        method: 'POST',
        headers: getAdminHeaders(),
        body: JSON.stringify(newProduct),
      });
      const data = await response.json();

      if (data.success) {
        setProducts([...products, data.product]);
        // Reset dynamic form elements
        setName('');
        setPrice('');
        alert('🌿 Product added to catalog successfully!');
      } else {
        alert(`Failed to add product: ${data.message}`);
      }
    } catch (err) {
      alert('Error connecting to backend.');
    }
  };

  // Handle removing a product from the database
  const handleDeleteProduct = async (id) => {
    if (!window.confirm('Are you sure you want to remove this item from the catalog?')) return;

    try {
      const response = await fetch(`${API_URL}/${id}`, {
        method: 'DELETE',
        headers: getAdminHeaders(),
      });
      const data = await response.json();

      if (data.success) {
        setProducts(products.filter(p => p._id !== id));
      } else {
        alert(`Failed to delete: ${data.message}`);
      }
    } catch (err) {
      alert('Error connecting to backend.');
    }
  };

  if (loading) return <div style={{ padding: '20px' }}>Loading live product catalog...</div>;
  if (error) return <div style={{ padding: '20px', color: 'red' }}>❌ Error: {error}</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h2>Inventory Management Dashboard</h2>
      
      {/* Add Product Form */}
      <form onSubmit={handleAddProduct} style={{ background: '#f4f4f4', padding: '20px', borderRadius: '8px', marginBottom: '30px' }}>
        <h3>Add New Fresh Item</h3>
        <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
          <input type="text" placeholder="Product Name" value={name} onChange={e => setName(e.target.value)} required style={{ padding: '8px', flex: 1 }} />
          <input type="number" placeholder="Price (₹)" value={price} onChange={e => setPrice(e.target.value)} required style={{ padding: '8px', width: '120px' }} />
          <input type="text" placeholder="Unit (e.g. 1 kg)" value={unit} onChange={e => setUnit(e.target.value)} required style={{ padding: '8px', width: '120px' }} />
        </div>
        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <input type="text" placeholder="Emoji (e.g. 🍉)" value={emoji} onChange={e => setEmoji(e.target.value)} required style={{ padding: '8px', width: '100px' }} />
          <input type="number" placeholder="Stock Qty" value={stock} onChange={e => setStock(e.target.value)} required style={{ padding: '8px', width: '100px' }} />
          <input type="color" value={color} onChange={e => setColor(e.target.value)} style={{ width: '50px', height: '38px', padding: '0', border: 'none' }} title="Choose background highlight color" />
          
          <select value={category} onChange={e => setCategory(e.target.value)} style={{ padding: '8px' }}>
            <option value="Fruits">Fruits</option>
            <option value="Juices">Juices</option>
            <option value="Fresh Cuts">Fresh Cuts</option>
          </select>
          <button type="submit" style={{ padding: '8px 20px', background: '#2e7d32', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>Save Product</button>
        </div>
      </form>

      {/* Products Table Data View */}
      <div>
        <h3>Current Catalog ({products.length} items)</h3>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead>
            <tr style={{ background: '#e0e0e0' }}>
              <th style={{ padding: '12px' }}>Item</th>
              <th style={{ padding: '12px' }}>Category</th>
              <th style={{ padding: '12px' }}>Price</th>
              <th style={{ padding: '12px' }}>Stock Status</th>
              <th style={{ padding: '12px' }}>Action</th>
            </tr>
          </thead>
          <tbody>
            {products.map(product => (
              <tr key={product._id} style={{ borderBottom: '1px solid #ddd' }}>
                <td style={{ padding: '12px' }}>
                  <span style={{ marginRight: '8px', padding: '4px 8px', borderRadius: '4px', background: product.color || '#fff' }}>{product.emoji}</span> 
                  {product.name} ({product.unit})
                </td>
                <td style={{ padding: '12px' }}>{product.category}</td>
                <td style={{ padding: '12px' }}>₹{product.price}</td>
                <td style={{ padding: '12px' }}>{product.stock} units</td>
                <td style={{ padding: '12px' }}>
                  <button onClick={() => handleDeleteProduct(product._id)} style={{ background: '#d32f2f', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer' }}>Remove</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Products;
```

### src/pages/Orders.js
```javascript
import React, { useState, useEffect } from 'react';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const API_URL = 'http://localhost:5000/api/orders';

  // Fetch all live customer orders across the platform
  const fetchOrders = async () => {
    try {
      setLoading(true);
      const response = await fetch(API_URL);
      const data = await response.json();
      if (data.success) {
        setOrders(data.orders);
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError('Could not connect to the backend server to fetch orders.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  // Handle changing an order's fulfillment tracking status
  const handleStatusChange = async (orderId, newStatus) => {
    try {
      const response = await fetch(`${API_URL}/${orderId}/status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus }),
      });
      const data = await response.json();

      if (data.success) {
        // Update local state smoothly
        setOrders(orders.map(order => 
          order._id === orderId ? { ...order, status: newStatus } : order
        ));
        alert(`Status updated to: ${newStatus.replace(/_/g, ' ')} 🚚`);
      } else {
        alert(`Failed to update status: ${data.message}`);
      }
    } catch (err) {
      alert('Error updating status on backend.');
    }
  };

  // Helper function to color code badges based on delivery state
  const getStatusStyle = (status) => {
    switch (status) {
      case 'placed': return { bg: '#e3f2fd', color: '#0d47a1' };
      case 'confirmed': return { bg: '#fff3e0', color: '#e65100' };
      case 'out_for_delivery': return { bg: '#f3e5f5', color: '#4a148c' };
      case 'delivered': return { bg: '#e8f5e9', color: '#1b5e20' };
      case 'cancelled': return { bg: '#ffebee', color: '#b71c1c' };
      default: return { bg: '#f5f5f5', color: '#333' };
    }
  };

  if (loading) return <div style={{ padding: '20px' }}>Loading incoming orders pipeline...</div>;
  if (error) return <div style={{ padding: '20px', color: 'red' }}>❌ Error: {error}</div>;

  return (
    <div style={{ padding: '20px' }}>
      <h2>Live Customer Orders Pipeline</h2>
      <h3>Active Batches ({orders.length} orders total)</h3>

      {orders.length === 0 ? (
        <div style={{ padding: '40px', textAlign: 'center', background: '#f9f9f9', borderRadius: '8px', border: '1px dashed #ccc' }}>
          🛒 No orders have been placed on the platform yet.
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {orders.map(order => {
            const badge = getStatusStyle(order.status);
            return (
              <div key={order._id} style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '20px', background: '#fff', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
                
                {/* Header Row */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #eee', paddingBottom: '10px', marginBottom: '15px' }}>
                  <div>
                    <span style={{ fontWeight: 'bold', fontSize: '1.1rem' }}>Order ID: #{order._id.slice(-6).toUpperCase()}</span>
                    <span style={{ marginLeft: '15px', color: '#666', fontSize: '0.9rem' }}>
                      {new Date(order.createdAt).toLocaleString()}
                    </span>
                  </div>
                  <div>
                    <span style={{ backgroundColor: badge.bg, color: badge.color, padding: '6px 12px', borderRadius: '20px', fontWeight: 'bold', fontSize: '0.85rem', textTransform: 'uppercase' }}>
                      {order.status.replace(/_/g, ' ')}
                    </span>
                  </div>
                </div>

                {/* Content Layout Grid */}
                <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '20px' }}>
                  
                  {/* Left Column: Items Purchased */}
                  <div>
                    <h4 style={{ margin: '0 0 10px 0', color: '#555' }}>Items Ordered</h4>
                    <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
                      {order.items.map((item, index) => (
                        <li key={index} style={{ padding: '6px 0', borderBottom: '1px dashed #f0f0f0', display: 'flex', justifyContent: 'space-between' }}>
                          <span>{item.emoji} {item.name} <span style={{ color: '#777' }}>x{item.quantity}</span></span>
                          <span style={{ fontWeight: '500' }}>₹{item.price * item.quantity}</span>
                        </li>
                      ))}
                    </ul>
                    <div style={{ marginTop: '10px', textAlign: 'right', fontWeight: 'bold', fontSize: '1.1rem' }}>
                      Total Bill: <span style={{ color: '#2e7d32' }}>₹{order.total}</span>
                    </div>
                  </div>

                  {/* Right Column: Customer Details & Fulfillment Controls */}
                  <div style={{ borderLeft: '1px solid #eee', paddingLeft: '20px' }}>
                    <h4 style={{ margin: '0 0 5px 0', color: '#555' }}>Customer Info</h4>
                    <p style={{ margin: '0 0 5px 0', fontWeight: '500' }}>{order.user?.name || 'Guest User'}</p>
                    <p style={{ margin: '0 0 15px 0', color: '#666', fontSize: '0.9rem' }}>📞 {order.user?.phone || 'N/A'}</p>

                    <h4 style={{ margin: '0 0 5px 0', color: '#555' }}>Delivery Destination</h4>
                    <p style={{ margin: '0 0 20px 0', fontSize: '0.9rem', color: '#444', lineHeight: '1.4' }}>📍 {order.address}</p>

                    <h4 style={{ margin: '0 0 8px 0', color: '#555' }}>Dispatch Management</h4>
                    <select 
                      value={order.status} 
                      onChange={(e) => handleStatusChange(order._id, e.target.value)}
                      style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ccc', background: '#fafafa', cursor: 'pointer', fontWeight: '500' }}
                    >
                      <option value="placed">Placed (Pending Review)</option>
                      <option value="confirmed">Confirm Order</option>
                      <option value="out_for_delivery">Out For Delivery 🛵</option>
                      <option value="delivered">Mark as Delivered ✅</option>
                      <option value="cancelled">Cancel Order ❌</option>
                    </select>
                  </div>

                </div>

              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default Orders;
```

---

## Environment Variables

### Backend (.env)
```
MONGO_URI=mongodb://localhost:27017/skyfresh
PORT=5000
JWT_SECRET=your_jwt_secret_key_here
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
PEXELS_KEY=your_pexels_api_key
```

### Frontend (web/index.html)
The Razorpay checkout script is included in the web entry point for web-based payments.

---

## Setup Instructions

### Backend Setup
1. Navigate to `skyfresh-backend`
2. Install dependencies: `npm install`
3. Create `.env` file with required environment variables
4. Start MongoDB server
5. Run seed script: `node seed.js`
6. Start server: `node server.js`

### Frontend Setup
1. Navigate to `skyfresh-frontend`
2. Install dependencies: `flutter pub get`
3. Run on mobile: `flutter run`
4. Run on web: `flutter run -d chrome`

### Admin Panel Setup
1. Navigate to `skyfresh-admin`
2. Install dependencies: `npm install`
3. Start development server: `npm start`

---

## Key Features

### Backend
- User authentication with JWT
- OTP verification system
- Product management
- Order management
- Address management
- Razorpay payment integration
- Serviceability checking

### Frontend
- User registration and login
- Product catalog with images
- Shopping cart functionality
- Order placement
- Address management
- Order history
- Razorpay payment integration (mobile and web)
- Location-based serviceability

### Admin Panel
- Dashboard with statistics
- Product inventory management
- Order management and status updates
- Real-time order tracking

---

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/verify-otp` - Verify OTP
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get user profile
- `POST /api/auth/addresses` - Add address
- `DELETE /api/auth/addresses/:id` - Delete address
- `PATCH /api/auth/addresses/:id/default` - Set default address

### Products
- `GET /api/products` - Get all products
- `POST /api/products/add` - Add product (admin only)
- `DELETE /api/products/:id` - Delete product (admin only)

### Orders
- `POST /api/orders` - Place order
- `GET /api/orders/my` - Get user orders
- `GET /api/orders` - Get all orders (admin)
- `PATCH /api/orders/:id/status` - Update order status

### Payments
- `POST /api/payments/create-order` - Create Razorpay order

### Serviceability
- `GET /api/serviceability/check` - Check location serviceability

---

## Technology Stack

### Backend
- Node.js
- Express.js
- MongoDB
- JWT
- Razorpay
- bcryptjs

### Frontend
- Flutter
- Dart
- Provider (State Management)
- Razorpay Flutter Plugin
- Geolocator
- Shared Preferences

### Admin Panel
- React
- React Router
- Recharts
- Axios

---

## Notes

- The Razorpay integration uses test mode with key `rzp_test_TEbkIK2Vtv3aJO`
- Web uses JavaScript interop for Razorpay, mobile uses Flutter plugin
- Admin phone number `8870682988` is configured as admin
- Serviceability is currently set to global (all locations serviceable)
- Images are fetched from Pexels API during database seeding
