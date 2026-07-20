const express = require('express');
const router = express.Router();

// GET /api/serviceability/check?lat=X&lng=Y
router.get('/check', (req, res) => {
  try {
    res.json({
      serviceable: true,
      distance: 0,
      city: 'Global',
      message: 'Location is serviceable.'
    });
  } catch (error) {
    console.error('Serviceability check error:', error);
    res.status(500).json({ error: 'Failed to check serviceability' });
  }
});

module.exports = router;
