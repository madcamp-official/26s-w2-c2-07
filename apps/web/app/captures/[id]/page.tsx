"use client";

import { ArrowLeft, ExternalLink, Pencil, Trash2, X } from "lucide-react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { api } from "../../api";
import type { ApiCapture, ApiTag } from "../../api-types";
import {
  captureDate,
  captureExcerpt,
  captureHasTitle,
  captureTitle,
} from "../../capture-display";
import { Shell, TypeBadge } from "../../components";
import { CaptureMedia } from "../../components/capture-media";

export default function CaptureDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [capture, setCapture] = useState<ApiCapture | null>(null);
  const [tags, setTags] = useState<ApiTag[]>([]);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [notFound, setNotFound] = useState(false);
  const [draft, setDraft] = useState({
    content: "",
    url: "",
    tagIds: [] as string[],
    isShared: false,
  });

  const loadCapture = () => {
    api
      .get<ApiCapture>(`/captures/${id}`)
      .then((result) => {
        setCapture(result);
        setDraft({
          content: result.content ?? "",
          url: result.url ?? "",
          tagIds: result.tags.map((tag) => tag.id),
          isShared: result.is_shared ?? false,
        });
      })
      .catch(() => setNotFound(true));
  };

  useEffect(() => {
    loadCapture();
    api
      .get<ApiTag[]>("/tags")
      .then(setTags)
      .catch(() => setTags([]));
  }, [id]);

  const save = async (event: React.FormEvent) => {
    event.preventDefault();
    setSaving(true);
    try {
      await api.patch(`/captures/${id}`, {
        content: draft.content,
        url: capture?.type === "link" ? draft.url : undefined,
        tagIds: draft.tagIds,
        isShared: draft.isShared,
      });
      setEditing(false);
      loadCapture();
    } finally {
      setSaving(false);
    }
  };

  const remove = async () => {
    await api.delete(`/captures/${id}`);
    router.push("/captures");
  };

  const toggleTag = (tagId: string) =>
    setDraft((current) => ({
      ...current,
      tagIds: current.tagIds.includes(tagId)
        ? current.tagIds.filter((id) => id !== tagId)
        : [...current.tagIds, tagId],
    }));

  if (notFound)
    return (
      <Shell>
        <div className="page narrow">
          <p>글감을 찾을 수 없어요.</p>
        </div>
      </Shell>
    );
  if (!capture) return null;

  return (
    <Shell>
      <div className="page narrow">
        <Link href="/captures" className="back">
          <ArrowLeft /> 글감함으로
        </Link>
        <article className="detail-paper">
          <div className="detail-meta">
            <TypeBadge type={capture.type} />
            <time>{captureDate(capture)}</time>
          </div>
          {captureHasTitle(capture) && <h1>{captureTitle(capture)}</h1>}
          <div className="detail-tags">
            {capture.tags.map((tag) => (
              <span key={tag.id}>#{tag.name}</span>
            ))}
          </div>
          <CaptureMedia capture={capture} variant="detail" />
          <p className="detail-body">{captureExcerpt(capture)}</p>
          {capture.type === "link" && capture.url && (
            <a
              className="link-preview"
              href={capture.url}
              target="_blank"
              rel="noreferrer"
            >
              <div>
                <small>{capture.url}</small>
                <b>{capture.link_title ?? capture.url}</b>
                <p>{capture.link_description}</p>
              </div>
              <ExternalLink />
            </a>
          )}
          <div className="detail-actions">
            <button onClick={() => setEditing(true)}>
              <Pencil /> 수정
            </button>
            <button className="danger" onClick={remove}>
              <Trash2 /> 삭제
            </button>
          </div>
        </article>

        {editing && (
          <div className="modal-backdrop">
            <form className="dialog" onSubmit={save}>
              <div className="dialog-heading">
                <div>
                  <h2>글감 수정</h2>
                  <p>메모와 태그를 다시 정리할 수 있어요.</p>
                </div>
                <button
                  type="button"
                  className="icon-btn"
                  onClick={() => setEditing(false)}
                >
                  <X />
                </button>
              </div>
              {capture.type === "link" && (
                <label>
                  URL
                  <input
                    type="url"
                    value={draft.url}
                    onChange={(event) =>
                      setDraft({ ...draft, url: event.target.value })
                    }
                  />
                </label>
              )}
              <label>
                {capture.type === "text" ? "내용" : "메모"}
                <textarea
                  value={draft.content}
                  onChange={(event) =>
                    setDraft({ ...draft, content: event.target.value })
                  }
                />
              </label>
              <fieldset className="tag-selector">
                <legend>태그</legend>
                <div>
                  {tags.map((tag) => (
                    <button
                      type="button"
                      key={tag.id}
                      className={draft.tagIds.includes(tag.id) ? "active" : ""}
                      onClick={() => toggleTag(tag.id)}
                    >
                      #{tag.name}
                    </button>
                  ))}
                </div>
              </fieldset>
              <div className="share-toggle">
                <div>
                  <b>글감 서핑에 공유</b>
                  <small>
                    다른 사용자가 이 글감을 검색하고 자신의 글감함에 담을 수 있어요.
                  </small>
                </div>
                <button
                  type="button"
                  className={`toggle ${draft.isShared ? "on" : ""}`}
                  onClick={() =>
                    setDraft((current) => ({ ...current, isShared: !current.isShared }))
                  }
                  role="switch"
                  aria-checked={draft.isShared}
                >
                  <i />
                </button>
              </div>
              <div className="form-actions">
                <button
                  type="button"
                  className="button ghost"
                  onClick={() => setEditing(false)}
                >
                  취소
                </button>
                <button className="button primary" disabled={saving}>
                  {saving ? "저장 중…" : "수정 저장"}
                </button>
              </div>
            </form>
          </div>
        )}
      </div>
    </Shell>
  );
}
