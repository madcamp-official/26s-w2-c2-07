import { Router } from "express";
import * as linkPreviewController from "../controllers/link-preview.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const linkPreviewRouter = Router();

linkPreviewRouter.post("/link-preview", requireAuth, linkPreviewController.getLinkPreview);
