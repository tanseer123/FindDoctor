const express = require('express');
const { query, validationResult } = require('express-validator');
const Doctor = require('../models/Doctor');
const sequelize = require('../config/database');
const auth = require('../middleware/auth'); // Import auth middleware

const router = express.Router();

/**
 * @route GET /api/doctors/nearby
 * @desc Get nearby doctors based on latitude and longitude
 * @access Public
 */
router.get(
  '/nearby',
  auth, // Middleware now bypasses authentication
  [
    query('lat').isFloat({ min: -90, max: 90 }),
    query('lng').isFloat({ min: -180, max: 180 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { lat, lng } = req.query;

    try {
      const doctors = await Doctor.findAll({
        where: sequelize.where(
          sequelize.fn(
            'ST_DWithin',
            sequelize.col('location'),
            sequelize.fn('ST_MakePoint', parseFloat(lng), parseFloat(lat)),
            5000 // 5km radius
          ),
          true
        ),
      });

      res.json(doctors);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Server Error' });
    }
  }
);

module.exports = router;
