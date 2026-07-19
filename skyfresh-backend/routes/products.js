const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { requireAuth, requireAdmin } = require('./auth');

// Public route: Everyone can view products (Now supports Search & Category filters!)
router.get('/', async (req, res) => {
  try {
    const { search, category } = req.query;
    let query = {};

    // 1. Filter by category (if provided)
    if (category && category !== 'All') {
      query.category = category;
    }

    // 2. Filter by search term (if provided) - Case insensitive
    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }

    // 3. Fetch products based on the built query
    const products = await Product.find(query);
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

// Protected Route: Only Admins can update an existing product
router.put('/:id', requireAuth, requireAdmin, async (req, res) => {
  try {
    const updatedProduct = await Product.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true } // Returns the updated document and runs schema validations
    );
    
    if (!updatedProduct) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    
    res.json({ success: true, product: updatedProduct, message: 'Product successfully updated.' });
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