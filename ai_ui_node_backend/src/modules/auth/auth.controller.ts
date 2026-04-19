import { Request, Response } from 'express';
import User from '../../database/models/user.model';

export const signup = async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, email, password } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      res.status(400).json({ status: 'error', message: 'Email already in use' });
      return;
    }

    // Create new user (Note: In production, ALWAYS hash this password with bcrypt!)
    const newUser = new User({ username, email, password });
    await newUser.save();

    res.status(201).json({ status: 'success', message: 'User created successfully' });
  } catch (error: any) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email, password });
    
    if (!user) {
      res.status(401).json({ status: 'error', message: 'Invalid credentials' });
      return;
    }

    res.status(200).json({
      status: 'success',
      message: 'Login successful',
      data: {
        username: user.username,
        email: user.email,
        level: user.level,
        role: user.role
      }
    });
  } catch (error: any) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};