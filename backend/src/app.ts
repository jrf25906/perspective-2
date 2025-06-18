import express from 'express';

const app = express();

// Middleware
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Mock authentication endpoints
app.post('/api/auth/login', (req, res) => {
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

app.post('/api/auth/register', (req, res) => {
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
app.get('/api/profile', (req, res) => {
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
