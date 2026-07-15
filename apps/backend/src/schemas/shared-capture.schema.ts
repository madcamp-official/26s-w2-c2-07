import { z } from "zod";

export const listSharedCapturesQuerySchema = z.object({
  q: z.string().max(200).optional(),
});

export const sharedCaptureIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const reportSharedCaptureSchema = z.object({
  reason: z.string().min(1).max(200),
});

export type ListSharedCapturesQuery = z.infer<typeof listSharedCapturesQuerySchema>;
export type ReportSharedCaptureInput = z.infer<typeof reportSharedCaptureSchema>;
