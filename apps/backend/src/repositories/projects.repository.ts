import { supabaseAdmin } from "../lib/supabase.js";
import * as capturesRepository from "./captures.repository.js";
import type {
  CreateProjectInput,
  UpdateProjectInput,
  UpdateProjectStatusInput,
} from "../schemas/project.schema.js";
import { HttpError } from "../utils/http-error.js";

export async function listProjects(userId: string) {
  const { data, error } = await supabaseAdmin
    .from("projects")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function getProjectById(userId: string, projectId: string) {
  const { data, error } = await supabaseAdmin
    .from("projects")
    .select("*")
    .eq("user_id", userId)
    .eq("id", projectId)
    .single();

  if (error) throw HttpError.notFound("Project not found");
  return data;
}

export async function createProject(userId: string, input: CreateProjectInput) {
  const { data, error } = await supabaseAdmin
    .from("projects")
    .insert({ user_id: userId, title: input.title, description: input.description })
    .select("*")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function updateProject(userId: string, projectId: string, input: UpdateProjectInput) {
  const { data, error } = await supabaseAdmin
    .from("projects")
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq("user_id", userId)
    .eq("id", projectId)
    .select("*")
    .single();

  if (error) throw HttpError.notFound("Project not found");
  return data;
}

export async function updateProjectStatus(
  userId: string,
  projectId: string,
  input: UpdateProjectStatusInput,
) {
  const { data, error } = await supabaseAdmin
    .from("projects")
    .update({ status: input.status, updated_at: new Date().toISOString() })
    .eq("user_id", userId)
    .eq("id", projectId)
    .select("*")
    .single();

  if (error) throw HttpError.notFound("Project not found");
  return data;
}

export async function deleteProject(userId: string, projectId: string) {
  const { error } = await supabaseAdmin.from("projects").delete().eq("user_id", userId).eq("id", projectId);

  if (error) throw HttpError.badRequest(error.message);
}

export async function listProjectCaptures(userId: string, projectId: string) {
  await getProjectById(userId, projectId); // ownership check

  const { data, error } = await supabaseAdmin
    .from("project_captures")
    .select("capture_id")
    .eq("project_id", projectId)
    .order("created_at", { ascending: false });

  if (error) throw HttpError.badRequest(error.message);

  // /captures, /captures/:id와 동일한 포맷(tags, image_url 포함)으로 통일해서 내려준다.
  return capturesRepository.getCapturesByIds(
    userId,
    data.map((row) => row.capture_id),
  );
}

export async function linkCapture(userId: string, projectId: string, captureId: string) {
  await getProjectById(userId, projectId); // ownership check

  const { error } = await supabaseAdmin
    .from("project_captures")
    .insert({ project_id: projectId, capture_id: captureId });

  if (error) throw HttpError.badRequest(error.message);
}

export async function unlinkCapture(userId: string, projectId: string, captureId: string) {
  await getProjectById(userId, projectId); // ownership check

  const { error } = await supabaseAdmin
    .from("project_captures")
    .delete()
    .eq("project_id", projectId)
    .eq("capture_id", captureId);

  if (error) throw HttpError.badRequest(error.message);
}
