const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const User = require('../models/user');
const { requireAuth, requireAdmin } = require('./middleware');

// GET /api/admin/orders - Fetch all orders (admin only)
router.get('/orders', requireAuth, requireAdmin, async (req, res) => {
  try {
    const orders = await Order.find()
      .populate('userId', 'phone name')
      .sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching orders', error: error.message });
  }
});

// PUT /api/admin/orders/:id/status - Update order status (admin only)
router.put('/orders/:id/status', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { status } = req.body;
    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).populate('userId', 'phone name');
    
    if (!updatedOrder) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Send FCM notification if user has a token
    if (updatedOrder.userId && updatedOrder.userId.fcmToken && global.firebaseAdmin) {
      try {
        const message = {
          notification: {
            title: 'Order Update',
            body: `Your order #${updatedOrder._id.toString().slice(-6).toUpperCase()} status is now: ${status}`,
          },
          token: updatedOrder.userId.fcmToken,
        };

        await global.firebaseAdmin.messaging().send(message);
        console.log('FCM notification sent to user', updatedOrder.userId.phone);
      } catch (fcmError) {
        console.error('Failed to send FCM notification:', fcmError.message);
        // Don't fail the request if FCM fails
      }
    }
    
    res.json({ success: true, order: updatedOrder });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating order status', error: error.message });
  }
});

module.exports = router;
