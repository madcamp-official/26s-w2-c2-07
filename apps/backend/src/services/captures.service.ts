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

export async function updateCapture(userId: string, captureId: string, input: UpdateCaptureInput) {
  if (input.url === undefined) {
    return capturesRepository.updateCapture(userId, captureId, input);
  }

  // URL이 실제로 바뀐 경우에만 미리보기를 다시 가져온다 (안 바뀐 저장 요청마다 외부 사이트를 재크롤링하지 않도록).
  const current = await capturesRepository.getCaptureById(userId, captureId);
  if (current.url === input.url) {
    return capturesRepository.updateCapture(userId, captureId, input);
  }

  const preview = await fetchLinkPreview(input.url);
  return capturesRepository.updateCapture(userId, captureId, input, {
    linkTitle: preview.title,
    linkDescription: preview.description,
    linkImageUrl: preview.imageUrl,
  });
}

export function deleteCapture(userId: string, captureId: string) {
  return capturesRepository.deleteCapture(userId, captureId);
}
