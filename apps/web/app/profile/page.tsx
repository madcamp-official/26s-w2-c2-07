"use client";

import { Mail, Pencil, Trash2, X } from "lucide-react";
import { useEffect, useState } from "react";
import { api } from "../api";
import type { ApiProfile } from "../api-types";
import { PageHead, Shell } from "../components";
import { supabase } from "../supabase-client";
import { useRouter } from "next/navigation";

export default function ProfilePage() {
  const router = useRouter();
  const [profile, setProfile] = useState<ApiProfile | null>(null);
  const [draft, setDraft] = useState({ displayName: "", avatarUrl: "" });
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);

  const load = () =>
    api.get<ApiProfile>("/me").then((result) => {
      setProfile(result);
      setDraft({
        displayName: result.display_name ?? "",
        avatarUrl: result.avatar_url ?? "",
      });
    });

  useEffect(() => {
    void load();
  }, []);

  const save = async (event: React.FormEvent) => {
    event.preventDefault();
    setSaving(true);
    try {
      await api.patch("/me", draft);
      await load();
      setEditing(false);
    } finally {
      setSaving(false);
    }
  };

  const deleteAccount = async () => {
    await api.delete("/me");
    if (api.isUsingMockData()) {
      alert("API 연결이 필요합니다");
      return;
    }
    await supabase.auth.signOut();
    router.push("/login");
  };

  if (!profile) return null;
  const initial = profile.display_name?.trim().slice(-1) || "?";

  return (
    <Shell>
      <div className="page narrow">
        <PageHead
          title="내 프로필"
          desc="현재 로그인한 계정과 Nook 프로필 정보를 관리하세요."
        />
        <section className="profile-card">
          <div className="big-avatar">{initial}</div>
          <div>
            <h2>{profile.display_name ?? "이름 없음"}</h2>
            <p>
              <Mail /> {profile.email}
            </p>
            <small>{profile.provider} 계정으로 로그인됨</small>
          </div>
          <button className="button ghost" onClick={() => setEditing(true)}>
            <Pencil /> 프로필 수정
          </button>
        </section>
        <section className="settings-card">
          <h3>계정 정보</h3>
          <div>
            <span>이메일</span>
            <b>{profile.email}</b>
          </div>
          <div>
            <span>로그인 방식</span>
            <b>{profile.provider}</b>
          </div>
          <div className="danger-zone">
            <div>
              <b>회원 탈퇴</b>
              <small>계정 삭제 API가 준비된 뒤 사용할 수 있습니다.</small>
            </div>
            <button onClick={deleteAccount}>
              <Trash2 /> 회원 탈퇴
            </button>
          </div>
        </section>
        {editing && (
          <div className="modal-backdrop">
            <form className="dialog" onSubmit={save}>
              <div className="dialog-heading">
                <div>
                  <h2>프로필 수정</h2>
                  <p>로그인 계정에 연결된 공개 정보를 변경하세요.</p>
                </div>
                <button
                  type="button"
                  className="icon-btn"
                  onClick={() => setEditing(false)}
                >
                  <X />
                </button>
              </div>
              <label>
                이름
                <input
                  value={draft.displayName}
                  onChange={(event) =>
                    setDraft({ ...draft, displayName: event.target.value })
                  }
                  required
                  maxLength={100}
                />
              </label>
              <label>
                프로필 이미지 URL
                <input
                  type="url"
                  value={draft.avatarUrl}
                  onChange={(event) =>
                    setDraft({ ...draft, avatarUrl: event.target.value })
                  }
                />
              </label>
              <label>
                이메일
                <input value={profile.email} readOnly disabled />
                <small>이메일은 Google 계정에서 관리됩니다.</small>
              </label>
              <div className="form-actions">
                <button
                  type="button"
                  className="button ghost"
                  onClick={() => setEditing(false)}
                >
                  취소
                </button>
                <button className="button primary" disabled={saving}>
                  {saving ? "저장 중…" : "저장"}
                </button>
              </div>
            </form>
          </div>
        )}
      </div>
    </Shell>
  );
}
