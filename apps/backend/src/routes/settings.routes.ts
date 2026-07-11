import { Router } from "express";
import * as settingsController from "../controllers/settings.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const settingsRouter = Router();

settingsRouter.use(requireAuth);

settingsRouter.get("/settings", settingsController.getSettings);
settingsRouter.patch("/settings", settingsController.updateSettings);
