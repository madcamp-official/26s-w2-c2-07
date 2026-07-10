"use client";

import { Image, Link2, Plus, Search, Tag, Trash2, Type, Video, X } from "lucide-react";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { api } from "../api";
import type { ApiCapture, ApiTag } from "../api-types";
import { captureExcerpt, captureTitle, captureDate } from "../capture-display";
import { AddButton, PageHead, Shell, TypeBadge } from "../components";
import { type CaptureType } from "../data";

const captureIcons = { text: Type, photo: Image, link: Link2, video: Video };
const filters: Array<{ value: "all" | CaptureType; label: string }> = [
  { value: "all", label: "전체" },
  { value: "text", label: "조각글" },
  { value: "photo", label: "사진" },
  { value: "video", label: "동영상" },
  { value: "link", label: "링크" },
];

export default function CapturesPage() {
  const [filter, setFilter] = useState<"all" | CaptureType>("all");
  const [selectedTag, setSelectedTag] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [captures, setCaptures] = useState<ApiCapture[]>([]);
  const [tags, setTags] = useState<ApiTag[]>([]);
  const [newTagName, setNewTagName] = useState("");

  const loadCaptures = () => {
    api.get<ApiCapture[]>("/captures").then(setCaptures).catch(() => setCaptures([]));
  };
  const loadTags = () => {
    api.get<ApiTag[]>("/tags").then(setTags).catch(() => setTags([]));
  };

  useEffect(() => {
    loadCaptures();
    loadTags();
  }, []);

  const visibleCaptures = useMemo(
    () =>
      captures.filter((capture) => {
        const matchesType = filter === "all" || capture.type === filter;
        const matchesTag =
          !selectedTag || capture.tags.some((tag) => tag.name === selectedTag);
        const matchesQuery = `${captureTitle(capture)} ${captureExcerpt(capture)}`.includes(
          query,
        );
        return matchesType && matchesTag && matchesQuery;
      }),
    [captures, filter, query, selectedTag],
  );

  const addTag = async () => {
    const name = newTagName.trim();
    if (!name || tags.some((tag) => tag.name === name)) return;
    setNewTagName("");
    await api.post("/tags", { name, color: "#879287" });
    loadTags();
  };

  const removeTag = async (tag: ApiTag) => {
    if (selectedTag === tag.name) setSelectedTag(null);
    await api.delete(`/tags/${tag.id}`);
    loadTags();
  };

  return (
    <Shell>
      <div className="page captures-page">
        <PageHead
          title="글감함"
          desc="마음에 걸린 문장과 장면을 한곳에 모아두세요."
          action={<AddButton />}
        />
        <div className="capture-library-layout">
          <main>
            <div className="tools">
              <div className="filters">
                {filters.map(({ value, label }) => (
                  <button
                    key={value}
                    className={filter === value ? "active" : ""}
                    onClick={() => setFilter(value)}
                  >
                    {label}
                  </button>
                ))}
              </div>
              <label className="search">
                <Search />
                <input
                  value={query}
                  onChange={(event) => setQuery(event.target.value)}
                  placeholder="글감 검색"
                />
              </label>
            </div>
            {selectedTag && (
              <button
                className="selected-tag"
                onClick={() => setSelectedTag(null)}
              >
                #{selectedTag} <X />
              </button>
            )}
            <div className="capture-list roomy">
              {visibleCaptures.map((capture) => {
                const Icon = captureIcons[capture.type];
                return (
                  <Link
                    href={`/captures/${capture.id}`}
                    className="capture-row"
                    key={capture.id}
                  >
                    <span className={`capture-icon visual-${capture.type}`}>
                      <Icon />
                    </span>
                    <div>
                      <b>{captureTitle(capture)}</b>
                      <p>{captureExcerpt(capture)}</p>
                      <div className="capture-tags">
                        {capture.tags.map((tag) => (
                          <span key={tag.id}>#{tag.name}</span>
                        ))}
                      </div>
                    </div>
                    <TypeBadge type={capture.type} />
                    <time>{captureDate(capture)}</time>
                  </Link>
                );
              })}
              {!visibleCaptures.length && (
                <div className="empty">
                  찾는 글감이 없어요.
                  <small>다른 검색어나 유형, 태그를 선택해보세요.</small>
                </div>
              )}
            </div>
          </main>
          <aside className="tag-manager">
            <div className="tag-manager-heading">
              <div>
                <Tag />
                <h2>태그 관리</h2>
              </div>
              <small>{tags.length}개</small>
            </div>
            <p>글감을 주제별로 묶고 빠르게 찾아보세요.</p>
            <form
              className="tag-create"
              onSubmit={(event) => {
                event.preventDefault();
                addTag();
              }}
            >
              <input
                value={newTagName}
                onChange={(event) => setNewTagName(event.target.value)}
                placeholder="새 태그 이름"
                maxLength={16}
              />
              <button aria-label="태그 추가">
                <Plus />
              </button>
            </form>
            <div className="tag-list">
              {tags.map((tag) => (
                <div
                  key={tag.id}
                  className={selectedTag === tag.name ? "active" : ""}
                >
                  <button
                    className="tag-filter-button"
                    onClick={() => setSelectedTag(tag.name)}
                  >
                    <i style={{ background: tag.color ?? undefined }} />
                    <span>{tag.name}</span>
                    <small>
                      {captures.filter((c) => c.tags.some((t) => t.id === tag.id)).length}
                    </small>
                  </button>
                  <button
                    aria-label={`${tag.name} 삭제`}
                    onClick={() => removeTag(tag)}
                  >
                    <Trash2 />
                  </button>
                </div>
              ))}
            </div>
          </aside>
        </div>
      </div>
    </Shell>
  );
}
