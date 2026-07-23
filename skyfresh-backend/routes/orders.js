const express = require('express');
const router = express.Router();
const Order = require('../models/Order');

// POST /api/orders - Create a new order
router.post('/', async (req, res) => {
  try {
    const {
      user,
      items,
      shippingAddress,
      subtotal,
      deliveryCharge,
      totalAmount,
      total,
      paymentMethod,
      houseNo,
      street,
      city,
      state,
      pincode
    } = req.body;

    // Build shipping address from root body if flat object was passed
    const formattedAddress = shippingAddress || {
      houseNo: houseNo || req.body['house_no'] || '',
      street: street || req.body['address'] || '',
      city: city || '',
      state: state || '',
      pincode: pincode || ''
    };

    // Calculate or fallback total amount
    const finalTotal = totalAmount || total || 0;

    // Create new order instance safely
    const newOrder = new Order({
      user: user || null,
      items: items || [],
      shippingAddress: formattedAddress,
      subtotal: subtotal || 0,
      deliveryCharge: deliveryCharge || 0,
      totalAmount: finalTotal,
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
    console.error('CRITICAL: Error placing order:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error while placing order',
      error: error.message
    });
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