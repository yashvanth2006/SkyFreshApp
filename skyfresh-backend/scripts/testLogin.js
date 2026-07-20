const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
require('dotenv').config();

async function testLogin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/skyfresh');
    console.log('Connected to MongoDB');

    const phone = '8870682988';
    const password = 'admin123';

    const user = await User.findOne({ phone });
    if (!user) {
      console.log('User not found');
      return;
    }

    console.log('User found:', user.name);
    console.log('Stored password hash:', user.password);

    const isMatch = await bcrypt.compare(password, user.password);
    console.log('Password match:', isMatch);

    if (!isMatch) {
      console.log('Password does not match. Resetting password...');
      const hashedPassword = await bcrypt.hash(password, 10);
      user.password = hashedPassword;
      await user.save();
      console.log('Password reset successfully');
      
      // Test again
      const newMatch = await bcrypt.compare(password, user.password);
      console.log('New password match:', newMatch);
    }

    await mongoose.disconnect();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

testLogin();
