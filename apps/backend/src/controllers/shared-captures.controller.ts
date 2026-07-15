import type { Request, Response } from "express";
import {
  listSharedCapturesQuerySchema,
  reportSharedCaptureSchema,
  sharedCaptureIdParamsSchema,
} from "../schemas/shared-capture.schema.js";
import * as sharedCapturesService from "../services/shared-captures.service.js";

export async function listSharedCaptures(req: Request, res: Response) {
  const { q } = listSharedCapturesQuerySchema.parse(req.query);
  const captures = await sharedCapturesService.listSharedCaptures(req.user!.id, q);
  res.json(captures);
}

export async function saveSharedCapture(req: Request, res: Response) {
  const { id } = sharedCaptureIdParamsSchema.parse(req.params);
  const capture = await sharedCapturesService.saveSharedCapture(req.user!.id, id);
  res.status(201).json(capture);
}

export async function reportSharedCapture(req: Request, res: Response) {
  const { id } = sharedCaptureIdParamsSchema.parse(req.params);
  const { reason } = reportSharedCaptureSchema.parse(req.body);
  await sharedCapturesService.reportSharedCapture(req.user!.id, id, reason);
  res.status(204).send();
}
