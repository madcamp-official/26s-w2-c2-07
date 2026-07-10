import { Router } from "express";
import * as documentsController from "../controllers/documents.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const documentsRouter = Router();

documentsRouter.use(requireAuth);

documentsRouter.get("/projects/:id/documents", documentsController.listDocuments);
documentsRouter.post("/projects/:id/documents", documentsController.createDocument);
documentsRouter.get("/projects/:id/documents/:documentId", documentsController.getDocument);
documentsRouter.patch("/projects/:id/documents/:documentId", documentsController.updateDocument);
documentsRouter.delete("/projects/:id/documents/:documentId", documentsController.deleteDocument);
