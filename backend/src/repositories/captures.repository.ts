import { supabaseAdmin } from "../lib/supabase.js";
import type { CreateCaptureInput, UpdateCaptureInput } from "../schemas/capture.schema.js";
import { HttpError } from "../utils/http-error.js";

export interface LinkPreviewFields {
  linkTitle: string | null;
  linkDescription: string | null;
  linkImageUrl: string | null;
}

export async function listCaptures(userId: string, type?: string) {
  let query = supabaseAdmin
    .from("captures")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (type) query = query.eq("type", type);

  const { data, error } = await query;
  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function getCaptureById(userId: string, captureId: string) {
  const { data, error } = await supabaseAdmin
    .from("captures")
    .select("*")
    .eq("user_id", userId)
    .eq("id", captureId)
    .single();

  if (error) throw HttpError.notFound("Capture not found");
  return data;
}

export async function createCapture(userId: string, input: CreateCaptureInput, preview?: LinkPreviewFields) {
  const { data, error } = await supabaseAdmin
    .from("captures")
    .insert({
      user_id: userId,
      type: input.type,
      content: input.content,
      url: input.url,
      link_title: preview?.linkTitle,
      link_description: preview?.linkDescription,
      link_image_url: preview?.linkImageUrl,
    })
    .select("*")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function updateCapture(userId: string, captureId: string, input: UpdateCaptureInput) {
  const { data, error } = await supabaseAdmin
    .from("captures")
    .update({ content: input.content, url: input.url, updated_at: new Date().toISOString() })
    .eq("user_id", userId)
    .eq("id", captureId)
    .select("*")
    .single();

  if (error) throw HttpError.notFound("Capture not found");
  return data;
}

export async function deleteCapture(userId: string, captureId: string) {
  const { error } = await supabaseAdmin.from("captures").delete().eq("user_id", userId).eq("id", captureId);

  if (error) throw HttpError.badRequest(error.message);
}

export async function createCaptureAsset(userId: string, captureId: string, storagePath: string) {
  // ownership check: the capture must belong to this user
  await getCaptureById(userId, captureId);

  const { data, error } = await supabaseAdmin
    .from("capture_assets")
    .insert({ capture_id: captureId, storage_path: storagePath })
    .select("*")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}
