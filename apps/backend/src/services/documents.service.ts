import * as documentsRepository from "../repositories/documents.repository.js";
import type { CreateDocumentInput, UpdateDocumentInput } from "../schemas/document.schema.js";

export function listDocuments(userId: string, projectId: string) {
  return documentsRepository.listDocuments(userId, projectId);
}

export function getDocument(userId: string, projectId: string, documentId: string) {
  return documentsRepository.getDocumentById(userId, projectId, documentId);
}

export function createDocument(userId: string, projectId: string, input: CreateDocumentInput) {
  return documentsRepository.createDocument(userId, projectId, input);
}

export function updateDocument(userId: string, projectId: string, documentId: string, input: UpdateDocumentInput) {
  return documentsRepository.updateDocument(userId, projectId, documentId, input);
}

export function deleteDocument(userId: string, projectId: string, documentId: string) {
  return documentsRepository.deleteDocument(userId, projectId, documentId);
}
