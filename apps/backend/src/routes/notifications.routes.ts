import { Router } from "express";
import * as notificationsController from "../controllers/notifications.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const notificationsRouter = Router();

notificationsRouter.use(requireAuth);

notificationsRouter.get("/notifications", notificationsController.listNotifications);
notificationsRouter.patch("/notifications/read-all", notificationsController.markAllNotificationsRead);
notificationsRouter.patch("/notifications/:id/read", notificationsController.markNotificationRead);
