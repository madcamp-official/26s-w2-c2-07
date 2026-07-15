import { supabaseAdmin } from "../lib/supabase.js";
import { HttpError } from "../utils/http-error.js";
import {
  attachImageUrls,
  CAPTURE_SELECT_WITH_TAGS,
  flattenTags,
  getCaptureById,
} from "./captures.repository.js";

// shared_visibility -> visibility로 이름을 바꾸고, 본인 소유 여부를 알 수 있게 creator/is_mine을 채워 넣는다.
function toSharedCaptureShape(
  row: any,
  creator: { id: string; display_name: string | null; avatar_url: string | null },
  viewerId: string,
) {
  const { shared_visibility, ...rest } = row;
  return { ...rest, visibility: shared_visibility, creator, is_mine: row.user_id === viewerId };
}

async function attachCreators(rows: any[], viewerId: string): Promise<any[]> {
  const userIds = [...new Set(rows.map((row) => row.user_id as string))];
  if (!userIds.length) return [];

  const { data, error } = await supabaseAdmin
    .from("profiles")
    .select("id, display_name, avatar_url")
    .in("id", userIds);
  if (error) throw HttpError.badRequest(error.message);

  const profileById = new Map((data ?? []).map((profile: any) => [profile.id, profile]));
  return rows.map((row) =>
    toSharedCaptureShape(
      row,
      profileById.get(row.user_id) ?? { id: row.user_id, display_name: null, avatar_url: null },
      viewerId,
    ),
  );
}

function matchesQuery(capture: any, q: string) {
  const needle = q.toLowerCase();
  const haystack = [
    capture.content,
    capture.link_title,
    capture.link_description,
    capture.creator.display_name,
    ...capture.tags.map((tag: any) => tag.name),
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
  return haystack.includes(needle);
}

export async function listSharedCaptures(viewerId: string, q?: string) {
  const { data, error } = await supabaseAdmin
    .from("captures")
    .select(CAPTURE_SELECT_WITH_TAGS)
    .eq("is_shared", true)
    .order("created_at", { ascending: false });

  if (error) throw HttpError.badRequest(error.message);

  const withImages = await attachImageUrls(data.map(flattenTags));
  const withCreators = await attachCreators(withImages, viewerId);

  return q ? withCreators.filter((capture) => matchesQuery(capture, q)) : withCreators;
}

// save/report 대상 조회: 공유된 글감이기만 하면 되고(비공개로 전환된 것도 신고 이력 확인 등에 필요), user_id는 소유권 비교용으로 남겨둔다.
export async function getSharedCaptureById(captureId: string) {
  const { data, error } = await supabaseAdmin
    .from("captures")
    .select("*")
    .eq("id", captureId)
    .eq("is_shared", true)
    .single();

  if (error) throw HttpError.notFound("Shared capture not found");
  return data;
}

export async function saveSharedCapture(userId: string, captureId: string) {
  const original = await getSharedCaptureById(captureId);
  if (original.user_id === userId) throw HttpError.badRequest("본인 글감은 저장할 수 없습니다");

  const { error: saveError } = await supabaseAdmin
    .from("capture_saves")
    .insert({ capture_id: captureId, user_id: userId });
  if (saveError) {
    if (saveError.code === "23505") throw new HttpError(409, "이미 저장한 글감입니다");
    throw HttpError.badRequest(saveError.message);
  }

  const { error: countError } = await supabaseAdmin
    .from("captures")
    .update({ saved_count: original.saved_count + 1 })
    .eq("id", captureId);
  if (countError) throw HttpError.badRequest(countError.message);

  const { data: inserted, error: insertError } = await supabaseAdmin
    .from("captures")
    .insert({
      user_id: userId,
      type: original.type,
      content: original.content,
      url: original.url,
      link_title: original.link_title,
      link_description: original.link_description,
      link_image_url: original.link_image_url,
    })
    .select("id")
    .single();
  if (insertError) throw HttpError.badRequest(insertError.message);

  // 태그는 원 작성자 소유이므로 그대로 복사할 수 없다(태그 소유권이 어긋난다) — 이미지/영상 원본 파일만 그대로 이어준다.
  const { data: assets, error: assetsError } = await supabaseAdmin
    .from("capture_assets")
    .select("storage_path")
    .eq("capture_id", captureId);
  if (assetsError) throw HttpError.badRequest(assetsError.message);

  if (assets?.length) {
    const { error: copyAssetsError } = await supabaseAdmin
      .from("capture_assets")
      .insert(assets.map((asset: any) => ({ capture_id: inserted.id, storage_path: asset.storage_path })));
    if (copyAssetsError) throw HttpError.badRequest(copyAssetsError.message);
  }

  return getCaptureById(userId, inserted.id);
}

export async function reportSharedCapture(userId: string, captureId: string, reason: string) {
  const original = await getSharedCaptureById(captureId);
  if (original.user_id === userId) throw HttpError.badRequest("본인 글감은 신고할 수 없습니다");

  const { error: reportError } = await supabaseAdmin
    .from("capture_reports")
    .insert({ capture_id: captureId, user_id: userId, reason });
  if (reportError) {
    if (reportError.code === "23505") throw new HttpError(409, "이미 신고한 글감입니다");
    throw HttpError.badRequest(reportError.message);
  }

  const reportCount = original.report_count + 1;
  const updates: Record<string, unknown> = { report_count: reportCount };
  if (reportCount >= 3) updates.shared_visibility = "limited";

  const { error: updateError } = await supabaseAdmin.from("captures").update(updates).eq("id", captureId);
  if (updateError) throw HttpError.badRequest(updateError.message);
}
