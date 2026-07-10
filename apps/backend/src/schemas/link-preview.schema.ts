import { z } from "zod";

export const linkPreviewRequestSchema = z.object({
  url: z.string().url(),
});

export type LinkPreviewRequestInput = z.infer<typeof linkPreviewRequestSchema>;
