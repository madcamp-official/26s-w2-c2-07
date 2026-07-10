import { supabaseAdmin } from "../lib/supabase.js";
import type { CreateTagInput } from "../schemas/tag.schema.js";
import { HttpError } from "../utils/http-error.js";
import { getCaptureById } from "./captures.repository.js";

export async function listTags(userId: string) {
  const { data, error } = await supabaseAdmin
    .from("tags")
    .select("*")
    .eq("user_id", userId)
    .order("name", { ascending: true });

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function createTag(userId: string, input: CreateTagInput) {
  const { data, error } = await supabaseAdmin
    .from("tags")
    .insert({ user_id: userId, name: input.name, color: input.color })
    .select("*")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function deleteTag(userId: string, tagId: string) {
  const { error } = await supabaseAdmin.from("tags").delete().eq("user_id", userId).eq("id", tagId);

  if (error) throw HttpError.badRequest(error.message);
}

export async function attachTag(userId: string, captureId: string, tagId: string) {
  await getCaptureById(userId, captureId); // ownership check

  const { error } = await supabaseAdmin.from("capture_tags").insert({ capture_id: captureId, tag_id: tagId });

  if (error) throw HttpError.badRequest(error.message);
}

export async function detachTag(userId: string, captureId: string, tagId: string) {
  await getCaptureById(userId, captureId); // ownership check

  const { error } = await supabaseAdmin
    .from("capture_tags")
    .delete()
    .eq("capture_id", captureId)
    .eq("tag_id", tagId);

  if (error) throw HttpError.badRequest(error.message);
}
