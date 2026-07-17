# SKYfresh - Complete Project Structure & Code

## Project Overview
```
SkyFreshApp/
├── skyfresh-backend/          # Node.js/Express API
├── skyfresh-frontend/         # Flutter mobile app
├── skyfresh-admin/            # React admin panel
└── .gitignore
```

---

## Backend (Node.js/Express)

### Structure
```
skyfresh-backend/
├── package.json
├── server.js
├── seed.js
├── .env.example
├── models/
│   ├── Product.js
│   ├── Order.js
│   ├── user.js
│   └── Review.js
└── routes/
    ├── auth.js
    ├── products.js
    ├── orders.js
    ├── reviews.js
    └── serviceability.js
```

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
    "mongoose": "^9.7.3"
  }
}
```

### server.js
```javascript
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', '*');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

app.use('/api/auth',     require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/reviews', require('./routes/reviews'));
app.use('/api/serviceability', require('./routes/serviceability'));

app.get('/', (req, res) => {
  res.json({ message: 'SKYfresh API is running 🌿' });
});

mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB connected');
    app.listen(process.env.PORT, () => {
      console.log(`🚀 Server running on port ${process.env.PORT}`);
    });
  })
  .catch((err) => console.log('❌ MongoDB error:', err));
```

### seed.js
```javascript
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

### .env.example
```
MONGO_URI=mongodb://localhost:27017/skyfresh
PORT=5000
JWT_SECRET=your_jwt_secret_key_here
```

### models/Product.js
```javascript
const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  price: { type: Number, required: true },
  unit: { type: String, required: true },
  emoji: { type: String, required: true },
  category: { type: String, enum: ['Fruits', 'Juices', 'Fresh Cuts'], required: true },
  stock: { type: Number, default: 50 },
  color: { type: String, default: '#FFF3CD' },
  image: { type: String, default: '' },
  isAvailable: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
```

### models/Order.js
```javascript
const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  name:     { type: String, required: true },
  price:    { type: Number, required: true },
  quantity: { type: Number, required: true },
  unit:     { type: String },
  emoji:    { type: String },
}, { _id: false });

const orderSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  items: { type: [orderItemSchema], required: true, validate: v => Array.isArray(v) && v.length > 0 },
  subtotal:     { type: Number, required: true },
  deliveryFee:  { type: Number, required: true, default: 0 },
  total:        { type: Number, required: true },
  address:      { type: String, required: true },
  status: { type: String, enum: ['placed', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'], default: 'placed' },
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
```

### models/user.js
```javascript
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  phone: { type: String, required: true, unique: true, trim: true },
  password: { type: String, required: true },
  otp: { type: String, default: null },
  otpExpiry: { type: Date, default: null },
  isVerified: { type: Boolean, default: false },
  addresses: [{
    label: { type: String, default: 'Home', trim: true },
    line: { type: String, required: true, trim: true },
    isDefault: { type: Boolean, default: false },
  }],
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
```

### models/Review.js
```javascript
const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String, required: true, trim: true },
  productName: { type: String, required: true, trim: true },
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String, required: true, trim: true },
}, { timestamps: true });

module.exports = mongoose.model('Review', reviewSchema);
```

### routes/auth.js
```javascript
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Order = require('../models/Order');
const Review = require('../models/Review');

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
    reviewCount: stats.reviewCount ?? 0,
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

    console.log(`OTP for ${phone}: ${otp}`);
    res.json({ success: true, message: 'OTP sent successfully', otp: otp });
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

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({ success: true, user: formatUser(user, { orderCount, reviewCount }) });
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

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({ success: true, message: 'Address saved', user: formatUser(user, { orderCount, reviewCount }) });
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

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({ success: true, message: 'Address removed', user: formatUser(user, { orderCount, reviewCount }) });
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

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({ success: true, message: 'Default address updated', user: formatUser(user, { orderCount, reviewCount }) });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = router;
```

### routes/products.js
```javascript
const express = require('express');
const router = express.Router();
const Product = require('../models/Product');

router.get('/', async (req, res) => {
  try {
    const products = await Product.find();
    res.json({ success: true, products });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

router.get('/category/:cat', async (req, res) => {
  try {
    const products = await Product.find({ category: req.params.cat });
    res.json({ success: true, products });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

router.post('/add', async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.json({ success: true, product });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Product deleted' });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

module.exports = router;
```

