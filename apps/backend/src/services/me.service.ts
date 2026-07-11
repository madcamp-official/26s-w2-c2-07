import { env } from "../config/env.js";
import { supabaseAdmin } from "../lib/supabase.js";
import * as capturesRepository from "../repositories/captures.repository.js";
import * as profilesRepository from "../repositories/profiles.repository.js";
import type { UpdateProfileInput } from "../schemas/profile.schema.js";
import { HttpError } from "../utils/http-error.js";

async function getAuthUser(userId: string) {
  const { data, error } = await supabaseAdmin.auth.admin.getUserById(userId);
  if (error || !data.user) throw HttpError.notFound("User not found");
  return data.user;
}

function toDto(profile: any, authUser: Awaited<ReturnType<typeof getAuthUser>>) {
  return {
    id: profile.id,
    email: authUser.email ?? null,
    display_name: profile.display_name,
    avatar_url: profile.avatar_url,
    provider: authUser.app_metadata?.provider ?? "email",
    created_at: profile.created_at,
    settings: {
      captureAlertsEnabled: profile.notify_enabled,
      darkEditorEnabled: profile.dark_editor,
    },
  };
}

export async function getMe(userId: string) {
  const [profile, authUser] = await Promise.all([
    profilesRepository.getProfile(userId),
    getAuthUser(userId),
  ]);
  return toDto(profile, authUser);
}

export async function updateMe(userId: string, input: UpdateProfileInput) {
  const [profile, authUser] = await Promise.all([
    profilesRepository.updateProfile(userId, input),
    getAuthUser(userId),
  ]);
  return toDto(profile, authUser);
}

// auth.users를 지우면 profiles/captures/tags/projects/documents 등은
// 이미 걸려있는 on delete cascade로 전부 함께 삭제된다. Storage의 실제 파일은
// cascade 대상이 아니므로, 계정이 사라지기 전에 경로를 모아서 따로 지워야 한다.
export async function deleteMe(userId: string) {
  const storagePaths = await capturesRepository.listAssetStoragePaths(userId);

  if (storagePaths.length) {
    const { error: storageError } = await supabaseAdmin.storage
      .from(env.SUPABASE_STORAGE_BUCKET)
      .remove(storagePaths);
    if (storageError) console.error("[me.deleteMe] failed to remove storage assets:", storageError.message);
  }

  const { error } = await supabaseAdmin.auth.admin.deleteUser(userId);
  if (error) throw HttpError.badRequest(error.message);
}
