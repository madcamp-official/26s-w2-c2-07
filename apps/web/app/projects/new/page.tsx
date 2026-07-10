"use client";
import { useRouter } from "next/navigation";
import { PageHead, Shell } from "../../components";

export default function NewProject() {
  const r = useRouter();
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
            프로젝트 이름 <input placeholder="예: 여행의 온도" />
          </label>
          <label>
            프로젝트 소개{" "}
            <textarea placeholder="어떤 이야기를 쓰고 싶은지 짧게 적어보세요." />
          </label>
          <div className="form-actions">
            <button className="button ghost" onClick={() => r.back()}>
              취소
            </button>
            <button
              className="button primary"
              onClick={() => r.push("/projects")}
            >
              프로젝트 만들기
            </button>
          </div>
          {/* TODO(backend): Supabase project 생성 API와 연결해야 합니다. */}
        </div>
      </div>
    </Shell>
  );
}
