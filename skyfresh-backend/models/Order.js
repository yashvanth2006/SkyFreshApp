const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  name:     { type: String, required: true },
  price:    { type: Number, required: true }, // price per unit at time of order
  quantity: { type: Number, required: true },
  unit:     { type: String },
  emoji:    { type: String },
}, { _id: false });

const orderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  items: {
    type: [orderItemSchema],
    required: true,
    validate: v => Array.isArray(v) && v.length > 0,
  },
  subtotal:     { type: Number, required: true },
  deliveryFee:  { type: Number, required: true, default: 0 },
  total:        { type: Number, required: true },
  address:      { type: String, required: true },
  status: {
    type: String,
    enum: ['placed', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'placed',
  },
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);