const express = require('express');
const router = express.Router();

// Coimbatore city center coordinates
const COIMBATORE_CENTER = {
  lat: 11.0168,
  lng: 76.9558
};

// Maximum serviceable radius in kilometers
const MAX_RADIUS_KM = 30; // Using 30km to cover all over Coimbatore including outskirts

// Haversine formula to calculate distance between two coordinates
function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

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
