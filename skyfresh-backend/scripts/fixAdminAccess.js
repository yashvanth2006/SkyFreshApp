const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
require('dotenv').config();

async function fixAdminAccess() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/skyfresh');
    console.log('Connected to MongoDB');

    const phone = '8870682988';
    const password = 'yash2468';

    const user = await User.findOne({ phone });
    if (!user) {
      console.log('User not found');
      return;
    }

    console.log('Current user:', user.name);
    console.log('Current isAdmin:', user.isAdmin);

    // Set admin privileges
    user.isAdmin = true;
    user.isVerified = true;

    // Reset password to the user's actual password
    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;

    await user.save();

    console.log('✅ User updated successfully!');
    console.log('Phone:', phone);
    console.log('Password:', password);
    console.log('isAdmin:', true);
    console.log('isVerified:', true);

    // Test login
    const isMatch = await bcrypt.compare(password, user.password);
    console.log('Password verification:', isMatch ? '✅ Success' : '❌ Failed');

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

fixAdminAccess();
