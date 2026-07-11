import type { ApiCapture } from "./api-types";

export function captureTitle(c: ApiCapture): string {
  if (c.type === "link") return c.link_title || c.url || "링크";
  if (c.type === "photo") return c.content?.slice(0, 40) || "사진 기록";
  if (c.type === "video") return c.content?.slice(0, 40) || "동영상 기록";
  return c.content?.slice(0, 40) || "빈 글감";
}

export function captureExcerpt(c: ApiCapture): string {
  if (c.type === "link") return c.content || c.url || "";
  return c.content ?? "";
}

export function captureDate(c: ApiCapture): string {
  return new Date(c.created_at).toLocaleString("ko-KR", {
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}
