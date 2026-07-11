import { Router } from "express";
import { capturesRouter } from "./captures.routes.js";
import { documentsRouter } from "./documents.routes.js";
import { linkPreviewRouter } from "./link-preview.routes.js";
import { meRouter } from "./me.routes.js";
import { projectsRouter } from "./projects.routes.js";
import { settingsRouter } from "./settings.routes.js";
import { tagsRouter } from "./tags.routes.js";

export const apiRouter = Router();

apiRouter.use(meRouter);
apiRouter.use(settingsRouter);
apiRouter.use(capturesRouter);
apiRouter.use(projectsRouter);
apiRouter.use(documentsRouter);
apiRouter.use(linkPreviewRouter);
apiRouter.use(tagsRouter);
