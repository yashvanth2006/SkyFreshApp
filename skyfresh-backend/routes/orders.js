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