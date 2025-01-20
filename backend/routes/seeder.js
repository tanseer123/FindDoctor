const express = require('express');
const Doctor = require('../models/Doctor');

const router = express.Router();

router.post('/seed-doctors', async (req, res) => {
  try {
    const doctors = [
      {
        name: 'Dr. Alice Smith',
        specialization: 'Cardiologist',
        fee: 200,
        location: { type: 'Point', coordinates: [-122.4194, 37.7749] }, // San Francisco
      },
      {
        name: 'Dr. Bob Johnson',
        specialization: 'Neurologist',
        fee: 250,
        location: { type: 'Point', coordinates: [-122.4313, 37.7735] }, // Nearby SF
      },
      // Add more sample doctors as needed
      {
        name: 'Dr. Priya Kumar',
        specialization: 'Cardiologist',
        fee: 1000,
        location: { type: 'Point', coordinates: [77.5815, 12.9401] }, // Near your location
      },
      {
        name: 'Dr. Ravi Shankar',
        specialization: 'Neurologist',
        fee: 1200,
        location: { type: 'Point', coordinates: [77.5825, 12.9405] }, // ~500m from your location
      },
      {
        name: 'Dr. Anita Desai',
        specialization: 'Pediatrician',
        fee: 800,
        location: { type: 'Point', coordinates: [77.5835, 12.9395] }, // ~1km from your location
      },
      {
        name: 'Dr. Suresh Patel',
        specialization: 'Orthopedic',
        fee: 900,
        location: { type: 'Point', coordinates: [77.5805, 12.9410] }, // ~800m from your location
      },
      {
        name: 'Dr. Meena Sharma',
        specialization: 'Dermatologist',
        fee: 1500,
        location: { type: 'Point', coordinates: [77.5795, 12.9398] }, // ~600m from your location
      },
    ];

    await Doctor.bulkCreate(doctors);
    res.status(201).json({ message: 'Doctors seeded successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server Error' });
  }
});

module.exports = router;
