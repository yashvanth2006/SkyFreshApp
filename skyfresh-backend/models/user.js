const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      trim: true
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user'
    },
    otp: {
      type: String,
      default: null
    },
    otpExpiry: {
      type: Date,
      default: null
    },
    isVerified: {
      type: Boolean,
      default: false
    },
    addresses: [{
      label: { type: String, default: 'Home', trim: true },
      line: { type: String, required: true, trim: true },
      isDefault: { type: Boolean, default: false },
    }],
  },
  {
    timestamps: true
  }
);

// Prevents OverwriteModelError if the model is required multiple times
const User = mongoose.models.User || mongoose.model('User', userSchema);

module.exports = User;