import { z } from "zod";

export const captureTypeSchema = z.enum(["text", "photo", "link", "video"]);

export const listCapturesQuerySchema = z.object({
  type: captureTypeSchema.optional(),
});

export const createCaptureSchema = z.object({
  type: captureTypeSchema,
  content: z.string().max(10_000).optional(), // 조각글 본문 / 링크 메모
  url: z.string().url().optional(), // type === "link"
  tagIds: z.array(z.string().uuid()).max(20).optional(),
  isShared: z.boolean().optional(), // true면 글감 서핑에 노출된다
});

export const updateCaptureSchema = z.object({
  content: z.string().max(10_000).optional(),
  url: z.string().url().optional(),
  tagIds: z.array(z.string().uuid()).max(20).optional(),
  isShared: z.boolean().optional(),
});

export const captureIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export type CreateCaptureInput = z.infer<typeof createCaptureSchema>;
export type UpdateCaptureInput = z.infer<typeof updateCaptureSchema>;
