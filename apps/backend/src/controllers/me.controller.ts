import type { Request, Response } from "express";
import * as profilesRepository from "../repositories/profiles.repository.js";
import { updateProfileSchema } from "../schemas/profile.schema.js";

export async function getMe(req: Request, res: Response) {
  const profile = await profilesRepository.getProfile(req.user!.id);
  res.json(profile);
}

export async function updateMe(req: Request, res: Response) {
  const input = updateProfileSchema.parse(req.body);
  const profile = await profilesRepository.updateProfile(req.user!.id, input);
  res.json(profile);
}
