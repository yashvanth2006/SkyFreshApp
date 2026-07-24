const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const { requireAuth } = require('./middleware');

// POST /api/orders - Create a new order (protected)
router.post('/', requireAuth, async (req, res) => {
  try {
    const { items, shippingAddress, subtotal, deliveryCharge, totalAmount, paymentMethod } = req.body;

    // Create new order with authenticated user
    const newOrder = new Order({
      userId: req.user.id,
      items: items || [],
      shippingAddress: shippingAddress || '',
      subtotal: subtotal || 0,
      deliveryCharge: deliveryCharge || 0,
      totalAmount: totalAmount || 0,
      paymentMethod: paymentMethod || 'Cash on Delivery',
      status: 'Pending'
    });

    const savedOrder = await newOrder.save();

    return res.status(201).json({
      success: true,
      message: 'Order placed successfully!',
      order: savedOrder
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Server error while placing order',
      error: error.message
    });
  }
});

// GET /api/orders/my - Fetch current user's orders (protected)
router.get('/my', requireAuth, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching orders', error: error.message });
  }
});

// GET /api/orders - Fetch all orders (For Admin Panel)
router.get('/', async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching orders', error: error.message });
  }
});

// PATCH /api/orders/:id/status - Update Order Status
router.patch('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    res.json(updatedOrder);
  } catch (error) {
    res.status(500).json({ message: 'Error updating order status', error: error.message });
  }
});

module.exports = router;