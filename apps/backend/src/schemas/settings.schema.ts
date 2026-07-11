import { z } from "zod";

export const updateSettingsSchema = z.object({
  notifyEnabled: z.boolean().optional(),
  darkEditor: z.boolean().optional(),
});

export type UpdateSettingsInput = z.infer<typeof updateSettingsSchema>;
