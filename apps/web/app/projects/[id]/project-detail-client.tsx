"use client";

import {
  Check,
  Download,
  FileText,
  MoreHorizontal,
  Plus,
  Search,
  Sparkles,
  Trash2,
  X,
} from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { api } from "../../api";
import type {
  ApiCapture,
  ApiDocument,
  ApiProject,
  ApiProjectCaptureLink,
} from "../../api-types";
import { captureExcerpt, captureTitle } from "../../capture-display";
import { StatusBadge } from "../../components";

type ExportFormat = "pdf" | "docx" | "txt";

function normalizeLinkedCaptures(
  payload: ApiCapture[] | ApiProjectCaptureLink[],
): ApiCapture[] {
  return payload.map((item) => ("captures" in item ? item.captures : item));
}

export function ProjectDetailClient({ projectId }: { projectId: string }) {
  const router = useRouter();
  const [project, setProject] = useState<ApiProject | null>(null);
  const [documents, setDocuments] = useState<ApiDocument[]>([]);
  const [linkedCaptures, setLinkedCaptures] = useState<ApiCapture[]>([]);
  const [allCaptures, setAllCaptures] = useState<ApiCapture[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [query, setQuery] = useState("");
  const [menuOpen, setMenuOpen] = useState(false);
  const [editing, setEditing] = useState(false);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [linking, setLinking] = useState(false);
  const [creatingDocument, setCreatingDocument] = useState(false);
  const [changingStatus, setChangingStatus] = useState(false);
  const [draft, setDraft] = useState({ title: "", description: "" });

  const load = async () => {
    const [projectResult, documentResult, captureResult] = await Promise.all([
      api.get<ApiProject>(`/projects/${projectId}`),
      api.get<ApiDocument[]>(`/projects/${projectId}/documents`),
      api.get<ApiCapture[] | ApiProjectCaptureLink[]>(
        `/projects/${projectId}/captures`,
      ),
    ]);
    setProject(projectResult);
    setDraft({
      title: projectResult.title,
      description: projectResult.description ?? "",
    });
    setDocuments(documentResult);
    setLinkedCaptures(normalizeLinkedCaptures(captureResult));
  };

  useEffect(() => {
    void load();
  }, [projectId]);

  const saveEdit = async (event: React.FormEvent) => {
    event.preventDefault();
    await api.patch(`/projects/${projectId}`, draft);
    setEditing(false);
    await load();
  };

  const changeStatus = async () => {
    if (!project || changingStatus) return;
    setChangingStatus(true);
    try {
      await api.patch(`/projects/${projectId}/status`, {
        status: project.status === "active" ? "done" : "active",
      });
      await load();
    } finally {
      setChangingStatus(false);
    }
  };

  const createDocument = async () => {
    if (creatingDocument) return;
    setCreatingDocument(true);
    try {
      const document = await api.post<ApiDocument>(
        `/projects/${projectId}/documents`,
        {
          clientRequestId: crypto.randomUUID(),
          title: "제목 없음",
          content: "",
        },
      );
      router.push(`/projects/${projectId}/write/${document.id}`);
    } finally {
      setCreatingDocument(false);
    }
  };

  const openLinkPicker = async () => {
    const captures = await api.get<ApiCapture[]>(
      `/captures?projectId=${projectId}`,
    );
    setAllCaptures(captures);
    setSelectedIds(
      new Set(
        captures
          .filter(
            (capture) =>
              capture.isLinked ||
              linkedCaptures.some((linked) => linked.id === capture.id),
          )
          .map((capture) => capture.id),
      ),
    );
    setQuery("");
    setLinking(true);
  };

  const saveCaptureLinks = async () => {
    const originallyLinked = new Set(
      linkedCaptures.map((capture) => capture.id),
    );
    const toAdd = [...selectedIds].filter((id) => !originallyLinked.has(id));
    const toRemove = [...originallyLinked].filter((id) => !selectedIds.has(id));
    await Promise.all([
      ...toAdd.map((captureId) =>
        api.post(`/projects/${projectId}/captures`, { captureId }),
      ),
      ...toRemove.map((captureId) =>
        api.delete(`/projects/${projectId}/captures/${captureId}`),
      ),
    ]);
    setLinking(false);
    await load();
  };

  const exportProject = async (format: ExportFormat) => {
    const blob = await api.download(
      `/projects/${projectId}/export?format=${format}`,
    );
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = `${project?.title ?? "nook-project"}.${format}`;
    anchor.click();
    URL.revokeObjectURL(url);
  };

  const visibleCaptures = useMemo(
    () =>
      allCaptures.filter((capture) =>
        `${captureTitle(capture)} ${captureExcerpt(capture)}`
          .toLowerCase()
          .includes(query.toLowerCase()),
      ),
    [allCaptures, query],
  );
  if (!project) return null;

  return (
    <>
      <div className="project-hero">
        <div>
          <StatusBadge status={project.status} />
          <h1>{project.title}</h1>
          <p>{project.description}</p>
          <small>
            마지막 수정{" "}
            {new Date(project.updated_at).toLocaleDateString("ko-KR")} · 글감{" "}
            {linkedCaptures.length}개
          </small>
        </div>
        <div className="project-actions">
          <button
            className="button ghost status-change"
            onClick={changeStatus}
            disabled={changingStatus}
          >
            {project.status === "active" ? (
              <>
                <Check /> 완료하기
              </>
            ) : (
              "다시 진행하기"
            )}
          </button>
          {project.status === "done" && (
            <div className="export-actions">
              <button className="button ghost">
                <Download /> 내보내기
              </button>
              <div>
                {(["pdf", "docx", "txt"] as ExportFormat[]).map((format) => (
                  <button key={format} onClick={() => exportProject(format)}>
                    {format.toUpperCase()}
                  </button>
                ))}
              </div>
            </div>
          )}
          <div className="project-menu-wrap">
            <button
              className="icon-btn"
              onClick={() => setMenuOpen(!menuOpen)}
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
      </div>

      <section className="section manuscript-section">
        <div className="section-title">
          <div>
            <FileText />
            <h2>원고</h2>
            <span className="number">{documents.length}</span>
          </div>
          <button onClick={createDocument} disabled={creatingDocument}>
            <Plus /> {creatingDocument ? "추가 중…" : "새 원고"}
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
                <small>
                  {new Date(doc.updated_at).toLocaleDateString("ko-KR")}
                </small>
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
        <div className="mini-cards">
          {linkedCaptures.map((capture) => (
            <Link href={`/captures/${capture.id}`} key={capture.id}>
              <small>
                {new Date(capture.created_at).toLocaleDateString("ko-KR")}
              </small>
              <b>{captureTitle(capture)}</b>
              <p>{captureExcerpt(capture)}</p>
            </Link>
          ))}
        </div>
      </section>

      {linking && (
        <div className="modal-backdrop">
          <section className="dialog capture-picker">
            <div className="dialog-heading">
              <div>
                <h2>프로젝트에 글감 연결</h2>
                <p>모든 글감에서 검색하고 여러 개를 선택하세요.</p>
              </div>
              <button className="icon-btn" onClick={() => setLinking(false)}>
                <X />
              </button>
            </div>
            <label className="search">
              <Search />
              <input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="글감 검색"
              />
            </label>
            <div className="capture-picker-list">
              {visibleCaptures.map((capture) => (
                <button
                  key={capture.id}
                  className={selectedIds.has(capture.id) ? "selected" : ""}
                  onClick={() =>
                    setSelectedIds((current) => {
                      const next = new Set(current);
                      next.has(capture.id)
                        ? next.delete(capture.id)
                        : next.add(capture.id);
                      return next;
                    })
                  }
                >
                  <span>
                    <b>{captureTitle(capture)}</b>
                    <small>{captureExcerpt(capture)}</small>
                  </span>
                  {selectedIds.has(capture.id) && <Check />}
                </button>
              ))}
            </div>
            <div className="form-actions">
              <button
                className="button ghost"
                onClick={() => setLinking(false)}
              >
                취소
              </button>
              <button className="button primary" onClick={saveCaptureLinks}>
                {selectedIds.size}개 연결 저장
              </button>
            </div>
          </section>
        </div>
      )}

      {editing && (
        <div className="modal-backdrop">
          <form className="dialog" onSubmit={saveEdit}>
            <div className="dialog-heading">
              <div>
                <h2>프로젝트 정보 수정</h2>
                <p>이름과 설명을 변경할 수 있어요.</p>
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
              <button
                className="button danger-button"
                onClick={async () => {
                  await api.delete(`/projects/${projectId}`);
                  router.push("/projects");
                }}
              >
                삭제
              </button>
            </div>
          </section>
        </div>
      )}
    </>
  );
}
