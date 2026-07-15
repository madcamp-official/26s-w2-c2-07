"use client";

import { Image, Link2, Plus, Type, Upload, Video } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { api } from "../../api";
import type { ApiCapture, ApiTag } from "../../api-types";
import { PageHead, Shell } from "../../components";
import { supabase } from "../../supabase-client";
import { nextTagColor, type CaptureType } from "../../data";

const STORAGE_BUCKET = process.env.NEXT_PUBLIC_SUPABASE_STORAGE_BUCKET!;

const captureTypes = [
  { value: "text" as const, icon: Type, label: "조각글" },
  { value: "photo" as const, icon: Image, label: "사진" },
  { value: "video" as const, icon: Video, label: "동영상" },
  { value: "link" as const, icon: Link2, label: "링크" },
];

export default function NewCapturePage() {
  const router = useRouter();
  const [type, setType] = useState<CaptureType>("text");
  const [text, setText] = useState("");
  const [url, setUrl] = useState("");
  const [memo, setMemo] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [saving, setSaving] = useState(false);
  const [isShared, setIsShared] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [tags, setTags] = useState<ApiTag[]>([]);
  const [selectedTagIds, setSelectedTagIds] = useState<string[]>([]);
  const [newTagName, setNewTagName] = useState("");
  const [creatingTag, setCreatingTag] = useState(false);

  useEffect(() => {
    api
      .get<ApiTag[]>("/tags")
      .then(setTags)
      .catch(() => setTags([]));
  }, []);

  const toggleTag = (tagId: string) => {
    setSelectedTagIds((current) =>
      current.includes(tagId)
        ? current.filter((id) => id !== tagId)
        : [...current, tagId],
    );
  };

  const createTag = async (event: React.FormEvent) => {
    event.preventDefault();
    const name = newTagName.trim();
    if (!name) return;

    setCreatingTag(true);
    try {
      const tag = await api.post<ApiTag>("/tags", {
        name,
        color: nextTagColor(tags.length),
      });
      setTags((current) => [...current, tag]);
      setSelectedTagIds((current) => [...current, tag.id]);
      setNewTagName("");
    } finally {
      setCreatingTag(false);
    }
  };

  const save = async () => {
    setSaving(true);
    try {
      const capture = await api.post<ApiCapture>("/captures", {
        type,
        content: type === "text" ? text : memo || undefined,
        url: type === "link" ? url : undefined,
        tagIds: selectedTagIds,
        isShared,
      });

      if ((type === "photo" || type === "video") && file) {
        const { uploadUrl, storagePath, token } = await api.post<{
          uploadUrl: string;
          storagePath: string;
          token: string;
        }>(`/captures/${capture.id}/assets/upload-url`, {
          fileName: file.name,
          contentType: file.type,
        });
        void uploadUrl;
        if (storagePath !== "local-dummy") {
          await supabase.storage
            .from(STORAGE_BUCKET)
            .uploadToSignedUrl(storagePath, token, file);
          await api.post(`/captures/${capture.id}/assets/complete`, {
            storagePath,
          });
        }
      }

      router.push("/captures");
    } finally {
      setSaving(false);
    }
  };

  return (
    <Shell>
      <div className="page narrow">
        <PageHead
          eyebrow="새로운 영감"
          title="글감 남기기"
          desc="완벽하지 않아도 괜찮아요. 지금 마음에 남은 것을 적어보세요."
        />
        <div className="capture-form">
          <div className="choice">
            {captureTypes.map(({ value, icon: Icon, label }) => (
              <button
                key={value}
                className={type === value ? "active" : ""}
                onClick={() => setType(value)}
              >
                <Icon />
                {label}
              </button>
            ))}
          </div>
          {type === "text" && (
            <label>
              내용
              <textarea
                value={text}
                onChange={(event) => setText(event.target.value)}
                placeholder="떠오른 문장이나 생각을 자유롭게 적어보세요."
              />
            </label>
          )}
          {(type === "photo" || type === "video") && (
            <>
              <input
                ref={fileInputRef}
                type="file"
                accept={type === "photo" ? "image/*" : "video/*"}
                hidden
                onChange={(event) => setFile(event.target.files?.[0] ?? null)}
              />
              <button
                className="upload"
                onClick={() => fileInputRef.current?.click()}
              >
                <Upload />
                <b>
                  {file
                    ? file.name
                    : type === "photo"
                      ? "사진을 선택하세요"
                      : "동영상을 선택하세요"}
                </b>
                <span>
                  {type === "photo"
                    ? "JPG, PNG · 최대 10MB"
                    : "MP4, MOV · 최대 200MB"}
                </span>
              </button>
              <label>
                메모
                <textarea
                  value={memo}
                  onChange={(event) => setMemo(event.target.value)}
                  placeholder="이 장면/영상을 기억하고 싶은 이유를 적어보세요."
                />
              </label>
            </>
          )}
          {type === "link" && (
            <>
              <label>
                URL
                <input
                  type="url"
                  value={url}
                  onChange={(event) => setUrl(event.target.value)}
                  placeholder="https://"
                />
              </label>
              <label>
                메모
                <textarea
                  value={memo}
                  onChange={(event) => setMemo(event.target.value)}
                  placeholder="링크와 함께 기억할 내용을 적어보세요."
                />
              </label>
            </>
          )}
          <fieldset className="tag-selector">
            <legend>
              태그 <small>여러 개 선택할 수 있어요</small>
            </legend>
            <div>
              {tags.map((tag) => (
                <button
                  type="button"
                  key={tag.id}
                  className={selectedTagIds.includes(tag.id) ? "active" : ""}
                  onClick={() => toggleTag(tag.id)}
                >
                  #{tag.name}
                </button>
              ))}
            </div>
            <form className="inline-tag-create" onSubmit={createTag}>
              <input
                value={newTagName}
                onChange={(event) => setNewTagName(event.target.value)}
                placeholder="새 태그 만들기"
                maxLength={30}
              />
              <button
                type="submit"
                disabled={creatingTag || !newTagName.trim()}
              >
                <Plus /> {creatingTag ? "추가 중…" : "추가"}
              </button>
            </form>
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
              className={`toggle ${isShared ? "on" : ""}`}
              onClick={() => setIsShared((current) => !current)}
              role="switch"
              aria-checked={isShared}
            >
              <i />
            </button>
          </div>
          <div className="form-actions">
            <button className="button ghost" onClick={() => router.back()}>
              취소
            </button>
            <button className="button primary" onClick={save} disabled={saving}>
              {saving ? "저장 중…" : "글감 저장"}
            </button>
          </div>
        </div>
      </div>
    </Shell>
  );
}
