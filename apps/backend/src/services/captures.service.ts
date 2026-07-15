import * as capturesRepository from "../repositories/captures.repository.js";
import type { CreateCaptureInput, UpdateCaptureInput } from "../schemas/capture.schema.js";
import type { NotificationSource } from "../schemas/notification.schema.js";
import { HttpError } from "../utils/http-error.js";
import { fetchLinkPreview } from "./link-preview.service.js";
import * as notificationsService from "./notifications.service.js";

export function listCaptures(userId: string, type?: string) {
  return capturesRepository.listCaptures(userId, type);
}

export function getCapture(userId: string, captureId: string) {
  return capturesRepository.getCaptureById(userId, captureId);
}

function captureNotificationText(input: CreateCaptureInput, capture: any) {
  switch (input.type) {
    case "photo":
      return { title: "새 사진 글감이 도착했어요", detail: input.content?.slice(0, 40) ?? "사진 기록" };
    case "video":
      return { title: "새 동영상 글감이 도착했어요", detail: input.content?.slice(0, 40) ?? "동영상 기록" };
    case "link":
      return { title: "새 링크를 확인해보세요", detail: capture.link_title ?? input.url ?? null };
    default:
      return { title: "새 글감이 도착했어요", detail: input.content?.slice(0, 40) ?? null };
  }
}

export async function createCapture(
  userId: string,
  input: CreateCaptureInput,
  source: NotificationSource = "web",
) {
  if (input.type === "text" && !input.content) {
    throw HttpError.badRequest("content is required for text captures");
  }
  if (input.type === "link" && !input.url) {
    throw HttpError.badRequest("url is required for link captures");
  }

  let capture;
  if (input.type === "link" && input.url) {
    const preview = await fetchLinkPreview(input.url);
    capture = await capturesRepository.createCapture(userId, input, {
      linkTitle: preview.title,
      linkDescription: preview.description,
      linkImageUrl: preview.imageUrl,
    });
  } else {
    capture = await capturesRepository.createCapture(userId, input);
  }

  const { title, detail } = captureNotificationText(input, capture);
  await notificationsService.notifyIfEnabled(userId, source, title, detail);

  return capture;
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
