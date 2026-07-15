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
  if (!token) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
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
      id: a._id,
      label: a.label,
      line: a.line,
      isDefault: a.isDefault,
    })),
    orderCount: stats.orderCount ?? 0,
    reviewCount: stats.reviewCount ?? 0,
  };
}

// ── REGISTER
router.post('/register', async (req, res) => {
  try {
    const { name, phone, password } = req.body;

    const existing = await User.findOne({ phone });
    if (existing) {
      return res.json({ success: false, message: 'Phone number already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000);

    const user = new User({
      name,
      phone,
      password: hashedPassword,
      otp,
      otpExpiry
    });
    await user.save();

    console.log(`OTP for ${phone}: ${otp}`);

    res.json({
      success: true,
      message: 'OTP sent successfully',
      otp: otp
    });

  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── VERIFY OTP
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;

    const user = await User.findOne({ phone });
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    if (user.otp !== otp) {
      return res.json({ success: false, message: 'Invalid OTP' });
    }

    if (user.otpExpiry < new Date()) {
      return res.json({ success: false, message: 'OTP expired' });
    }

    user.isVerified = true;
    user.otp = null;
    user.otpExpiry = null;
    await user.save();

    const token = jwt.sign(
      { id: user._id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      message: 'Phone verified successfully',
      token,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone
      }
    });

  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── LOGIN
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;

    const user = await User.findOne({ phone });
    if (!user) {
      return res.json({ success: false, message: 'Phone number not registered' });
    }

    if (!user.isVerified) {
      return res.json({ success: false, message: 'Please verify your phone first' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.json({ success: false, message: 'Wrong password' });
    }

    const token = jwt.sign(
      { id: user._id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone
      }
    });

  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── CURRENT USER PROFILE
router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('name phone createdAt addresses');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({
      success: true,
      user: formatUser(user, { orderCount, reviewCount }),
    });

  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── ADD ADDRESS
router.post('/addresses', requireAuth, async (req, res) => {
  try {
    const { label, line, isDefault } = req.body;
    if (!line || !line.trim()) {
      return res.json({ success: false, message: 'Address is required' });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    if (isDefault || user.addresses.length === 0) {
      user.addresses.forEach((a) => { a.isDefault = false; });
    }

    user.addresses.push({
      label: (label || 'Home').trim(),
      line: line.trim(),
      isDefault: isDefault === true || user.addresses.length === 0,
    });
    await user.save();

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({
      success: true,
      message: 'Address saved',
      user: formatUser(user, { orderCount, reviewCount }),
    });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── DELETE ADDRESS
router.delete('/addresses/:id', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    const address = user.addresses.id(req.params.id);
    if (!address) {
      return res.json({ success: false, message: 'Address not found' });
    }

    const wasDefault = address.isDefault;
    address.deleteOne();

    if (wasDefault && user.addresses.length > 0) {
      user.addresses[0].isDefault = true;
    }

    await user.save();

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({
      success: true,
      message: 'Address removed',
      user: formatUser(user, { orderCount, reviewCount }),
    });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

// ── SET DEFAULT ADDRESS
router.patch('/addresses/:id/default', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    const address = user.addresses.id(req.params.id);
    if (!address) {
      return res.json({ success: false, message: 'Address not found' });
    }

    user.addresses.forEach((a) => { a.isDefault = false; });
    address.isDefault = true;
    await user.save();

    const [orderCount, reviewCount] = await Promise.all([
      Order.countDocuments({ user: user._id }),
      Review.countDocuments({ user: user._id }),
    ]);

    res.json({
      success: true,
      message: 'Default address updated',
      user: formatUser(user, { orderCount, reviewCount }),
    });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = router;