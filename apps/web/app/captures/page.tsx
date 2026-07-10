"use client";

import { Image, Link2, Plus, Search, Tag, Trash2, Type, X } from "lucide-react";
import Link from "next/link";
import { useMemo, useState } from "react";
import { AddButton, PageHead, Shell, TypeBadge } from "../components";
import {
  captures,
  tags as initialTags,
  type CaptureType,
  type Tag as TagData,
} from "../data";

const captureIcons = { text: Type, image: Image, link: Link2 };
const filters: Array<{ value: "all" | CaptureType; label: string }> = [
  { value: "all", label: "전체" },
  { value: "text", label: "조각글" },
  { value: "image", label: "사진" },
  { value: "link", label: "링크" },
];

export default function CapturesPage() {
  const [filter, setFilter] = useState<"all" | CaptureType>("all");
  const [selectedTag, setSelectedTag] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [tags, setTags] = useState<TagData[]>(initialTags);
  const [newTagName, setNewTagName] = useState("");

  const visibleCaptures = useMemo(
    () =>
      captures.filter((capture) => {
        const matchesType = filter === "all" || capture.type === filter;
        const matchesTag = !selectedTag || capture.tags.includes(selectedTag);
        const matchesQuery = `${capture.title} ${capture.excerpt}`.includes(
          query,
        );
        return matchesType && matchesTag && matchesQuery;
      }),
    [filter, query, selectedTag],
  );

  const addTag = () => {
    const name = newTagName.trim();
    if (!name || tags.some((tag) => tag.name === name)) return;
    setTags((current) => [
      ...current,
      { id: name, name, color: "#879287", count: 0 },
    ]);
    setNewTagName("");
  };

  const removeTag = (tag: TagData) => {
    setTags((current) => current.filter((item) => item.id !== tag.id));
    if (selectedTag === tag.name) setSelectedTag(null);
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
                      <b>{capture.title}</b>
                      <p>{capture.excerpt}</p>
                      <div className="capture-tags">
                        {capture.tags.map((tag) => (
                          <span key={tag}>#{tag}</span>
                        ))}
                      </div>
                    </div>
                    <TypeBadge type={capture.type} />
                    <time>{capture.date}</time>
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
                    <i style={{ background: tag.color }} />
                    <span>{tag.name}</span>
                    <small>{tag.count}</small>
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
            {/* TODO(backend): tags 및 capture_tags 생성·수정·삭제 API와 연결해야 합니다. */}
          </aside>
        </div>
      </div>
    </Shell>
  );
}
