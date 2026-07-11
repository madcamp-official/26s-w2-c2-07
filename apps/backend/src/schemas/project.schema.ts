import { z } from "zod";

export const projectStatusSchema = z.enum(["active", "done"]);

export const createProjectSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(2000).optional(),
});

export const updateProjectSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  description: z.string().max(2000).optional(),
});

export const updateProjectStatusSchema = z.object({
  status: projectStatusSchema,
});

export const exportProjectQuerySchema = z.object({
  format: z.enum(["pdf", "docx", "txt"]),
});

export const projectIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const linkCaptureSchema = z.object({
  captureId: z.string().uuid(),
});

export const projectCaptureParamsSchema = z.object({
  id: z.string().uuid(),
  captureId: z.string().uuid(),
});

export type CreateProjectInput = z.infer<typeof createProjectSchema>;
export type UpdateProjectInput = z.infer<typeof updateProjectSchema>;
export type UpdateProjectStatusInput = z.infer<typeof updateProjectStatusSchema>;
export type ExportProjectFormat = z.infer<typeof exportProjectQuerySchema>["format"];
