import { z } from "zod";

export const createTagSchema = z.object({
  name: z.string().min(1).max(30),
  color: z.string().max(20).optional(),
});

export const tagIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const attachTagSchema = z.object({
  tagId: z.string().uuid(),
});

export const captureTagParamsSchema = z.object({
  id: z.string().uuid(), // captureId
  tagId: z.string().uuid(),
});

export type CreateTagInput = z.infer<typeof createTagSchema>;
