import express from 'express';

const app = express();

// Middleware
app.use(express.json());

// CORS configuration
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Mock authentication endpoints
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Mock successful login
  if (email && password) {
    const mockUser = {
      id: 1,
      email: email,
      username: email.split('@')[0],
      firstName: 'Test',
      lastName: 'User',
      avatarUrl: null,
      isActive: true,
      emailVerified: true,
      echoScore: 75.5,
      biasProfile: null,
      preferredChallengeTime: null,
      currentStreak: 0,
      lastActivityDate: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      lastLoginAt: new Date().toISOString(),
      role: 'user',
      deletedAt: null,
      googleId: null
    };
    
    res.json({
      user: mockUser,
      token: 'mock-jwt-token-12345'
    });
  } else {
    res.status(400).json({
      error: {
        message: 'Email and password are required',
        code: 'INVALID_CREDENTIALS'
      }
    });
  }
});

app.post('/api/v1/auth/register', (req, res) => {
  const { email, password, username, firstName, lastName } = req.body;
  
  // Mock successful registration
  if (email && password) {
    const mockUser = {
      id: 1,
      email: email,
      username: username || email.split('@')[0],
      firstName: firstName || 'New',
      lastName: lastName || 'User',
      avatarUrl: null,
      isActive: true,
      emailVerified: false,
      echoScore: 0.0,
      biasProfile: null,
      preferredChallengeTime: null,
      currentStreak: 0,
      lastActivityDate: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      lastLoginAt: new Date().toISOString(),
      role: 'user',
      deletedAt: null,
      googleId: null
    };
    
    res.json({
      user: mockUser,
      token: 'mock-jwt-token-12345'
    });
  } else {
    res.status(400).json({
      error: {
        message: 'Email and password are required',
        code: 'VALIDATION_ERROR'
      }
    });
  }
});

// Mock profile endpoint
app.get('/api/v1/profile', (req, res) => {
  res.json({
    success: true,
    data: {
      user: {
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        username: 'test'
      }
    }
  });
});

export default app;
