const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const User = require('../models/user');
const Product = require('../models/Product');
const { getMessaging } = require('firebase-admin/messaging');

// GET /api/admin/stats - Summary numbers
router.get('/stats', async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    const totalUsers = await User.countDocuments();
    const activeProducts = await Product.countDocuments();
    const orders = await Order.find({ status: { $nin: ['Cancelled', 'Failed'] } });
    const totalSales = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
    
    res.json({
      totalOrders,
      totalUsers,
      activeProducts,
      totalSales
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching stats', error: error.message });
  }
});

// GET /api/admin/orders - Fetch all orders (no auth required)
router.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find()
      .populate('userId', 'phone name')
      .sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching orders', error: error.message });
  }
});

// PUT /api/admin/orders/:id/status - Update order status (no auth required)
router.put('/orders/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { returnDocument: 'after' }
    ).populate('userId', 'phone name fcmToken');
    
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

        await getMessaging(global.firebaseAdmin).send(message);
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
