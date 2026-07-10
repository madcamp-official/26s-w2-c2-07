import * as capturesRepository from "../repositories/captures.repository.js";
import type { CreateCaptureInput, UpdateCaptureInput } from "../schemas/capture.schema.js";
import { HttpError } from "../utils/http-error.js";
import { fetchLinkPreview } from "./link-preview.service.js";

export function listCaptures(userId: string, type?: string) {
  return capturesRepository.listCaptures(userId, type);
}

export function getCapture(userId: string, captureId: string) {
  return capturesRepository.getCaptureById(userId, captureId);
}

export async function createCapture(userId: string, input: CreateCaptureInput) {
  if (input.type === "text" && !input.content) {
    throw HttpError.badRequest("content is required for text captures");
  }
  if (input.type === "link" && !input.url) {
    throw HttpError.badRequest("url is required for link captures");
  }

  if (input.type === "link" && input.url) {
    const preview = await fetchLinkPreview(input.url);
    return capturesRepository.createCapture(userId, input, {
      linkTitle: preview.title,
      linkDescription: preview.description,
      linkImageUrl: preview.imageUrl,
    });
  }

  return capturesRepository.createCapture(userId, input);
}

export function updateCapture(userId: string, captureId: string, input: UpdateCaptureInput) {
  return capturesRepository.updateCapture(userId, captureId, input);
}

export function deleteCapture(userId: string, captureId: string) {
  return capturesRepository.deleteCapture(userId, captureId);
}
