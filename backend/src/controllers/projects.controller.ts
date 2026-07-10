import type { Request, Response } from "express";
import {
  createProjectSchema,
  linkCaptureSchema,
  projectCaptureParamsSchema,
  projectIdParamsSchema,
  updateProjectSchema,
} from "../schemas/project.schema.js";
import * as projectsService from "../services/projects.service.js";

export async function listProjects(req: Request, res: Response) {
  const projects = await projectsService.listProjects(req.user!.id);
  res.json(projects);
}

export async function getProject(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  const project = await projectsService.getProject(req.user!.id, id);
  res.json(project);
}

export async function createProject(req: Request, res: Response) {
  const input = createProjectSchema.parse(req.body);
  const project = await projectsService.createProject(req.user!.id, input);
  res.status(201).json(project);
}

export async function updateProject(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  const input = updateProjectSchema.parse(req.body);
  const project = await projectsService.updateProject(req.user!.id, id, input);
  res.json(project);
}

export async function deleteProject(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  await projectsService.deleteProject(req.user!.id, id);
  res.status(204).send();
}

export async function listProjectCaptures(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  const captures = await projectsService.listProjectCaptures(req.user!.id, id);
  res.json(captures);
}

export async function linkCapture(req: Request, res: Response) {
  const { id } = projectIdParamsSchema.parse(req.params);
  const { captureId } = linkCaptureSchema.parse(req.body);
  await projectsService.linkCapture(req.user!.id, id, captureId);
  res.status(201).send();
}

export async function unlinkCapture(req: Request, res: Response) {
  const { id, captureId } = projectCaptureParamsSchema.parse(req.params);
  await projectsService.unlinkCapture(req.user!.id, id, captureId);
  res.status(204).send();
}
