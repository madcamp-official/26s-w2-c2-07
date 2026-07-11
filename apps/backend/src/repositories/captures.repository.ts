import { env } from "../config/env.js";
import { supabaseAdmin } from "../lib/supabase.js";
import type { CreateCaptureInput, UpdateCaptureInput } from "../schemas/capture.schema.js";
import { HttpError } from "../utils/http-error.js";

export interface LinkPreviewFields {
  linkTitle: string | null;
  linkDescription: string | null;
  linkImageUrl: string | null;
}

const CAPTURE_SELECT_WITH_TAGS =
  "*, capture_tags(tags(id, name, color)), capture_assets(storage_path)";

// capture_tags(tags(...)) 중첩 구조를 tags: [{id,name,color}] 형태로 펼쳐준다
// (Database 타입이 아직 생성 전이라 supabase 응답은 any로 취급된다 — 다른 repository 함수들과 동일)
function flattenTags(row: any) {
  const { capture_tags, ...rest } = row;
  return { ...rest, tags: (capture_tags ?? []).map((ct: any) => ct.tags) };
}

// capture_assets(storage_path)를 실제 브라우저에서 열람 가능한 서명된 URL로 바꿔준다.
// 버킷이 public이든 private이든 signed URL은 항상 동작하므로 버킷 설정을 몰라도 안전하다.
// 목록 조회에서는 경로들을 모아 한 번의 Storage API 호출로 배치 발급해 왕복을 줄인다.
async function attachImageUrls(rows: any[]): Promise<any[]> {
  const paths = rows.flatMap((row) =>
    (row.capture_assets ?? []).map((asset: { storage_path: string }) => asset.storage_path),
  );
  const urlByPath = new Map<string, string>();

  if (paths.length) {
    const { data, error } = await supabaseAdmin.storage
      .from(env.SUPABASE_STORAGE_BUCKET)
      .createSignedUrls(paths, 60 * 60); // 1시간

    if (error) throw HttpError.badRequest(error.message);
    for (const entry of data ?? []) {
      if (entry.signedUrl && !entry.error) urlByPath.set(entry.path ?? "", entry.signedUrl);
    }
  }

  return rows.map((row) => {
    const { capture_assets, ...rest } = row;
    const storagePath = capture_assets?.[0]?.storage_path;
    return { ...rest, image_url: storagePath ? (urlByPath.get(storagePath) ?? null) : null };
  });
}

export async function listCaptures(userId: string, type?: string) {
  let query = supabaseAdmin
    .from("captures")
    .select(CAPTURE_SELECT_WITH_TAGS)
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (type) query = query.eq("type", type);

  const { data, error } = await query;
  if (error) throw HttpError.badRequest(error.message);
  return attachImageUrls(data.map(flattenTags));
}

export async function getCaptureById(userId: string, captureId: string) {
  const { data, error } = await supabaseAdmin
    .from("captures")
    .select(CAPTURE_SELECT_WITH_TAGS)
    .eq("user_id", userId)
    .eq("id", captureId)
    .single();

  if (error) throw HttpError.notFound("Capture not found");
  const [capture] = await attachImageUrls([flattenTags(data)]);
  return capture;
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
