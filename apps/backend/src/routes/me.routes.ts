import { Router } from "express";
import * as meController from "../controllers/me.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const meRouter = Router();

meRouter.get("/me", requireAuth, meController.getMe);
meRouter.patch("/me", requireAuth, meController.updateMe);
meRouter.get("/me/settings", requireAuth, meController.getSettings);
meRouter.patch("/me/settings", requireAuth, meController.updateSettings);
