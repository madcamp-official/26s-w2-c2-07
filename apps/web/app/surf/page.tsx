"use client";

import { ExternalLink, Flag, Image, Link2, Search, Type, Video } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { api } from "../api";
import type { ApiSharedCapture } from "../api-types";
import { captureExcerpt, captureTitle } from "../capture-display";
import { PageHead, Shell, TypeBadge } from "../components";
import { CaptureMedia } from "../components/capture-media";

const icons = { text: Type, photo: Image, link: Link2, video: Video };

export default function SurfPage() {
  const [query, setQuery] = useState("");
  const [captures, setCaptures] = useState<ApiSharedCapture[]>([]);
  const [selected, setSelected] = useState<ApiSharedCapture | null>(null);

  useEffect(() => {
    // TODO: 더미 데이터 삭제
    // 백엔드 /shared-captures API가 없으면 mock-api가 공유 글감 더미 데이터를 반환합니다.
    api
      .get<ApiSharedCapture[]>(
        `/shared-captures?q=${encodeURIComponent(query)}`,
      )
      .then(setCaptures)
      .catch(() => setCaptures([]));
  }, [query]);

  const visibleCaptures = useMemo(
    () => captures.filter((capture) => capture.visibility === "visible"),
    [captures],
  );

  const saveCapture = async (capture: ApiSharedCapture) => {
    await api.post(`/shared-captures/${capture.id}/save`);
    if (api.isUsingMockData()) alert("API 연결이 필요합니다");
  };

  const reportCapture = async (capture: ApiSharedCapture) => {
    await api.post(`/shared-captures/${capture.id}/report`, {
      reason: "inappropriate",
    });
    if (api.isUsingMockData()) alert("API 연결이 필요합니다");
  };

  return (
    <Shell>
      <div className="page surf-page">
        <PageHead
          title="글감 서핑"
          desc="다른 작가들이 공유한 장면과 문장을 검색하고 내 글감함에 담아보세요."
        />

        <label className="search surf-search">
          <Search />
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="공유 글감 검색"
          />
        </label>

        <div className="surf-grid">
          {visibleCaptures.map((capture) => {
            const Icon = icons[capture.type];
            return (
              <button
                className="surf-card"
                key={capture.id}
                onClick={() => setSelected(capture)}
              >
                <CaptureMedia capture={capture} variant="card" />
                <span className="capture-icon">
                  <Icon />
                </span>
                <TypeBadge type={capture.type} />
                <h3>{captureTitle(capture)}</h3>
                <p>{captureExcerpt(capture)}</p>
                <small>
                  {capture.creator.display_name ?? "익명"} · 저장{" "}
                  {capture.saved_count}
                </small>
              </button>
            );
          })}
        </div>
      </div>

      {selected && (
        <div className="modal-backdrop" onClick={() => setSelected(null)}>
          <section
            className="dialog surf-detail-modal"
            onClick={(event) => event.stopPropagation()}
          >
            <CaptureMedia capture={selected} variant="detail" />
            <TypeBadge type={selected.type} />
            <h2>{captureTitle(selected)}</h2>
            <p>{captureExcerpt(selected)}</p>
            {selected.type === "link" && selected.url && (
              <a
                className="link-preview"
                href={selected.url}
                target="_blank"
                rel="noreferrer"
              >
                <div>
                  <small>{selected.url}</small>
                  <b>{selected.link_title ?? selected.url}</b>
                  <p>{selected.link_description}</p>
                </div>
                <ExternalLink />
              </a>
            )}
            <div className="tag-row">
              {selected.tags.map((tag) => (
                <span key={tag.id}>#{tag.name}</span>
              ))}
            </div>
            <small>
              공유한 사람: {selected.creator.display_name ?? "익명"} · 저장{" "}
              {selected.saved_count}
            </small>
            {selected.is_mine ? (
              <p className="surf-own-note">내가 공유한 글감</p>
            ) : (
              <div className="modal-actions">
                <button className="button ghost" onClick={() => reportCapture(selected)}>
                  <Flag /> 신고
                </button>
                <button className="button primary" onClick={() => saveCapture(selected)}>
                  내 글감함에 추가
                </button>
              </div>
            )}
          </section>
        </div>
      )}
    </Shell>
  );
}
