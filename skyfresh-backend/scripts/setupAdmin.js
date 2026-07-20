const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
require('dotenv').config();

// MongoDB connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/skyfresh';

async function setupAdmin() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ phone: '8870682988' });
    
    if (existingAdmin) {
      console.log('Admin user already exists. Updating admin privileges...');
      existingAdmin.isAdmin = true;
      await existingAdmin.save();
      console.log('Admin privileges updated successfully!');
      console.log('Admin Phone: 8870682988');
      console.log('Admin Password: (unchanged)');
    } else {
      // Create new admin user
      const hashedPassword = await bcrypt.hash('admin123', 10);
      
      const admin = new User({
        name: 'SKYfresh Admin',
        phone: '8870682988',
        password: hashedPassword,
        isAdmin: true,
        isVerified: true
      });

      await admin.save();
      console.log('Admin user created successfully!');
      console.log('Admin Phone: 8870682988');
      console.log('Admin Password: admin123');
      console.log('⚠️  IMPORTANT: Please change the password after first login!');
    }

    // Disconnect
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    process.exit(0);
  } catch (error) {
    console.error('Error setting up admin:', error);
    process.exit(1);
  }
}

setupAdmin();
