import { supabaseAdmin } from "../lib/supabase.js";
import type { UpdateProfileInput } from "../schemas/profile.schema.js";
import type { UpdateSettingsInput } from "../schemas/settings.schema.js";
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

export async function getSettings(userId: string) {
  const { data, error } = await supabaseAdmin
    .from("profiles")
    .select("notify_enabled, dark_editor")
    .eq("id", userId)
    .single();

  if (error) throw HttpError.notFound("Profile not found");
  return data;
}

export async function updateSettings(userId: string, input: UpdateSettingsInput) {
  const { data, error } = await supabaseAdmin
    .from("profiles")
    .update({ notify_enabled: input.notifyEnabled, dark_editor: input.darkEditor })
    .eq("id", userId)
    .select("notify_enabled, dark_editor")
    .single();

  if (error) throw HttpError.badRequest(error.message);
  return data;
}