### routes/orders.js
```javascript
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Order = require('../models/Order');
const User = require('../models/User');

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

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

router.get('/my', requireAuth, async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 }).populate('user', 'name phone');
    res.json({ success: true, orders });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

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

### routes/reviews.js
```javascript
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Review = require('../models/Review');
const User = require('../models/User');

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
  const token = authHeader.split(' ')[1];
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

router.get('/', async (req, res) => {
  try {
    const reviews = await Review.find().sort({ createdAt: -1 }).limit(50);
    res.json({ success: true, reviews });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.get('/my', requireAuth, async (req, res) => {
  try {
    const reviews = await Review.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, reviews });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.post('/', requireAuth, async (req, res) => {
  try {
    const { productName, productId, rating, comment } = req.body;

    if (!productName || !comment || !rating) {
      return res.json({ success: false, message: 'Product, rating and review are required' });
    }
    if (rating < 1 || rating > 5) {
      return res.json({ success: false, message: 'Rating must be between 1 and 5' });
    }

    const user = await User.findById(req.user.id).select('name');
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    const review = new Review({
      user: req.user.id,
      userName: user.name,
      productName: productName.trim(),
      productId: productId || undefined,
      rating,
      comment: comment.trim(),
    });
    await review.save();

    res.json({ success: true, message: 'Review submitted', review });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = router;
```

### routes/serviceability.js
```javascript
const express = require('express');
const router = express.Router();

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

### Structure
```
skyfresh-frontend/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── theme.dart
│   ├── shop_info.dart
│   ├── cart_provider.dart
│   ├── api_service.dart
│   ├── models/
│   │   └── user_profile.dart
│   └── screens/
│       ├── splash_screen.dart
│       ├── login_screen.dart
│       ├── register_screen.dart
│       ├── otp_screen.dart
│       ├── home_screen.dart
│       ├── cart_screen.dart
│       ├── checkout_screen.dart
│       ├── order_success_screen.dart
│       ├── my_orders_screen.dart
│       ├── my_addresses_screen.dart
│       ├── profile_screen.dart
│       ├── notifications_screen.dart
│       ├── help_support_screen.dart
│       ├── location_check_screen.dart
│       └── ai_screen.dart
```

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
  http: ^1.2.0
  shared_preferences: ^2.2.2
  cached_network_image: ^3.3.1
  provider: ^6.1.1
  geolocator: ^14.0.3
  geocoding: ^5.0.0
  url_launcher: ^6.3.1

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
    colors: [Color(0x1A10B981), Color(0x05FFFFFF)],
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

### lib/shop_info.dart
```dart
import 'package:url_launcher/url_launcher.dart';

class ShopInfo {
  static const name = 'SKY PAZHAMUDHIR NILAYAM';
  static const primaryPhone = '8870682988';
  static const secondaryPhone = '9894325988';
  static const whatsAppPhone = primaryPhone;
  static const email = 'yashvanth2006k@gmail.com';
  static const openingHours = 'Open daily · 8:30 AM To 10:00 PM';
  static const googleMapsUrl =
      'https://www.google.com/maps/place/SKY+PAZHAMUDHIR+NILAYAM/@11.0427426,76.9243548,21z/data=!4m6!3m5!1s0x3ba859c28e3e7561:0x3124c49cd088be1c!8m2!3d11.0427535!4d76.9241488!16s%2Fg%2F11vfb3hjlr?entry=ttu';
  static const latitude = 11.0427535;
  static const longitude = 76.9241488;

  static String formatPhone(String phone) {
    if (phone.length == 10) return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    return phone;
  }

  static String get primaryPhoneDisplay => formatPhone(primaryPhone);
  static String get secondaryPhoneDisplay => formatPhone(secondaryPhone);

  static Future<bool> callPrimary() => _launch(Uri(scheme: 'tel', path: '+91$primaryPhone'));
  static Future<bool> callSecondary() => _launch(Uri(scheme: 'tel', path: '+91$secondaryPhone'));
  static Future<bool> openWhatsApp() => _launch(Uri.parse('https://wa.me/91$whatsAppPhone'));
  static Future<bool> sendEmail() => _launch(Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'SKYfresh Support'},
      ));
  static Future<bool> openMaps() => _launch(Uri.parse(googleMapsUrl));

  static Future<bool> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
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

### lib/api_service.dart
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyfresh/models/user_profile.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000/api";

  static Future<Map<String, dynamic>> register({
    required String name, required String phone, required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone, required String otp,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userPhone', data['user']['phone']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String phone, required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userPhone', data['user']['phone']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/products'), headers: {'Content-Type': 'application/json'});
      final data = jsonDecode(res.body);
      if (data['success'] == true) return List<Map<String, dynamic>>.from(data['products']);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required int subtotal, required int deliveryFee, required int total,
    required String address, String? paymentMethod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return {'success': false, 'message': 'Please log in again.'};

      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'items': items, 'subtotal': subtotal, 'deliveryFee': deliveryFee,
          'total': total, 'address': address,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return [];

      final res = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) return List<Map<String, dynamic>>.from(data['orders']);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<UserProfile?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return null;

      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['user'] != null) {
        final profile = UserProfile.fromJson(Map<String, dynamic>.from(data['user']));
        await prefs.setString('userName', profile.name);
        await prefs.setString('userPhone', profile.phone);
        return profile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> addAddress({
    required String line, String label = 'Home', bool isDefault = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return {'success': false, 'message': 'Please log in again.'};

      final res = await http.post(
        Uri.parse('$baseUrl/auth/addresses'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'label': label, 'line': line, 'isDefault': isDefault}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return {'success': false, 'message': 'Please log in again.'};

      final res = await http.delete(
        Uri.parse('$baseUrl/auth/addresses/$addressId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return {'success': false, 'message': 'Please log in again.'};

      final res = await http.patch(
        Uri.parse('$baseUrl/auth/addresses/$addressId/default'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<Map<String, dynamic>> checkServiceability({
    required double lat, required double lng,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/serviceability/check?lat=$lat&lng=$lng'),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'serviceable': false, 'message': 'Cannot connect to server.'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
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
    required this.id, required this.label, required this.line, required this.isDefault,
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
    required this.id, required this.name, required this.phone, required this.joinedAt,
    this.addresses = const [], this.orderCount = 0,
  });

  String? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address.line;
    }
    return addresses.isNotEmpty ? addresses.first.line : null;
  }

  String get formattedJoinDate {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[joinedAt.month - 1]} ${joinedAt.day}, ${joinedAt.year}';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final addressesJson = json['addresses'];
    return UserProfile(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now() : DateTime.now(),
      addresses: addressesJson is List
          ? addressesJson.map((a) => UserAddress.fromJson(Map<String, dynamic>.from(a))).toList()
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
  return UserProfile(id: '', name: '', phone: '', joinedAt: dateTime).formattedJoinDate;
}

String formatOrderStatus(String status) {
  switch (status) {
    case 'placed': return 'Placed';
    case 'confirmed': return 'Confirmed';
    case 'out_for_delivery': return 'Out for delivery';
    case 'delivered': return 'Delivered';
    case 'cancelled': return 'Cancelled';
    default: return status;
  }
}
```

---

## Admin Panel (React)

### Structure
```
skyfresh-admin/
├── package.json
├── src/
│   ├── App.js
│   ├── index.js
│   ├── index.css
│   ├── components/
│   │   └── Sidebar.js
│   └── pages/
│       ├── Dashboard.js
│       ├── Products.js
│       └── Orders.js
```

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
  }
}
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
  container: { display: 'flex', minHeight: '100vh' },
  main: { marginLeft: 240, flex: 1, minHeight: '100vh', background: '#F8FAFC' },
};
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

### src/index.css
```css
* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; }
body { background: #F8FAFC; color: #0C1A2E; }
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: #f1f1f1; }
::-webkit-scrollbar-thumb { background: #BAE6FD; border-radius: 10px; }
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
      <div style={styles.logo}>
        <span style={styles.logoIcon}>🌿</span>
        <div>
          <div style={styles.logoText}><span style={styles.sky}>SKY</span>fresh</div>
          <div style={styles.logoSub}>Admin Panel</div>
        </div>
      </div>
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
  sidebar: { width: 240, minHeight: '100vh', background: '#fff', borderRight: '1px solid #E2E8F0', display: 'flex', flexDirection: 'column', padding: '24px 16px', position: 'fixed', top: 0, left: 0, bottom: 0 },
  logo: { display: 'flex', alignItems: 'center', gap: 12, marginBottom: 32, padding: '0 8px' },
  logoIcon: { fontSize: 32, background: 'linear-gradient(135deg, #0EA5E9, #38BDF8)', borderRadius: 12, padding: 8 },
  logoText: { fontSize: 20, fontWeight: 800, color: '#0C1A2E' },
  sky: { color: '#0EA5E9' },
  logoSub: { fontSize: 11, color: '#94A3B8', letterSpacing: 1 },
  nav: { display: 'flex', flexDirection: 'column', gap: 6, flex: 1 },
  link: { display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderRadius: 14, textDecoration: 'none', fontSize: 14, fontWeight: 600, transition: 'all 0.2s' },
  linkIcon: { fontSize: 18 },
  bottom: { borderTop: '1px solid #E2E8F0', paddingTop: 16 },
  adminBadge: { display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', background: '#F8FAFC', borderRadius: 12 },
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
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Dashboard 📊</h1>
          <p style={styles.sub}>Welcome back, Admin! Here's what's happening.</p>
        </div>
        <div style={styles.dateBadge}>📅 Today, {new Date().toLocaleDateString()}</div>
      </div>

      <div style={styles.statsGrid}>
        {stats.map((s, i) => (
          <div key={i} style={styles.statCard}>
            <div style={{ ...styles.statIcon, background: s.bg, color: s.color }}>{s.icon}</div>
            <div>
              <div style={styles.statValue}>{s.value}</div>
              <div style={styles.statLabel}>{s.label}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={styles.row}>
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

        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Recent Orders</h2>
          <table style={styles.table}>
            <thead>
              <tr>
                {['ID', 'Customer', 'Items', 'Total', 'Status'].map(h => <th key={h} style={styles.th}>{h}</th>)}
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
                      background: o.status === 'Delivered' ? '#DCFCE7' : o.status === 'Pending' ? '#FEF9C3' : '#DBEAFE',
                      color: o.status === 'Delivered' ? '#16A34A' : o.status === 'Pending' ? '#CA8A04' : '#1D4ED8',
                    }}>{o.status}</span>
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
import React, { useState } from 'react';

const initialProducts = [
  { id: 1, name: 'Fresh Mango',       price: 60,  unit: '250g',  emoji: '🥭', category: 'Fruits',     stock: 50 },
  { id: 2, name: 'Watermelon',        price: 40,  unit: '500g',  emoji: '🍉', category: 'Fresh Cuts', stock: 30 },
  { id: 3, name: 'Orange Juice',      price: 80,  unit: '300ml', emoji: '🍊', category: 'Juices',     stock: 25 },
  { id: 4, name: 'Fresh Apple',       price: 50,  unit: '200g',  emoji: '🍎', category: 'Fruits',     stock: 40 },
  { id: 5, name: 'Mango Juice',       price: 90,  unit: '300ml', emoji: '🥭', category: 'Juices',     stock: 20 },
  { id: 6, name: 'Pineapple',         price: 70,  unit: '300g',  emoji: '🍍', category: 'Fruits',     stock: 35 },
  { id: 7, name: 'Green Juice',       price: 100, unit: '300ml', emoji: '🥬', category: 'Juices',     stock: 15 },
  { id: 8, name: 'Mixed Fruit Bowl',  price: 120, unit: '400g',  emoji: '🍱', category: 'Fresh Cuts', stock: 20 },
];

export default function Products() {
  const [products, setProducts] = useState(initialProducts);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ name: '', price: '', unit: '', emoji: '', category: 'Fruits', stock: '' });

  const handleAdd = () => {
    if (!form.name || !form.price) return;
    setProducts([...products, { ...form, id: Date.now(), price: Number(form.price), stock: Number(form.stock) }]);
    setForm({ name: '', price: '', unit: '', emoji: '', category: 'Fruits', stock: '' });
    setShowForm(false);
  };

  const handleDelete = (id) => {
    setProducts(products.filter(p => p.id !== id));
  };

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Products 🍎</h1>
          <p style={styles.sub}>{products.length} products in catalog</p>
        </div>
        <button style={styles.addBtn} onClick={() => setShowForm(!showForm)}>+ Add Product</button>
      </div>

      {showForm && (
        <div style={styles.form}>
          <h3 style={{ marginBottom: 16, color: '#0C1A2E' }}>Add New Product</h3>
          <div style={styles.formGrid}>
            <input style={styles.input} placeholder="Product name" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} />
            <input style={styles.input} placeholder="Emoji (e.g. 🍊)" value={form.emoji} onChange={e => setForm({ ...form, emoji: e.target.value })} />
            <input style={styles.input} placeholder="Price (₹)" type="number" value={form.price} onChange={e => setForm({ ...form, price: e.target.value })} />
            <input style={styles.input} placeholder="Unit (e.g. 250g)" value={form.unit} onChange={e => setForm({ ...form, unit: e.target.value })} />
            <select style={styles.input} value={form.category} onChange={e => setForm({ ...form, category: e.target.value })}>
              <option>Fruits</option>
              <option>Juices</option>
              <option>Fresh Cuts</option>
            </select>
            <input style={styles.input} placeholder="Stock quantity" type="number" value={form.stock} onChange={e => setForm({ ...form, stock: e.target.value })} />
          </div>
          <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
            <button style={styles.saveBtn} onClick={handleAdd}>Save Product</button>
            <button style={styles.cancelBtn} onClick={() => setShowForm(false)}>Cancel</button>
          </div>
        </div>
      )}

      <div style={styles.card}>
        <table style={styles.table}>
          <thead>
            <tr>
              {['Product', 'Category', 'Price', 'Unit', 'Stock', 'Actions'].map(h => <th key={h} style={styles.th}>{h}</th>)}
            </tr>
          </thead>
          <tbody>
            {products.map(p => (
              <tr key={p.id} style={styles.tr}>
                <td style={styles.td}>
                  <div style={styles.productCell}>
                    <span style={styles.emoji}>{p.emoji}</span>
                    <span style={{ fontWeight: 600 }}>{p.name}</span>
                  </div>
                </td>
                <td style={styles.td}><span style={styles.catBadge}>{p.category}</span></td>
                <td style={styles.td}>₹{p.price}</td>
                <td style={styles.td}>{p.unit}</td>
                <td style={styles.td}>
                  <span style={{ ...styles.stockBadge, background: p.stock > 20 ? '#DCFCE7' : '#FEF9C3', color: p.stock > 20 ? '#16A34A' : '#CA8A04' }}>{p.stock} left</span>
                </td>
                <td style={styles.td}>
                  <button style={styles.deleteBtn} onClick={() => handleDelete(p.id)}>🗑️ Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const styles = {
  page: { padding: 28 },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 },
  title: { fontSize: 26, fontWeight: 800, color: '#0C1A2E' },
  sub: { fontSize: 13, color: '#94A3B8', marginTop: 4 },
  addBtn: { background: 'linear-gradient(90deg, #0EA5E9, #38BDF8)', color: '#fff', border: 'none', padding: '10px 20px', borderRadius: 12, fontSize: 14, fontWeight: 700, cursor: 'pointer' },
  form: { background: '#fff', borderRadius: 18, padding: 24, marginBottom: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  formGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 },
  input: { padding: '10px 14px', border: '1.5px solid #E2E8F0', borderRadius: 10, fontSize: 13, outline: 'none', width: '100%' },
  saveBtn: { background: 'linear-gradient(90deg, #16A34A, #22C55E)', color: '#fff', border: 'none', padding: '10px 24px', borderRadius: 10, fontWeight: 700, cursor: 'pointer' },
  cancelBtn: { background: '#F1F5F9', color: '#64748B', border: 'none', padding: '10px 24px', borderRadius: 10, fontWeight: 700, cursor: 'pointer' },
  card: { background: '#fff', borderRadius: 18, padding: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', fontSize: 12, color: '#94A3B8', fontWeight: 600, paddingBottom: 12, borderBottom: '2px solid #F1F5F9' },
  tr: { borderBottom: '1px solid #F8FAFC' },
  td: { padding: '12px 0', fontSize: 13, color: '#0C1A2E' },
  productCell: { display: 'flex', alignItems: 'center', gap: 10 },
  emoji: { fontSize: 24, background: '#F8FAFC', padding: 6, borderRadius: 8 },
  catBadge: { background: '#E0F2FE', color: '#0284C7', padding: '3px 10px', borderRadius: 20, fontSize: 11, fontWeight: 600 },
  stockBadge: { padding: '3px 10px', borderRadius: 20, fontSize: 11, fontWeight: 700 },
  deleteBtn: { background: '#FEF2F2', color: '#EF4444', border: 'none', padding: '6px 12px', borderRadius: 8, fontSize: 12, cursor: 'pointer', fontWeight: 600 },
};
```

### src/pages/Orders.js
```javascript
import React, { useState, useEffect } from 'react';

const API_BASE = 'http://localhost:5000/api';

const STATUS_META = {
  placed:            { label: 'Placed',           bg: '#DBEAFE', color: '#1D4ED8' },
  confirmed:         { label: 'Confirmed',        bg: '#EDE9FE', color: '#7C3AED' },
  out_for_delivery:  { label: 'Out for Delivery', bg: '#FFEDD5', color: '#EA580C' },
  delivered:         { label: 'Delivered',        bg: '#DCFCE7', color: '#16A34A' },
  cancelled:         { label: 'Cancelled',        bg: '#FEE2E2', color: '#DC2626' },
};

const STATUS_TABS = ['All', 'placed', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'];

function formatDate(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}

function itemsSummary(items) {
  return items.map(i => `${i.name}${i.quantity > 1 ? ` x${i.quantity}` : ''}`).join(', ');
}

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState('All');
  const [updatingId, setUpdatingId] = useState(null);

  const fetchOrders = async () => {
    setLoading(true);
    setError('');
    try {
      const res = await fetch(`${API_BASE}/orders`);
      const data = await res.json();
      if (data.success) {
        setOrders(data.orders);
      } else {
        setError(data.message || 'Could not load orders');
      }
    } catch (e) {
      setError('Cannot connect to server. Is the backend running?');
    }
    setLoading(false);
  };

  useEffect(() => { fetchOrders(); }, []);

  const filtered = filter === 'All' ? orders : orders.filter(o => o.status === filter);

  const updateStatus = async (id, status) => {
    setUpdatingId(id);
    const prevOrders = orders;
    setOrders(orders.map(o => o._id === id ? { ...o, status } : o));

    try {
      const res = await fetch(`${API_BASE}/orders/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      });
      const data = await res.json();
      if (!data.success) {
        setOrders(prevOrders);
        alert(data.message || 'Could not update status');
      }
    } catch (e) {
      setOrders(prevOrders);
      alert('Cannot connect to server.');
    }
    setUpdatingId(null);
  };

  const countByStatus = (status) => orders.filter(o => o.status === status).length;

  return (
    <div style={styles.page}>
      <div style={styles.header}>
        <div>
          <h1 style={styles.title}>Orders 📦</h1>
          <p style={styles.sub}>{orders.length} total orders</p>
        </div>
        <div style={styles.summaryRow}>
          <div style={styles.summaryBadge('#DCFCE7', '#16A34A')}>✅ {countByStatus('delivered')} Delivered</div>
          <div style={styles.summaryBadge('#DBEAFE', '#1D4ED8')}>📦 {countByStatus('placed')} Placed</div>
          <div style={styles.summaryBadge('#FFEDD5', '#EA580C')}>🛵 {countByStatus('out_for_delivery')} Out for Delivery</div>
        </div>
      </div>

      <div style={styles.tabs}>
        {STATUS_TABS.map(f => (
          <button key={f} style={{
            ...styles.tab,
            background: filter === f ? 'linear-gradient(90deg, #15803D, #22C55E)' : '#fff',
            color: filter === f ? '#fff' : '#64748B',
            boxShadow: filter === f ? '0 4px 12px rgba(21,128,61,0.3)' : 'none',
          }} onClick={() => setFilter(f)}>
            {f === 'All' ? 'All' : STATUS_META[f].label}
          </button>
        ))}
        <button style={styles.refreshBtn} onClick={fetchOrders} disabled={loading}>
          {loading ? 'Refreshing…' : '↻ Refresh'}
        </button>
      </div>

      <div style={styles.card}>
        {loading ? (
          <div style={styles.centerMsg}>Loading orders…</div>
        ) : error ? (
          <div style={{ ...styles.centerMsg, color: '#DC2626' }}>{error}</div>
        ) : filtered.length === 0 ? (
          <div style={styles.centerMsg}>No orders found.</div>
        ) : (
          <table style={styles.table}>
            <thead>
              <tr>
                {['Customer', 'Phone', 'Items', 'Address', 'Total', 'Date', 'Status', 'Update'].map(h => <th key={h} style={styles.th}>{h}</th>)}
              </tr>
            </thead>
            <tbody>
              {filtered.map(o => (
                <tr key={o._id} style={styles.tr}>
                  <td style={{ ...styles.td, fontWeight: 700 }}>{o.user?.name || 'Unknown'}</td>
                  <td style={styles.td}>{o.user?.phone || '—'}</td>
                  <td style={styles.td}>{itemsSummary(o.items)}</td>
                  <td style={{ ...styles.td, maxWidth: 180, color: '#64748B' }}>{o.address}</td>
                  <td style={{ ...styles.td, fontWeight: 700 }}>₹{o.total}</td>
                  <td style={{ ...styles.td, color: '#94A3B8' }}>{formatDate(o.createdAt)}</td>
                  <td style={styles.td}>
                    <span style={{
                      ...styles.badge,
                      background: STATUS_META[o.status]?.bg || '#F1F5F9',
                      color: STATUS_META[o.status]?.color || '#64748B',
                    }}>{STATUS_META[o.status]?.label || o.status}</span>
                  </td>
                  <td style={styles.td}>
                    <select value={o.status} disabled={updatingId === o._id} onChange={e => updateStatus(o._id, e.target.value)} style={styles.select}>
                      <option value="placed">Placed</option>
                      <option value="confirmed">Confirmed</option>
                      <option value="out_for_delivery">Out for Delivery</option>
                      <option value="delivered">Delivered</option>
                      <option value="cancelled">Cancelled</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

const styles = {
  page: { padding: 28 },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20 },
  title: { fontSize: 26, fontWeight: 800, color: '#0C1A2E' },
  sub: { fontSize: 13, color: '#94A3B8', marginTop: 4 },
  summaryRow: { display: 'flex', gap: 10 },
  summaryBadge: (bg, color) => ({ background: bg, color, padding: '8px 14px', borderRadius: 20, fontSize: 12, fontWeight: 700 }),
  tabs: { display: 'flex', gap: 8, marginBottom: 20, alignItems: 'center' },
  tab: { padding: '8px 20px', borderRadius: 20, border: 'none', fontSize: 13, fontWeight: 600, cursor: 'pointer' },
  refreshBtn: { marginLeft: 'auto', padding: '8px 16px', borderRadius: 20, border: '1.5px solid #E2E8F0', background: '#fff', color: '#15803D', fontSize: 13, fontWeight: 700, cursor: 'pointer' },
  card: { background: '#fff', borderRadius: 18, padding: 20, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' },
  centerMsg: { padding: '40px 0', textAlign: 'center', color: '#94A3B8', fontSize: 14 },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', fontSize: 12, color: '#94A3B8', fontWeight: 600, paddingBottom: 12, borderBottom: '2px solid #F1F5F9' },
  tr: { borderBottom: '1px solid #F8FAFC' },
  td: { padding: '12px 4px', fontSize: 13, color: '#0C1A2E' },
  badge: { padding: '4px 12px', borderRadius: 20, fontSize: 11, fontWeight: 700 },
  select: { padding: '6px 10px', border: '1.5px solid #E2E8F0', borderRadius: 8, fontSize: 12, cursor: 'pointer', outline: 'none' },
};
```

---

## Summary

The SKYfresh project consists of three main components:

1. **Backend (Node.js/Express)**: REST API with MongoDB for user authentication, product management, order processing, reviews, and serviceability checks.

2. **Frontend (Flutter)**: Mobile app for users to browse products, add to cart, place orders, manage addresses, view order history, and access support features.

3. **Admin Panel (React)**: Web dashboard for administrators to manage products, view and update order statuses, and monitor business metrics.

All components communicate via REST API endpoints, with JWT-based authentication for secure access.
