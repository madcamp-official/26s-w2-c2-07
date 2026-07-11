import { z } from "zod";

export const updateSettingsSchema = z.object({
  captureAlertsEnabled: z.boolean().optional(),
  darkEditorEnabled: z.boolean().optional(),
});

export type UpdateSettingsInput = z.infer<typeof updateSettingsSchema>;
