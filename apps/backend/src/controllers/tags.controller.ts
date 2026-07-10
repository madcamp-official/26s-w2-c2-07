import type { Request, Response } from "express";
import { captureIdParamsSchema } from "../schemas/capture.schema.js";
import {
  attachTagSchema,
  captureTagParamsSchema,
  createTagSchema,
  tagIdParamsSchema,
} from "../schemas/tag.schema.js";
import * as tagsService from "../services/tags.service.js";

export async function listTags(req: Request, res: Response) {
  const tags = await tagsService.listTags(req.user!.id);
  res.json(tags);
}

export async function createTag(req: Request, res: Response) {
  const input = createTagSchema.parse(req.body);
  const tag = await tagsService.createTag(req.user!.id, input);
  res.status(201).json(tag);
}

export async function deleteTag(req: Request, res: Response) {
  const { id } = tagIdParamsSchema.parse(req.params);
  await tagsService.deleteTag(req.user!.id, id);
  res.status(204).send();
}

export async function attachTag(req: Request, res: Response) {
  const { id } = captureIdParamsSchema.parse(req.params);
  const { tagId } = attachTagSchema.parse(req.body);
  await tagsService.attachTag(req.user!.id, id, tagId);
  res.status(201).send();
}

export async function detachTag(req: Request, res: Response) {
  const { id, tagId } = captureTagParamsSchema.parse(req.params);
  await tagsService.detachTag(req.user!.id, id, tagId);
  res.status(204).send();
}
