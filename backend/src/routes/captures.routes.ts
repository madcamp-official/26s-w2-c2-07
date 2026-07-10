import { Router } from "express";
import * as capturesController from "../controllers/captures.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const capturesRouter = Router();

capturesRouter.use(requireAuth);

capturesRouter.get("/captures", capturesController.listCaptures);
capturesRouter.post("/captures", capturesController.createCapture);
capturesRouter.get("/captures/:id", capturesController.getCapture);
capturesRouter.patch("/captures/:id", capturesController.updateCapture);
capturesRouter.delete("/captures/:id", capturesController.deleteCapture);

capturesRouter.post("/captures/:id/assets/upload-url", capturesController.createUploadUrl);
capturesRouter.post("/captures/:id/assets/complete", capturesController.completeUpload);
