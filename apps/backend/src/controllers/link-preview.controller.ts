import type { Request, Response } from "express";
import { linkPreviewRequestSchema } from "../schemas/link-preview.schema.js";
import { fetchLinkPreview } from "../services/link-preview.service.js";

export async function getLinkPreview(req: Request, res: Response) {
  const { url } = linkPreviewRequestSchema.parse(req.body);
  const preview = await fetchLinkPreview(url);
  res.json(preview);
}
