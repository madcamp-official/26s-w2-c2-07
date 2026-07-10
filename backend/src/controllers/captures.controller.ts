import type { Request, Response } from "express";
import { createUploadUrlSchema, completeUploadSchema } from "../schemas/asset.schema.js";
import {
  captureIdParamsSchema,
  createCaptureSchema,
  listCapturesQuerySchema,
  updateCaptureSchema,
} from "../schemas/capture.schema.js";
import * as capturesService from "../services/captures.service.js";
import * as storageService from "../services/storage.service.js";

export async function listCaptures(req: Request, res: Response) {
  const { type } = listCapturesQuerySchema.parse(req.query);
  const captures = await capturesService.listCaptures(req.user!.id, type);
  res.json(captures);
}

export async function getCapture(req: Request, res: Response) {
  const { id } = captureIdParamsSchema.parse(req.params);
  const capture = await capturesService.getCapture(req.user!.id, id);
  res.json(capture);
}

export async function createCapture(req: Request, res: Response) {
  const input = createCaptureSchema.parse(req.body);
  const capture = await capturesService.createCapture(req.user!.id, input);
  res.status(201).json(capture);
}

export async function updateCapture(req: Request, res: Response) {
  const { id } = captureIdParamsSchema.parse(req.params);
  const input = updateCaptureSchema.parse(req.body);
  const capture = await capturesService.updateCapture(req.user!.id, id, input);
  res.json(capture);
}

export async function deleteCapture(req: Request, res: Response) {
  const { id } = captureIdParamsSchema.parse(req.params);
  await capturesService.deleteCapture(req.user!.id, id);
  res.status(204).send();
}

export async function createUploadUrl(req: Request, res: Response) {
  const { id } = captureIdParamsSchema.parse(req.params);
  const { fileName } = createUploadUrlSchema.parse(req.body);
  const result = await storageService.createUploadUrl(req.user!.id, id, fileName);
  res.status(201).json(result);
}

export async function completeUpload(req: Request, res: Response) {
  const { id } = captureIdParamsSchema.parse(req.params);
  const { storagePath } = completeUploadSchema.parse(req.body);
  const asset = await storageService.completeUpload(req.user!.id, id, storagePath);
  res.status(201).json(asset);
}
