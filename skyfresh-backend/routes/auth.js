const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const Order = require('../models/Order');
const { requireAuth } = require('./middleware');

function formatUser(user, stats = {}) {
  return {
    id: user._id,
    name: user.name,
    phone: user.phone,
    role: user.role,
    joinedAt: user.createdAt,
    addresses: (user.addresses || []).map((a) => ({
      id: a._id, label: a.label, line: a.line, isDefault: a.isDefault,
    })),
    orderCount: stats.orderCount ?? 0,
  };
}

// POST /api/auth/send-otp - Send OTP to phone number
router.post('/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    
    if (!phone) {
      return res.json({ success: false, message: 'Phone number is required' });
    }
    
    // Check if user exists, if not create them
    let user = await User.findOne({ phone });
    if (!user) {
      user = new User({
        phone,
        isVerified: false
      });
    }
    
    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    user.otp = otp;
    user.otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();
    
    // In production, send OTP via SMS
    console.log(`📱 OTP for ${phone}: ${otp}`);
    
    res.json({ success: true, message: 'OTP sent successfully' });
    
  } catch (err) {
    res.json({ success: false, message: 'Failed to send OTP', error: err.message });
  }
});

// POST /api/auth/verify-otp - Verify OTP and login
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    
    if (!phone || !otp) {
      return res.json({ success: false, message: 'Phone and OTP are required' });
    }
    
    const user = await User.findOne({ phone });
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    if (user.otp !== otp || user.otpExpiry < new Date()) {
      return res.json({ success: false, message: 'Invalid or expired OTP' });
    }
    
    user.isVerified = true;
    user.otp = null;
    user.otpExpiry = null;
    await user.save();
    
    // Generate token
    const token = jwt.sign(
      { id: user._id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({ success: true, message: 'OTP verified successfully', token, user: formatUser(user) });
    
  } catch (err) {
    res.json({ success: false, message: 'OTP verification failed', error: err.message });
  }
});

router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    const orderCount = await Order.countDocuments({ userId: user._id });
    res.json({ success: true, user: formatUser(user, { orderCount }) });
    
  } catch (err) {
    res.json({ success: false, message: 'Failed to fetch profile', error: err.message });
  }
});

router.post('/addresses', requireAuth, async (req, res) => {
  try {
    const { label, line, isDefault } = req.body;
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    // If this is default, remove default from others
    if (isDefault) {
      user.addresses.forEach(addr => addr.isDefault = false);
    }
    
    user.addresses.push({ label, line, isDefault });
    await user.save();
    
    res.json({ success: true, message: 'Address added successfully', user: formatUser(user) });
    
  } catch (err) {
    res.json({ success: false, message: 'Failed to add address', error: err.message });
  }
});

router.delete('/addresses/:id', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    user.addresses = user.addresses.filter(addr => addr._id.toString() !== req.params.id);
    await user.save();
    
    res.json({ success: true, message: 'Address deleted successfully', user: formatUser(user) });
    
  } catch (err) {
    res.json({ success: false, message: 'Failed to delete address', error: err.message });
  }
});

router.patch('/addresses/:id/default', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    // Remove default from all addresses
    user.addresses.forEach(addr => addr.isDefault = false);
    
    // Set default on the requested address
    const address = user.addresses.find(addr => addr._id.toString() === req.params.id);
    if (address) {
      address.isDefault = true;
    }
    
    await user.save();
    
    res.json({ success: true, message: 'Default address updated', user: formatUser(user) });
    
  } catch (err) {
    res.json({ success: false, message: 'Failed to update default address', error: err.message });
  }
});

// POST /api/users/fcm-token - Save FCM token for push notifications
router.post('/fcm-token', requireAuth, async (req, res) => {
  try {
    const { fcmToken } = req.body;
    
    if (!fcmToken) {
      return res.json({ success: false, message: 'FCM token is required' });
    }
    
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    user.fcmToken = fcmToken;
    await user.save();
    
    res.json({ success: true, message: 'FCM token saved successfully' });
    
  } catch (err) {
    res.json({ success: false, message: 'Failed to save FCM token', error: err.message });
  }
});

module.exports = { router, requireAuth };
