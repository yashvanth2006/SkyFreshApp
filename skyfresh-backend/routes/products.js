const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { requireAuth, requireAdmin } = require('./auth');

// Public route: Everyone can view products
router.get('/', async (req, res) => {
  try {
    const products = await Product.find();
    res.json({ success: true, products });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// Protected Route: Only Admins can append to the catalog
router.post('/add', requireAuth, requireAdmin, async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.json({ success: true, product });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// Protected Route: Only Admins can remove items from catalog
router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Product successfully deleted by admin.' });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

module.exports = router;