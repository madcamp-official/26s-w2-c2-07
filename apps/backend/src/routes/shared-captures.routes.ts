import { Router } from "express";
import * as sharedCapturesController from "../controllers/shared-captures.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const sharedCapturesRouter = Router();

sharedCapturesRouter.use(requireAuth);

sharedCapturesRouter.get("/shared-captures", sharedCapturesController.listSharedCaptures);
sharedCapturesRouter.post("/shared-captures/:id/save", sharedCapturesController.saveSharedCapture);
sharedCapturesRouter.post("/shared-captures/:id/report", sharedCapturesController.reportSharedCapture);
