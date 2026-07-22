const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false // Set to false so guest orders don't throw 500 errors
    },
    items: [
      {
        name: { type: String, required: true },
        price: { type: Number, required: true },
        quantity: { type: Number, required: true, default: 1 },
        product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: false }
      }
    ],
    shippingAddress: {
      houseNo: { type: String },
      street: { type: String },
      city: { type: String },
      state: { type: String },
      pincode: { type: String }
    },
    subtotal: {
      type: Number,
      default: 0
    },
    deliveryCharge: {
      type: Number,
      default: 0
    },
    totalAmount: {
      type: Number,
      required: true
    },
    paymentMethod: {
      type: String,
      default: 'Cash on Delivery'
    },
    status: {
      type: String,
      enum: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'],
      default: 'Pending'
    }
  },
  {
    timestamps: true
  }
);

const Order = mongoose.models.Order || mongoose.model('Order', orderSchema);

module.exports = Order;