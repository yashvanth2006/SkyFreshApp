const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  price: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    required: true
  },
  emoji: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: ['Fruits', 'Juices', 'Fresh Cuts'],
    required: true
  },
  stock: {
    type: Number,
    default: 50
  },
  color: {
    type: String,
    default: '#FFF3CD'
  },
  image: {
  type: String,
  default: ''
  },
  isAvailable: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);