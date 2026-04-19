import mongoose, { Document, Schema } from 'mongoose';

export interface IProject extends Document {
  userEmail: string;
  projectName: string;
  prompt: string;
  generatedCode: string;
}

const ProjectSchema: Schema = new Schema(
  {
    userEmail: { type: String, required: true },
    projectName: { type: String, required: true },
    prompt: { type: String, required: true },
    generatedCode: { type: String, required: true },
  },
  { timestamps: true }
);

export default mongoose.model<IProject>('Project', ProjectSchema);