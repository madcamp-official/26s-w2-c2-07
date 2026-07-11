import { z } from "zod";

export const createDocumentSchema = z.object({
  title: z.string().min(1).max(200).default("제목 없음"),
  content: z.string().max(200_000).default(""),
});

export const updateDocumentSchema = z.object({
  title: z.string().max(200).optional(), // 자동저장 도중 제목을 잠깐 지운 빈 문자열도 유효한 상태다
  content: z.string().max(200_000).optional(),
});

export const documentIdParamsSchema = z.object({
  id: z.string().uuid(), // projectId
  documentId: z.string().uuid(),
});

export type CreateDocumentInput = z.infer<typeof createDocumentSchema>;
export type UpdateDocumentInput = z.infer<typeof updateDocumentSchema>;
