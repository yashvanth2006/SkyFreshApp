const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library'); // NEW: Import Google Auth
const User = require('../models/User');
const Order = require('../models/Order');

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
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

async function requireAdmin(req, res, next) {
  try {
    const user = await User.findById(req.user.id);
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
    email: user.email, // NEW: Added email to formatting
    joinedAt: user.createdAt,
    addresses: (user.addresses || []).map((a) => ({
      id: a._id, label: a.label, line: a.line, isDefault: a.isDefault,
    })),
    orderCount: stats.orderCount ?? 0,
  };
}

// ... [Keep your existing /register and /verify-otp routes exactly the same] ...
router.post('/register', async (req, res) => { /* Your existing code */ });
router.post('/verify-otp', async (req, res) => { /* Your existing code */ });
router.post('/login', async (req, res) => { /* Your existing code */ });

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

// ... [Keep your existing /me, /addresses routes exactly the same] ...
router.get('/me', requireAuth, async (req, res) => { /* Your existing code */ });
router.post('/addresses', requireAuth, async (req, res) => { /* Your existing code */ });
router.delete('/addresses/:id', requireAuth, async (req, res) => { /* Your existing code */ });
router.patch('/addresses/:id/default', requireAuth, async (req, res) => { /* Your existing code */ });

module.exports = { router, requireAuth, requireAdmin };