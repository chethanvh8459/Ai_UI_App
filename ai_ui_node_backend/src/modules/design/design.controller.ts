import { Request, Response } from 'express';
import { GoogleGenAI } from '@google/genai';
import Project from '../../database/models/project.model';

const ai = new GoogleGenAI({}); 

export const generateUI = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, projectName = 'Untitled UI', prompt } = req.body;

    if (!prompt) {
      res.status(400).json({ status: 'error', message: 'Prompt is required' });
      return;
    }

    console.log(`🎨 Generating JSON UI for: ${email || 'Guest'} | Project: ${projectName}`);

    // 🔥 THE NEW JSON-DRIVEN INSTRUCTION
   const aiInstruction = `
    You are an expert Flutter Server-Driven UI generator. 
    Create a JSON representation of a Flutter UI for the following request: '${prompt}'.
    
    CRITICAL RULES:
    1. Provide ONLY valid JSON. 
    2. Do NOT include markdown formatting like \`\`\`json or \`\`\`. Just the raw JSON object.
    3. Use a schema compatible with the Flutter 'stac' package. 
    4. Always wrap the root in a Scaffold. 
    
    
    Example format:
    {
      "type": "scaffold",
      "backgroundColor": "#F5F5F5",
      "appBar": { "type": "appBar", "title": { "type": "text", "data": "Title" } },
      "body": { "type": "column", "children": [ { "type": "text", "data": "Hello World" } ] }
    }
    `;
    console.log("🚨 SENDING THIS INSTRUCTION TO GEMINI: 🚨\n", aiInstruction);
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: aiInstruction,
    });

    // Clean the text just in case Gemini accidentally adds markdown
    let generatedCode = response.text || "{}";
    generatedCode = generatedCode.replace(/```json/g, '').replace(/```/g, '').trim();

    const newProject = new Project({
      userEmail: email || 'anonymous',
      projectName,
      prompt,
      generatedCode
    });
    await newProject.save();

    res.status(200).json({
      status: 'success',
      code: generatedCode
    });

  } catch (error: any) {
    console.error('❌ AI Generation Error:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
};

export const getUserProjects = async (req: any, res: any) => {
  try {
    const userEmail = req.params.email;
    const projects = await Project.find({ userEmail: userEmail }).sort({ createdAt: -1 });
    res.status(200).json({ status: 'success', data: projects });
  } catch (error) {
    console.error("Error fetching projects:", error);
    res.status(500).json({ status: 'error', message: 'Failed to fetch projects' });
  }
};