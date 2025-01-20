require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const sequelize = require('./config/database');

const doctorsRoute = require('./routes/doctors');
const seederRoute = require('./routes/seeder');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: ["https://cuddly-yodel-gr9r5rvw7p4h6v-43299.app.github.dev", "http://localhost:3000"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true
  }
});
// ✅ Use CORS Middleware
const corsOptions = {
  origin: ["https://cuddly-yodel-gr9r5rvw7p4h6v-43299.app.github.dev", "http://localhost:3000"],
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true
};

app.use(cors(corsOptions));

app.use(express.json());

// ✅ Test Route
app.get('/', (req, res) => {
  res.send('FindDoctor Backend is Running...');
});

// ✅ Socket.io Connection Handling
io.on('connection', (socket) => {
  console.log(`New client connected: ${socket.id}`);

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

// ✅ API Routes
app.use('/api/doctors', doctorsRoute);
app.use('/api', seederRoute);

// ✅ Database Connection and Server Start
const PORT = process.env.PORT || 3000;

sequelize.authenticate()
  .then(() => {
    console.log('✅ Database connected successfully.');
    return sequelize.sync({ force: false });
  })
  .then(() => {
    console.log('✅ Database & tables synchronized.');
    server.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ Database connection failed:', err);
    process.exit(1);
  });
