import { supabaseAdmin } from "../lib/supabase.js";
import type { CreateDocumentInput, UpdateDocumentInput } from "../schemas/document.schema.js";
import { HttpError } from "../utils/http-error.js";
import { getProjectById } from "./projects.repository.js";

export async function listDocuments(userId: string, projectId: string) {
  const { data, error } = await supabaseAdmin
    .from("documents")
    .select("*")
    .eq("user_id", userId)
    .eq("project_id", projectId)
    .order("updated_at", { ascending: false });

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function getDocumentById(userId: string, projectId: string, documentId: string) {
  const { data, error } = await supabaseAdmin
    .from("documents")
    .select("*")
    .eq("user_id", userId)
    .eq("project_id", projectId)
    .eq("id", documentId)
    .single();

  if (error) throw HttpError.notFound("Document not found");
  return data;
}

export async function createDocument(userId: string, projectId: string, input: CreateDocumentInput) {
  await getProjectById(userId, projectId); // ownership check (insert has no row yet to filter by)

  const { data, error } = await supabaseAdmin
    .from("documents")
    .insert({ project_id: projectId, user_id: userId, title: input.title, content: input.content })
    .select("*")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function updateDocument(
  userId: string,
  projectId: string,
  documentId: string,
  input: UpdateDocumentInput,
) {
  const { data, error } = await supabaseAdmin
    .from("documents")
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq("user_id", userId)
    .eq("project_id", projectId)
    .eq("id", documentId)
    .select("*")
    .single();

  if (error) throw HttpError.notFound("Document not found");
  return data;
}

export async function deleteDocument(userId: string, projectId: string, documentId: string) {
  const { error } = await supabaseAdmin
    .from("documents")
    .delete()
    .eq("user_id", userId)
    .eq("project_id", projectId)
    .eq("id", documentId);

  if (error) throw HttpError.badRequest(error.message);
}
