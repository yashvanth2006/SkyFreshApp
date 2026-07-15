const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Review = require('../models/Review');
const User = require('../models/User');

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
  const token = authHeader.split(' ')[1];
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
}

router.get('/', async (req, res) => {
  try {
    const reviews = await Review.find().sort({ createdAt: -1 }).limit(50);
    res.json({ success: true, reviews });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.get('/my', requireAuth, async (req, res) => {
  try {
    const reviews = await Review.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, reviews });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

router.post('/', requireAuth, async (req, res) => {
  try {
    const { productName, productId, rating, comment } = req.body;

    if (!productName || !comment || !rating) {
      return res.json({ success: false, message: 'Product, rating and review are required' });
    }
    if (rating < 1 || rating > 5) {
      return res.json({ success: false, message: 'Rating must be between 1 and 5' });
    }

    const user = await User.findById(req.user.id).select('name');
    if (!user) {
      return res.json({ success: false, message: 'User not found' });
    }

    const review = new Review({
      user: req.user.id,
      userName: user.name,
      productName: productName.trim(),
      productId: productId || undefined,
      rating,
      comment: comment.trim(),
    });
    await review.save();

    res.json({ success: true, message: 'Review submitted', review });
  } catch (err) {
    res.json({ success: false, message: 'Server error', error: err.message });
  }
});

module.exports = router;
