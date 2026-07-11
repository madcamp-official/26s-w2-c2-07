import type { Request, Response } from "express";
import { updateProfileSchema } from "../schemas/profile.schema.js";
import * as meService from "../services/me.service.js";

export async function getMe(req: Request, res: Response) {
  const profile = await meService.getMe(req.user!.id);
  res.json(profile);
}

export async function updateMe(req: Request, res: Response) {
  const input = updateProfileSchema.parse(req.body);
  const profile = await meService.updateMe(req.user!.id, input);
  res.json(profile);
}

export async function deleteMe(req: Request, res: Response) {
  await meService.deleteMe(req.user!.id);
  res.status(204).send();
}
