import { z } from "zod";

export const createDocumentSchema = z.object({
  title: z.string().min(1).max(200).default("제목 없음"),
  content: z.string().max(200_000).default(""),
});

export const updateDocumentSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  content: z.string().max(200_000).optional(),
});

export const documentIdParamsSchema = z.object({
  id: z.string().uuid(), // projectId
  documentId: z.string().uuid(),
});

export type CreateDocumentInput = z.infer<typeof createDocumentSchema>;
export type UpdateDocumentInput = z.infer<typeof updateDocumentSchema>;
