import type { Request, Response } from "express";
import { updateSettingsSchema } from "../schemas/settings.schema.js";
import * as settingsService from "../services/settings.service.js";

export async function getSettings(req: Request, res: Response) {
  const settings = await settingsService.getSettings(req.user!.id);
  res.json(settings);
}

export async function updateSettings(req: Request, res: Response) {
  const input = updateSettingsSchema.parse(req.body);
  const settings = await settingsService.updateSettings(req.user!.id, input);
  res.json(settings);
}
