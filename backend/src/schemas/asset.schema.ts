import { z } from "zod";

export const createUploadUrlSchema = z.object({
  fileName: z.string().min(1),
  contentType: z.string().min(1), // e.g. "image/jpeg"
});

export const completeUploadSchema = z.object({
  storagePath: z.string().min(1),
});

export type CreateUploadUrlInput = z.infer<typeof createUploadUrlSchema>;
export type CompleteUploadInput = z.infer<typeof completeUploadSchema>;
