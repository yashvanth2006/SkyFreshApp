const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { requireAuth } = require('./middleware');

// GET /api/notifications - Fetch notifications for the user (and global)
router.get('/', requireAuth, async (req, res) => {
  try {
    // Fetch notifications where userId matches the current user OR userId is null (global)
    const notifications = await Notification.find({
      $or: [
        { userId: req.user.id },
        { userId: null }
      ]
    }).sort({ createdAt: -1 });

    res.json({ success: true, notifications });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching notifications', error: error.message });
  }
});

// PATCH /api/notifications/read-all - Mark all notifications as read for this user
router.patch('/read-all', requireAuth, async (req, res) => {
  try {
    // Note: marking a global notification (userId: null) as read for a specific user
    // would normally require tracking read status per user, but for simplicity here
    // we'll just update the document itself. If it's a global notification, it gets
    // marked read for everyone. To avoid this, we could only mark user-specific ones as read.
    await Notification.updateMany(
      { userId: req.user.id, unread: true },
      { unread: false }
    );
    res.json({ success: true, message: 'User notifications marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error marking notifications as read', error: error.message });
  }
});

// PATCH /api/notifications/:id/read - Mark a specific notification as read
router.patch('/:id/read', requireAuth, async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }
    
    // Only allow updating if it belongs to the user or is global
    if (notification.userId && notification.userId.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    notification.unread = false;
    await notification.save();
    
    res.json({ success: true, notification });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating notification', error: error.message });
  }
});

// DELETE /api/notifications/:id - Delete (dismiss) a notification
router.delete('/:id', requireAuth, async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }
    
    if (notification.userId && notification.userId.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    await Notification.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Notification deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error deleting notification', error: error.message });
  }
});

module.exports = router;
