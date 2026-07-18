const express = require('express');
const Razorpay = require('razorpay');
const router = express.Router();

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Route to create a payment order
router.post('/create-order', async (req, res) => {
  try {
    const { amount } = req.body; // Amount from frontend

    const options = {
      amount: amount * 100, // Razorpay expects amount in paise (multiply by 100)
      currency: 'INR',
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);
    
    res.json({
      success: true,
      order: order,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Failed to create order' });
  }
});

module.exports = router;