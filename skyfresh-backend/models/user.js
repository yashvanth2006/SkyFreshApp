const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  // ==============================
  // NEW: Added Email Field
  // ==============================
  email: { 
    type: String,
    unique: true,
    sparse: true, // Allows phone-only users to exist without an email
    trim: true,
    lowercase: true
  },
  phone: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  username: {
    type: String,
    unique: true,
    sparse: true, // Allows users without username
    trim: true
  },
  password: {
    type: String,
    required: true
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
  isAdmin: {
    type: Boolean,
    default: false
  },
  addresses: [{
    label: { type: String, default: 'Home', trim: true },
    line: { type: String, required: true, trim: true },
    isDefault: { type: Boolean, default: false },
  }],
}, { timestamps: true });

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  const bcrypt = require('bcryptjs');
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);