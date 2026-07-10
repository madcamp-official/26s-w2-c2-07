import { randomUUID } from "node:crypto";
import { env } from "../config/env.js";
import { supabaseAdmin } from "../lib/supabase.js";
import * as capturesRepository from "../repositories/captures.repository.js";
import { HttpError } from "../utils/http-error.js";

/**
 * Issues a signed upload URL for a capture's photo asset. The client
 * (mobile/web) uploads the file bytes directly to Storage using this URL —
 * the API server never sees the file contents.
 */
export async function createUploadUrl(userId: string, captureId: string, fileName: string) {
  await capturesRepository.getCaptureById(userId, captureId); // ownership check

  const ext = fileName.includes(".") ? fileName.split(".").pop() : "bin";
  const storagePath = `${userId}/${captureId}/${randomUUID()}.${ext}`;

  const { data, error } = await supabaseAdmin.storage
    .from(env.SUPABASE_STORAGE_BUCKET)
    .createSignedUploadUrl(storagePath);

  if (error) throw HttpError.badRequest(error.message);

  return { uploadUrl: data.signedUrl, storagePath, token: data.token };
}

/** Called by the client after the direct upload to Storage succeeds. */
export async function completeUpload(userId: string, captureId: string, storagePath: string) {
  return capturesRepository.createCaptureAsset(userId, captureId, storagePath);
}
