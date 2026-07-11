import type { Request, Response } from "express";
import * as profilesRepository from "../repositories/profiles.repository.js";
import { updateProfileSchema } from "../schemas/profile.schema.js";
import { updateSettingsSchema } from "../schemas/settings.schema.js";

export async function getMe(req: Request, res: Response) {
  const profile = await profilesRepository.getProfile(req.user!.id);
  res.json(profile);
}

export async function updateMe(req: Request, res: Response) {
  const input = updateProfileSchema.parse(req.body);
  const profile = await profilesRepository.updateProfile(req.user!.id, input);
  res.json(profile);
}

export async function getSettings(req: Request, res: Response) {
  const settings = await profilesRepository.getSettings(req.user!.id);
  res.json(settings);
}

export async function updateSettings(req: Request, res: Response) {
  const input = updateSettingsSchema.parse(req.body);
  const settings = await profilesRepository.updateSettings(req.user!.id, input);
  res.json(settings);
}
