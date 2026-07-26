const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null // null means it's a global notification
  },
  title: {
    type: String,
    required: true
  },
  body: {
    type: String,
    required: true
  },
  icon: {
    type: String,
    default: '🔔'
  },
  color: {
    type: String,
    default: '#DCFCE7' // Will be parsed by flutter like 0xFFDCFCE7 or similar
  },
  unread: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Notification', notificationSchema);
