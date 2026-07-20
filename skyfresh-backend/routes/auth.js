const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library'); // NEW: Import Google Auth
const User = require('../models/User');
const Order = require('../models/Order');
const Admin = require('../models/Admin');

// NEW: Initialize Google Client
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

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
    console.log('requireAuth - decoded token:', req.user);
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

async function requireAdmin(req, res, next) {
  try {
    console.log('requireAdmin - req.user:', req.user);
    const admin = await Admin.findById(req.user.id);
    console.log('requireAdmin - found admin:', admin ? admin.username : 'null');
    console.log('requireAdmin - admin ID from token:', req.user.id);
    console.log('requireAdmin - admin ID from DB:', admin ? admin._id.toString() : 'null');
    
    if (!admin) {
      console.log('requireAdmin - ACCESS DENIED - Admin not found');
      return res.status(403).json({ success: false, message: 'Access denied. Admins only.' });
    }
    console.log('requireAdmin - ACCESS GRANTED');
    req.admin = admin;
    next();
  } catch (err) {
    console.error('requireAdmin - error:', err);
    res.status(500).json({ success: false, message: 'Server authorization error' });
  }
}

function formatUser(user, stats = {}) {
  return {
    id: user._id,
    name: user.name,
    phone: user.phone,
    email: user.email, // NEW: Added email to formatting
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
    
    // Check if user already exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.json({ success: false, message: 'User already exists with this phone number' });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create new user
    const user = new User({
      name,
      phone,
      password: hashedPassword,
      isVerified: false
    });
    
    await user.save();
    
    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.otp = otp;
    user.otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();
    
    // In production, send OTP via SMS
    console.log(`OTP for ${phone}: ${otp}`);
    
    res.json({ success: true, message: 'Registration successful. Please verify OTP.' });
    
  } catch (err) {
    console.error('Registration error:', err);
    res.json({ success: false, message: 'Registration failed', error: err.message });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    
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
    console.error('OTP verification error:', err);
    res.json({ success: false, message: 'OTP verification failed', error: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    
    const user = await User.findOne({ phone });
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }
    
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.json({ success: false, message: 'Invalid password' });
    }
    
    // Generate token
    const token = jwt.sign(
      { id: user._id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({ success: true, message: 'Login successful', token, user: formatUser(user) });
    
  } catch (err) {
    console.error('Login error:', err);
    res.json({ success: false, message: 'Login failed', error: err.message });
  }
});

// Admin login route (username/password)
router.post('/admin/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    const admin = await Admin.findOne({ username });
    if (!admin) {
      return res.json({ success: false, message: 'Admin not found' });
    }
    
    const isMatch = await admin.comparePassword(password);
    if (!isMatch) {
      return res.json({ success: false, message: 'Invalid password' });
    }
    
    // Generate token
    const token = jwt.sign(
      { id: admin._id, username: admin.username, type: 'admin' },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({ 
      success: true, 
      message: 'Admin login successful', 
      token, 
      admin: {
        id: admin._id,
        username: admin.username,
        name: admin.name
      }
    });
    
  } catch (err) {
    console.error('Admin login error:', err);
    res.json({ success: false, message: 'Admin login failed', error: err.message });
  }
});

// ==========================================
// NEW: GOOGLE SIGN-IN ROUTE
// ==========================================
router.post('/google-login', async (req, res) => {
  try {
    const { idToken } = req.body;
    
    // 1. Verify token with Google
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    
    const { email, name } = ticket.getPayload();

    // 2. Check if user exists by email
    let user = await User.findOne({ email });

    // 3. If new user, register them automatically
    if (!user) {
      const randomPassword = await bcrypt.hash(Math.random().toString(36), 10);
      user = new User({
        name,
        email,
        // Generate a placeholder phone so it doesn't crash your current DB schema
        phone: 'GGL_' + Date.now().toString().slice(-7), 
        password: randomPassword,
        isVerified: true, // Google emails are already verified
      });
      await user.save();
    }

    // 4. Generate JWT matching your existing logic
    const token = jwt.sign(
      { id: user._id, phone: user.phone }, 
      process.env.JWT_SECRET, 
      { expiresIn: '7d' }
    );

    res.json({ 
      success: true, 
      message: 'Google login successful', 
      token, 
      user: formatUser(user) 
    });

  } catch (err) {
    res.json({ success: false, message: 'Google authentication failed', error: err.message });
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
    console.error('Get profile error:', err);
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
    console.error('Add address error:', err);
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
    console.error('Delete address error:', err);
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
    console.error('Update default address error:', err);
    res.json({ success: false, message: 'Failed to update default address', error: err.message });
  }
});

module.exports = { router, requireAuth, requireAdmin };
