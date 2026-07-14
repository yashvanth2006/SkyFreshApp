const express = require('express');
const router = express.Router();
const Product = require('../models/Product');

// ── GET ALL PRODUCTS
router.get('/', async (req, res) => {
  try {
    const products = await Product.find();
    res.json({ success: true, products });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// ── GET BY CATEGORY
router.get('/category/:cat', async (req, res) => {
  try {
    const products = await Product.find({ category: req.params.cat });
    res.json({ success: true, products });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// ── ADD PRODUCT
router.post('/add', async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.json({ success: true, product });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// ── DELETE PRODUCT
router.delete('/:id', async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Product deleted' });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

module.exports = router;