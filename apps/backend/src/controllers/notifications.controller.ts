import type { Request, Response } from "express";
import { notificationIdParamsSchema } from "../schemas/notification.schema.js";
import * as notificationsService from "../services/notifications.service.js";

export async function listNotifications(req: Request, res: Response) {
  const notifications = await notificationsService.listNotifications(req.user!.id);
  res.json(notifications);
}

export async function markNotificationRead(req: Request, res: Response) {
  const { id } = notificationIdParamsSchema.parse(req.params);
  const notification = await notificationsService.markNotificationRead(req.user!.id, id);
  res.json(notification);
}

export async function markAllNotificationsRead(req: Request, res: Response) {
  await notificationsService.markAllNotificationsRead(req.user!.id);
  res.status(204).send();
}
