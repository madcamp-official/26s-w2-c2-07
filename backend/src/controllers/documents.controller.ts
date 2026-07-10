import type { Request, Response } from "express";
import {
  createDocumentSchema,
  documentIdParamsSchema,
  updateDocumentSchema,
} from "../schemas/document.schema.js";
import { projectIdParamsSchema } from "../schemas/project.schema.js";
import * as documentsService from "../services/documents.service.js";

export async function listDocuments(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  const documents = await documentsService.listDocuments(req.user!.id, id);
  res.json(documents);
}

export async function createDocument(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  const input = createDocumentSchema.parse(req.body);
  const document = await documentsService.createDocument(req.user!.id, id, input);
  res.status(201).json(document);
}

export async function getDocument(req: Request, res: Response) {
  const { id, documentId } = documentIdParamsSchema.parse(req.params);
  const document = await documentsService.getDocument(req.user!.id, id, documentId);
  res.json(document);
}

export async function updateDocument(req: Request, res: Response) {
  const { id, documentId } = documentIdParamsSchema.parse(req.params);
  const input = updateDocumentSchema.parse(req.body);
  const document = await documentsService.updateDocument(req.user!.id, id, documentId, input);
  res.json(document);
}

export async function deleteDocument(req: Request, res: Response) {
  const { id, documentId } = documentIdParamsSchema.parse(req.params);
  await documentsService.deleteDocument(req.user!.id, id, documentId);
  res.status(204).send();
}
