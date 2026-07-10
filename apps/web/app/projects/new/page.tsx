"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { api } from "../../api";
import type { ApiProject } from "../../api-types";
import { PageHead, Shell } from "../../components";

export default function NewProject() {
  const r = useRouter();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [saving, setSaving] = useState(false);

  const save = async () => {
    if (!title.trim()) return;
    setSaving(true);
    try {
      const project = await api.post<ApiProject>("/projects", { title, description });
      r.push(`/projects/${project.id}`);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Shell>
      <div className="page narrow">
        <PageHead
          eyebrow="새로운 글의 시작"
          title="프로젝트 만들기"
          desc="주제와 방향은 나중에 언제든 바꿀 수 있어요."
        />
        <div className="capture-form">
          <label>
            프로젝트 이름{" "}
            <input
              value={title}
              onChange={(event) => setTitle(event.target.value)}
              placeholder="예: 여행의 온도"
            />
          </label>
          <label>
            프로젝트 소개{" "}
            <textarea
              value={description}
              onChange={(event) => setDescription(event.target.value)}
              placeholder="어떤 이야기를 쓰고 싶은지 짧게 적어보세요."
            />
          </label>
          <div className="form-actions">
            <button className="button ghost" onClick={() => r.back()}>
              취소
            </button>
            <button className="button primary" onClick={save} disabled={saving}>
              {saving ? "만드는 중…" : "프로젝트 만들기"}
            </button>
          </div>
        </div>
      </div>
    </Shell>
  );
}
