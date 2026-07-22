const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const axios = require('axios');

// Helper function to fetch image from Pexels
const fetchPexelsImage = async (productName) => {
  try {
    const response = await axios.get(
      `https://api.pexels.com/v1/search?query=${encodeURIComponent(productName)}&per_page=1`,
      {
        headers: {
          Authorization: process.env.PEXELS_KEY
        }
      }
    );
    
    if (response.data.photos && response.data.photos.length > 0) {
      return response.data.photos[0].src.medium;
    }
    return null;
  } catch (error) {
    console.error('Pexels API error:', error.message);
    return null;
  }
};

// Public route: Everyone can view products (Now supports Search & Category filters!)
router.get('/', async (req, res) => {
  try {
    const { search, category } = req.query;
    let query = {};

    // 1. Filter by category (if provided) - Case insensitive
    if (category && category !== 'All') {
      query.category = { $regex: `^${category}$`, $options: 'i' };
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

// Route: Anyone can add products
router.post('/', async (req, res) => {
  try {
    const productData = req.body;
    
    // If no image is provided, fetch one from Pexels
    if (!productData.image || productData.image.trim() === '') {
      const pexelsImage = await fetchPexelsImage(productData.name);
      if (pexelsImage) {
        productData.image = pexelsImage;
      } else {
        // Fallback placeholder image
        productData.image = 'https://via.placeholder.com/400x300?text=No+Image';
      }
    }
    
    const product = new Product(productData);
    await product.save();
    res.json({ success: true, product });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

// Route: Anyone can update products
router.put('/:id', async (req, res) => {
  try {
    const productData = req.body;
    
    // If no image is provided, fetch one from Pexels
    if (!productData.image || productData.image.trim() === '') {
      const pexelsImage = await fetchPexelsImage(productData.name);
      if (pexelsImage) {
        productData.image = pexelsImage;
      } else {
        // Fallback placeholder image
        productData.image = 'https://via.placeholder.com/400x300?text=No+Image';
      }
    }
    
    const updatedProduct = await Product.findByIdAndUpdate(
      req.params.id, 
      productData, 
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

// Route: Anyone can delete products
router.delete('/:id', async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Product successfully deleted.' });
  } catch (err) {
    res.json({ success: false, message: err.message });
  }
});

module.exports = router;