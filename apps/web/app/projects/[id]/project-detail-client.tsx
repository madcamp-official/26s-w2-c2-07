"use client";

import {
  FileText,
  MoreHorizontal,
  Plus,
  Sparkles,
  Trash2,
  X,
} from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { api } from "../../api";
import type { ApiCapture, ApiDocument, ApiProject, ApiProjectCaptureLink } from "../../api-types";
import { captureExcerpt, captureTitle } from "../../capture-display";
import { StatusBadge, projectStatusLabels } from "../../components";
import type { ProjectStatus } from "../../data";

const statuses: ProjectStatus[] = ["active", "done", "archived"];

export function ProjectDetailClient({ projectId }: { projectId: string }) {
  const router = useRouter();
  const [project, setProject] = useState<ApiProject | null>(null);
  const [documents, setDocuments] = useState<ApiDocument[]>([]);
  const [links, setLinks] = useState<ApiProjectCaptureLink[]>([]);
  const [allCaptures, setAllCaptures] = useState<ApiCapture[]>([]);
  const [menuOpen, setMenuOpen] = useState(false);
  const [editing, setEditing] = useState(false);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [linking, setLinking] = useState(false);
  const [draft, setDraft] = useState({ title: "", description: "", status: "active" as ProjectStatus });

  const load = () => {
    api.get<ApiProject>(`/projects/${projectId}`).then((p) => {
      setProject(p);
      setDraft({ title: p.title, description: p.description ?? "", status: p.status });
    });
    api.get<ApiDocument[]>(`/projects/${projectId}/documents`).then(setDocuments);
    api.get<ApiProjectCaptureLink[]>(`/projects/${projectId}/captures`).then(setLinks);
  };

  useEffect(load, [projectId]);

  const saveEdit = async (event: React.FormEvent) => {
    event.preventDefault();
    await api.patch(`/projects/${projectId}`, draft);
    setEditing(false);
    load();
  };

  const removeProject = async () => {
    await api.delete(`/projects/${projectId}`);
    router.push("/projects");
  };

  const createDocument = async () => {
    const doc = await api.post<ApiDocument>(`/projects/${projectId}/documents`, {});
    router.push(`/projects/${projectId}/write/${doc.id}`);
  };

  const openLinkPicker = () => {
    setLinking((current) => !current);
    if (!linking) api.get<ApiCapture[]>("/captures").then(setAllCaptures);
  };

  const linkCapture = async (captureId: string) => {
    await api.post(`/projects/${projectId}/captures`, { captureId });
    setLinking(false);
    load();
  };

  const unlinkCapture = async (captureId: string) => {
    await api.delete(`/projects/${projectId}/captures/${captureId}`);
    load();
  };

  if (!project) return null;

  const linkedIds = new Set(links.map((l) => l.capture_id));
  const unlinkedCaptures = allCaptures.filter((c) => !linkedIds.has(c.id));

  return (
    <>
      <div className="project-hero">
        <div>
          <StatusBadge status={project.status} />
          <h1>{project.title}</h1>
          <p>{project.description}</p>
          <small>
            마지막 수정 {new Date(project.updated_at).toLocaleDateString("ko-KR")} · 글감{" "}
            {links.length}개
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
            <span className="number">{documents.length}</span>
          </div>
          <button onClick={createDocument}>
            <Plus /> 새 원고
          </button>
        </div>
        <div className="manuscripts">
          {documents.map((doc, index) => (
            <Link
              href={`/projects/${projectId}/write/${doc.id}`}
              key={doc.id}
              className="manuscript"
            >
              <span className="manuscript-no">
                {String(index + 1).padStart(2, "0")}
              </span>
              <div>
                <h3>{doc.title}</h3>
                <p>{doc.content.slice(0, 80)}</p>
                <small>{new Date(doc.updated_at).toLocaleDateString("ko-KR")}</small>
              </div>
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
          <button onClick={openLinkPicker}>
            글감 연결 <Plus />
          </button>
        </div>
        {linking && (
          <div className="mini-cards">
            {unlinkedCaptures.map((capture) => (
              <button key={capture.id} onClick={() => linkCapture(capture.id)}>
                <small>{captureTitle(capture)}</small>
                <p>{captureExcerpt(capture)}</p>
              </button>
            ))}
            {!unlinkedCaptures.length && <p>연결할 수 있는 글감이 없어요.</p>}
          </div>
        )}
        <div className="mini-cards">
          {links.map(({ capture_id, captures: capture }) => (
            <div key={capture_id} style={{ position: "relative" }}>
              <Link href={`/captures/${capture_id}`}>
                <small>{new Date(capture.created_at).toLocaleDateString("ko-KR")}</small>
                <b>{captureTitle(capture)}</b>
                <p>{captureExcerpt(capture)}</p>
              </Link>
              <button aria-label="연결 해제" onClick={() => unlinkCapture(capture_id)}>
                <X />
              </button>
            </div>
          ))}
        </div>
      </section>

      {editing && (
        <div className="modal-backdrop" role="presentation">
          <form className="dialog" onSubmit={saveEdit}>
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
                onChange={(event) => setDraft({ ...draft, title: event.target.value })}
              />
            </label>
            <label>
              설명
              <textarea
                value={draft.description}
                onChange={(event) => setDraft({ ...draft, description: event.target.value })}
              />
            </label>
            <label>
              진행 상태
              <select
                value={draft.status}
                onChange={(event) =>
                  setDraft({ ...draft, status: event.target.value as ProjectStatus })
                }
              >
                {statuses.map((status) => (
                  <option key={status} value={status}>
                    {projectStatusLabels[status]}
                  </option>
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
              <button className="button danger-button" onClick={removeProject}>
                삭제
              </button>
            </div>
          </section>
        </div>
      )}
    </>
  );
}
