import { Film, Image as ImageIcon, Link2 } from "lucide-react";
import type { ApiCapture } from "../api-types";

interface CaptureMediaProps {
  capture: ApiCapture;
  variant: "detail" | "card";
}

function mediaUrl(capture: ApiCapture) {
  if (capture.type === "link") return capture.link_image_url;
  if (capture.type === "video") {
    return (
      capture.thumbnail_url ??
      capture.asset_url ??
      capture.assets?.[0]?.url ??
      capture.assets?.[0]?.signed_url
    );
  }
  return (
    capture.asset_url ??
    capture.assets?.[0]?.url ??
    capture.assets?.[0]?.signed_url
  );
}

export function CaptureMedia({ capture, variant }: CaptureMediaProps) {
  if (
    !(["photo", "video", "link"] as const).includes(
      capture.type as "photo" | "video" | "link",
    )
  )
    return null;

  const source = mediaUrl(capture);
  const label =
    capture.type === "photo"
      ? "사진 글감"
      : capture.type === "video"
        ? "영상 썸네일"
        : "링크 썸네일";
  const PlaceholderIcon =
    capture.type === "photo"
      ? ImageIcon
      : capture.type === "video"
        ? Film
        : Link2;

  return (
    <div
      className={`capture-media capture-media-${variant} media-${capture.type}`}
    >
      {source ? (
        <img src={source} alt={label} />
      ) : (
        <div className="capture-media-placeholder">
          <PlaceholderIcon />
          <span>{label}</span>
        </div>
      )}
    </div>
  );
}
