const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Admin = require('../models/Admin');
require('dotenv').config();

async function createAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/skyfresh');
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ username: 'admin' });
    
    if (existingAdmin) {
      console.log('Admin user already exists. Updating password...');
      const hashedPassword = await bcrypt.hash('admin2006', 10);
      existingAdmin.password = hashedPassword;
      await existingAdmin.save();
      console.log('Admin password updated successfully!');
      console.log('Username: admin');
      console.log('Password: admin2006');
    } else {
      // Create new admin user with hashed password
      const hashedPassword = await bcrypt.hash('admin2006', 10);
      const admin = new Admin({
        username: 'admin',
        password: hashedPassword,
        name: 'SKYfresh Admin'
      });

      await admin.save();
      console.log('Admin user created successfully!');
      console.log('Username: admin');
      console.log('Password: admin2006');
    }

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
    process.exit(0);
  } catch (error) {
    console.error('Error creating admin:', error);
    process.exit(1);
  }
}

createAdmin();
