"use client";

import {
  ArrowRight,
  FileText,
  MoreHorizontal,
  Plus,
  Sparkles,
  Trash2,
  X,
} from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import { captures, type Project, type ProjectStatus } from "../../data";

const statuses: ProjectStatus[] = ["초안", "진행 중", "완료", "보관됨"];

export function ProjectDetailClient({ project }: { project: Project }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [editing, setEditing] = useState(false);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [draft, setDraft] = useState(project);

  return (
    <>
      <div className="project-hero">
        <div>
          <span className="status">
            <i />
            {draft.status}
          </span>
          <h1>{draft.title}</h1>
          <p>{draft.description}</p>
          <small>
            마지막 수정 {draft.updated} · 글감 {draft.captures}개
          </small>
        </div>
        <div className="project-menu-wrap">
          <button
            className="icon-btn"
            onClick={() => setMenuOpen((open) => !open)}
            aria-label="프로젝트 메뉴"
          >
            <MoreHorizontal />
          </button>
          {menuOpen && (
            <div className="project-menu">
              <button
                onClick={() => {
                  setEditing(true);
                  setMenuOpen(false);
                }}
              >
                프로젝트 정보 수정
              </button>
              <button
                className="danger-menu-item"
                onClick={() => {
                  setDeleteConfirmOpen(true);
                  setMenuOpen(false);
                }}
              >
                <Trash2 /> 프로젝트 삭제
              </button>
            </div>
          )}
        </div>
      </div>

      <section className="section manuscript-section">
        <div className="section-title">
          <div>
            <FileText />
            <h2>원고</h2>
            <span className="number">{draft.manuscripts.length}</span>
          </div>
          <Link href={`/projects/${draft.id}/write/new`}>
            <Plus /> 새 원고
          </Link>
        </div>
        <div className="manuscripts">
          {draft.manuscripts.map((manuscript, index) => (
            <Link
              href={`/projects/${draft.id}/write/${manuscript.id}`}
              key={manuscript.id}
              className="manuscript"
            >
              <span className="manuscript-no">
                {String(index + 1).padStart(2, "0")}
              </span>
              <div>
                <h3>{manuscript.title}</h3>
                <p>{manuscript.excerpt}</p>
                <small>
                  {manuscript.updated} · {manuscript.words.toLocaleString()}자
                </small>
              </div>
              <ArrowRight />
            </Link>
          ))}
        </div>
      </section>

      <section className="section">
        <div className="section-title">
          <div>
            <Sparkles />
            <h2>연결된 글감</h2>
          </div>
          <button>
            글감 연결 <Plus />
          </button>
        </div>
        <div className="mini-cards">
          {captures.slice(0, 4).map((capture) => (
            <Link href={`/captures/${capture.id}`} key={capture.id}>
              <small>{capture.date}</small>
              <b>{capture.title}</b>
              <p>{capture.excerpt}</p>
            </Link>
          ))}
        </div>
      </section>

      {editing && (
        <div className="modal-backdrop" role="presentation">
          <form
            className="dialog"
            onSubmit={(event) => {
              event.preventDefault();
              setEditing(false);
            }}
          >
            <div className="dialog-heading">
              <div>
                <h2>프로젝트 정보 수정</h2>
                <p>이름, 설명과 진행 상태를 변경할 수 있어요.</p>
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
              프로젝트 이름
              <input
                value={draft.title}
                onChange={(event) =>
                  setDraft({ ...draft, title: event.target.value })
                }
              />
            </label>
            <label>
              설명
              <textarea
                value={draft.description}
                onChange={(event) =>
                  setDraft({ ...draft, description: event.target.value })
                }
              />
            </label>
            <label>
              진행 상태
              <select
                value={draft.status}
                onChange={(event) =>
                  setDraft({
                    ...draft,
                    status: event.target.value as ProjectStatus,
                  })
                }
              >
                {statuses.map((status) => (
                  <option key={status}>{status}</option>
                ))}
              </select>
            </label>
            <div className="form-actions">
              <button
                type="button"
                className="button ghost"
                onClick={() => setEditing(false)}
              >
                취소
              </button>
              <button className="button primary">변경 저장</button>
            </div>
          </form>
        </div>
      )}

      {deleteConfirmOpen && (
        <div className="modal-backdrop">
          <section className="dialog confirm-dialog">
            <Trash2 />
            <h2>프로젝트를 삭제할까요?</h2>
            <p>프로젝트와 연결된 원고가 함께 삭제되며 되돌릴 수 없습니다.</p>
            <div className="form-actions">
              <button
                className="button ghost"
                onClick={() => setDeleteConfirmOpen(false)}
              >
                취소
              </button>
              <Link className="button danger-button" href="/projects">
                삭제
              </Link>
            </div>
          </section>
        </div>
      )}
      {/* TODO(backend): project 수정·삭제 및 project_captures 연결 API와 연결해야 합니다. */}
    </>
  );
}
