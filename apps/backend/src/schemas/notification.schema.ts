import { z } from "zod";

export const notificationIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const notificationSourceSchema = z.enum(["mobile", "web"]);
export type NotificationSource = z.infer<typeof notificationSourceSchema>;
