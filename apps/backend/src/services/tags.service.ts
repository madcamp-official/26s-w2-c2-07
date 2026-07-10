import * as tagsRepository from "../repositories/tags.repository.js";
import type { CreateTagInput } from "../schemas/tag.schema.js";

export function listTags(userId: string) {
  return tagsRepository.listTags(userId);
}

export function createTag(userId: string, input: CreateTagInput) {
  return tagsRepository.createTag(userId, input);
}

export function deleteTag(userId: string, tagId: string) {
  return tagsRepository.deleteTag(userId, tagId);
}

export function attachTag(userId: string, captureId: string, tagId: string) {
  return tagsRepository.attachTag(userId, captureId, tagId);
}

export function detachTag(userId: string, captureId: string, tagId: string) {
  return tagsRepository.detachTag(userId, captureId, tagId);
}
