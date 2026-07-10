import { supabaseAdmin } from "../lib/supabase.js";
import type { UpdateProfileInput } from "../schemas/profile.schema.js";
import { HttpError } from "../utils/http-error.js";

export async function getProfile(userId: string) {
  const { data, error } = await supabaseAdmin.from("profiles").select("*").eq("id", userId).single();

  if (error) throw HttpError.notFound("Profile not found");
  return data;
}

export async function updateProfile(userId: string, input: UpdateProfileInput) {
  const { data, error } = await supabaseAdmin
    .from("profiles")
    .update({ display_name: input.displayName, avatar_url: input.avatarUrl })
    .eq("id", userId)
    .select("*")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}
