const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      trim: true,
      default: ''
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
      unique: true,
      sparse: true
    },
    phone: {
      type: String,
      trim: true,
      unique: true,
      sparse: true,
      default: undefined // Omits the field if empty so sparse index works properly
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user'
    },
    firebaseUid: {
      type: String,
      unique: true,
      sparse: true,
      default: undefined // Prevents duplicate 'null' errors for non-Firebase users
    },
    fcmToken: {
      type: String,
      default: null
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
    addresses: [
      {
        label: { type: String, default: 'Home', trim: true },
        line: { type: String, required: true, trim: true },
        isDefault: { type: Boolean, default: false }
      }
    ]
  },
  {
    timestamps: true
  }
);

// Prevents OverwriteModelError if the model is required multiple times
const User = mongoose.models.User || mongoose.model('User', userSchema);

module.exports = User;