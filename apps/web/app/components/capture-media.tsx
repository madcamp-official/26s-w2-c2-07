import { Film, Image as ImageIcon, Link2 } from "lucide-react";
import type { ApiCapture } from "../api-types";

interface CaptureMediaProps {
  capture: ApiCapture;
  variant: "detail" | "card";
}

function assetUrl(capture: ApiCapture) {
  return (
    capture.asset_url ??
    capture.assets?.[0]?.url ??
    capture.assets?.[0]?.signed_url ??
    capture.image_url
  );
}

export function CaptureMedia({ capture, variant }: CaptureMediaProps) {
  if (
    !(["photo", "video", "link"] as const).includes(
      capture.type as "photo" | "video" | "link",
    )
  )
    return null;

  const label =
    capture.type === "photo"
      ? "사진 글감"
      : capture.type === "video"
        ? "영상 글감"
        : "링크 썸네일";
  const PlaceholderIcon =
    capture.type === "photo"
      ? ImageIcon
      : capture.type === "video"
        ? Film
        : Link2;

  const className = `capture-media capture-media-${variant} media-${capture.type}`;

  if (capture.type === "video") {
    const videoSrc = assetUrl(capture);
    if (!videoSrc) {
      return (
        <div className={className}>
          <div className="capture-media-placeholder">
            <PlaceholderIcon />
            <span>{label}</span>
          </div>
        </div>
      );
    }
    return (
      <div className={className}>
        <video
          src={videoSrc}
          poster={capture.thumbnail_url ?? undefined}
          controls
          preload="metadata"
        />
      </div>
    );
  }

  const source =
    capture.type === "link" ? capture.link_image_url : assetUrl(capture);

  return (
    <div className={className}>
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
