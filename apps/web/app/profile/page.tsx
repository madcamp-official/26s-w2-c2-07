"use client";

import {
  BookOpen,
  FileText,
  FolderKanban,
  Mail,
  Pencil,
  Trash2,
  X,
} from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { PageHead, Shell } from "../components";
import { profile as initialProfile } from "../data";

export default function ProfilePage() {
  const [profile, setProfile] = useState(initialProfile);
  const [draft, setDraft] = useState(initialProfile);
  const [editing, setEditing] = useState(false);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);

  const openEditor = () => {
    setDraft(profile);
    setEditing(true);
  };

  const saveProfile = (event: React.FormEvent) => {
    event.preventDefault();
    setProfile({
      ...draft,
      initial: draft.name.trim().slice(-1) || profile.initial,
    });
    setEditing(false);
  };

  return (
    <Shell>
      <div className="page narrow">
        <PageHead
          title="내 프로필"
          desc="Nook에서 쌓아온 나의 기록과 계정 정보를 확인하세요."
        />
        <section className="profile-card">
          <div className="big-avatar">{profile.initial}</div>
          <div>
            <h2>{profile.name}</h2>
            <p>
              <Mail /> {profile.email}
            </p>
            <small>{profile.bio}</small>
          </div>
          <button className="button ghost" onClick={openEditor}>
            <Pencil /> 프로필 수정
          </button>
        </section>

        <div className="stats">
          <div>
            <BookOpen />
            <b>{profile.captureCount}</b>
            <span>모은 글감</span>
          </div>
          <div>
            <FolderKanban />
            <b>{profile.projectCount}</b>
            <span>프로젝트</span>
          </div>
          <div>
            <FileText />
            <b>{profile.manuscriptCount}</b>
            <span>원고</span>
          </div>
        </div>

        <section className="settings-card">
          <h3>계정 정보</h3>
          <div>
            <span>이메일</span>
            <b>{profile.email}</b>
          </div>
          <div>
            <span>로그인 방식</span>
            <b>Google</b>
          </div>
          <div>
            <span>가입일</span>
            <b>{profile.joined}</b>
          </div>
          <div className="danger-zone">
            <div>
              <b>회원 탈퇴</b>
              <small>모든 글감과 프로젝트가 영구적으로 삭제됩니다.</small>
            </div>
            <button onClick={() => setDeleteConfirmOpen(true)}>
              <Trash2 /> 회원 탈퇴
            </button>
          </div>
        </section>

        {editing && (
          <div className="modal-backdrop">
            <form className="dialog" onSubmit={saveProfile}>
              <div className="dialog-heading">
                <div>
                  <h2>프로필 수정</h2>
                  <p>Nook에서 사용할 개인 정보를 변경하세요.</p>
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
                  value={draft.name}
                  onChange={(event) =>
                    setDraft({ ...draft, name: event.target.value })
                  }
                  required
                  maxLength={30}
                />
              </label>
              <label>
                이메일
                <input
                  value={draft.email}
                  type="email"
                  onChange={(event) =>
                    setDraft({ ...draft, email: event.target.value })
                  }
                  required
                />
              </label>
              <label>
                소개
                <textarea
                  value={draft.bio}
                  onChange={(event) =>
                    setDraft({ ...draft, bio: event.target.value })
                  }
                  maxLength={120}
                />
              </label>
              <div className="form-actions">
                <button
                  type="button"
                  className="button ghost"
                  onClick={() => setEditing(false)}
                >
                  취소
                </button>
                <button className="button primary">저장</button>
              </div>
            </form>
          </div>
        )}

        {deleteConfirmOpen && (
          <div className="modal-backdrop">
            <section className="dialog confirm-dialog">
              <Trash2 />
              <h2>정말 탈퇴할까요?</h2>
              <p>계정과 모든 기록이 영구 삭제되며 되돌릴 수 없습니다.</p>
              <div className="form-actions">
                <button
                  className="button ghost"
                  onClick={() => setDeleteConfirmOpen(false)}
                >
                  취소
                </button>
                <Link className="button danger-button" href="/login">
                  회원 탈퇴
                </Link>
              </div>
            </section>
          </div>
        )}
        {/* TODO(backend): profiles 수정, 이메일 변경 및 Supabase Auth 사용자 삭제 API와 연결해야 합니다. */}
      </div>
    </Shell>
  );
}
