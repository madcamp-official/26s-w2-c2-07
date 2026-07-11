import { Router } from "express";
import * as projectsController from "../controllers/projects.controller.js";
import { requireAuth } from "../middlewares/auth.js";

export const projectsRouter = Router();

projectsRouter.use(requireAuth);

projectsRouter.get("/projects", projectsController.listProjects);
projectsRouter.post("/projects", projectsController.createProject);
projectsRouter.get("/projects/:id", projectsController.getProject);
projectsRouter.get("/projects/:id/export", projectsController.exportProject);
projectsRouter.patch("/projects/:id", projectsController.updateProject);
projectsRouter.patch("/projects/:id/status", projectsController.updateProjectStatus);
projectsRouter.delete("/projects/:id", projectsController.deleteProject);

projectsRouter.get("/projects/:id/captures", projectsController.listProjectCaptures);
projectsRouter.post("/projects/:id/captures", projectsController.linkCapture);
projectsRouter.delete("/projects/:id/captures/:captureId", projectsController.unlinkCapture);
