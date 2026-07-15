import * as sharedCapturesRepository from "../repositories/shared-captures.repository.js";

export function listSharedCaptures(viewerId: string, q?: string) {
  return sharedCapturesRepository.listSharedCaptures(viewerId, q);
}

export function saveSharedCapture(userId: string, captureId: string) {
  return sharedCapturesRepository.saveSharedCapture(userId, captureId);
}

export function reportSharedCapture(userId: string, captureId: string, reason: string) {
  return sharedCapturesRepository.reportSharedCapture(userId, captureId, reason);
}
