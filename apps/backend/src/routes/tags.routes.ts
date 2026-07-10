import { Router } from "express";
import * as tagsController from "../controllers/tags.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const tagsRouter = Router();

tagsRouter.use(requireAuth);

tagsRouter.get("/tags", tagsController.listTags);
tagsRouter.post("/tags", tagsController.createTag);
tagsRouter.delete("/tags/:id", tagsController.deleteTag);

tagsRouter.post("/captures/:id/tags", tagsController.attachTag);
tagsRouter.delete("/captures/:id/tags/:tagId", tagsController.detachTag);
