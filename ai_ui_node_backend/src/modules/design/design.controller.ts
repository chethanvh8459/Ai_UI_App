import { Request, Response } from 'express';
import { GoogleGenAI } from '@google/genai';
import Project from '../../database/models/project.model';

// Initialize the Gemini AI Client
// It automatically looks for GEMINI_API_KEY in your .env file
const ai = new GoogleGenAI({}); 

// 🔥 1. GENERATE NEW UI VIA GEMINI
export const generateUI = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, projectName = 'Untitled UI', prompt } = req.body;

    if (!prompt) {
      res.status(400).json({ status: 'error', message: 'Prompt is required' });
      return;
    }

    console.log(`🎨 Generating UI for: ${email || 'Guest'} | Project: ${projectName}`);

    // The instruction for the AI
    const aiInstruction = `
    You are an expert Flutter UI/UX designer. 
    Create Flutter widget code for the following request: '${prompt}'.
    Provide ONLY the Dart code. Do not include markdown formatting like \`\`\`dart or explanations. Just the raw code.
    `;

    // Call Gemini 2.5 Flash
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: aiInstruction,
    });

    const generatedCode = response.text;

    // Save the result to MongoDB
    const newProject = new Project({
      userEmail: email || 'anonymous', // 👈 Saved as userEmail
      projectName,
      prompt,
      generatedCode
    });
    await newProject.save();

    // Send the code back to Flutter
    res.status(200).json({
      status: 'success',
      code: generatedCode
    });

  } catch (error: any) {
    console.error('❌ AI Generation Error:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
};

// 🔥 2. GET ALL PROJECTS FOR A SPECIFIC USER
export const getUserProjects = async (req: any, res: any) => {
  try {
    const userEmail = req.params.email;
    
    // Find all projects matching the email, sort by newest first
    // 🔴 FIXED: Now correctly searching for userEmail to match the save logic above!
    const projects = await Project.find({ userEmail: userEmail }).sort({ createdAt: -1 });
    
    res.status(200).json({ status: 'success', data: projects });
  } catch (error) {
    console.error("Error fetching projects:", error);
    res.status(500).json({ status: 'error', message: 'Failed to fetch projects' });
  }
};