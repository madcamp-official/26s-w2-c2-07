import * as projectsRepository from "../repositories/projects.repository.js";
import type { CreateProjectInput, UpdateProjectInput } from "../schemas/project.schema.js";

export function listProjects(userId: string) {
  return projectsRepository.listProjects(userId);
}

export function getProject(userId: string, projectId: string) {
  return projectsRepository.getProjectById(userId, projectId);
}

export function createProject(userId: string, input: CreateProjectInput) {
  return projectsRepository.createProject(userId, input);
}

export function updateProject(userId: string, projectId: string, input: UpdateProjectInput) {
  return projectsRepository.updateProject(userId, projectId, input);
}

export function deleteProject(userId: string, projectId: string) {
  return projectsRepository.deleteProject(userId, projectId);
}

export function listProjectCaptures(userId: string, projectId: string) {
  return projectsRepository.listProjectCaptures(userId, projectId);
}

export function linkCapture(userId: string, projectId: string, captureId: string) {
  return projectsRepository.linkCapture(userId, projectId, captureId);
}

export function unlinkCapture(userId: string, projectId: string, captureId: string) {
  return projectsRepository.unlinkCapture(userId, projectId, captureId);
}
