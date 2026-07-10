"use client";

import { Image, Link2, Type, Upload } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { PageHead, Shell } from "../../components";
import { tags, type CaptureType } from "../../data";

const captureTypes = [
  { value: "text" as const, icon: Type, label: "조각글" },
  { value: "image" as const, icon: Image, label: "사진" },
  { value: "link" as const, icon: Link2, label: "링크" },
];

export default function NewCapturePage() {
  const router = useRouter();
  const [type, setType] = useState<CaptureType>("text");
  const [selectedTags, setSelectedTags] = useState<string[]>([]);

  const toggleTag = (tagName: string) => {
    setSelectedTags((current) =>
      current.includes(tagName)
        ? current.filter((name) => name !== tagName)
        : [...current, tagName],
    );
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
          <label>
            제목
            <input placeholder="나중에 알아보기 쉬운 제목" />
          </label>
          {type === "text" && (
            <label>
              내용
              <textarea placeholder="떠오른 문장이나 생각을 자유롭게 적어보세요." />
            </label>
          )}
          {type === "image" && (
            <>
              <button className="upload">
                <Upload />
                <b>사진을 끌어놓거나 선택하세요</b>
                <span>JPG, PNG · 최대 10MB</span>
              </button>
              <label>
                메모
                <textarea placeholder="이 장면을 기억하고 싶은 이유를 적어보세요." />
              </label>
            </>
          )}
          {type === "link" && (
            <>
              <label>
                URL
                <input type="url" placeholder="https://" />
              </label>
              <label>
                메모
                <textarea placeholder="링크와 함께 기억할 내용을 적어보세요." />
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
                  className={selectedTags.includes(tag.name) ? "active" : ""}
                  onClick={() => toggleTag(tag.name)}
                >
                  #{tag.name}
                </button>
              ))}
            </div>
          </fieldset>
          <div className="form-actions">
            <button className="button ghost" onClick={() => router.back()}>
              취소
            </button>
            <button
              className="button primary"
              onClick={() => router.push("/captures")}
            >
              글감 저장
            </button>
          </div>
          <p className="backend-note">현재 저장은 화면 시연용입니다.</p>
          {/* TODO(backend): capture, capture_tags 생성 및 이미지 업로드 API와 연결해야 합니다. */}
        </div>
      </div>
    </Shell>
  );
}
