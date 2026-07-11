"use client";
import Link from "next/link";
import {
  ArrowLeft,
  ChevronRight,
  Image,
  Link2,
  PanelRightClose,
  PanelRightOpen,
  Type,
  Video,
} from "lucide-react";
import { useParams } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { api } from "../../../../api";
import type {
  ApiCapture,
  ApiDocument,
  ApiProject,
  ApiProjectCaptureLink,
  ApiSettings,
} from "../../../../api-types";
import { captureExcerpt, captureTitle } from "../../../../capture-display";
import { captureTypeLabels } from "../../../../components";
import { CaptureSearchControls } from "../../../../components/capture-search-controls";
import { CaptureMedia } from "../../../../components/capture-media";
import { type CaptureType } from "../../../../data";

const referenceIcons: Record<CaptureType, typeof Type> = {
  text: Type,
  photo: Image,
  link: Link2,
  video: Video,
};

export default function Writer() {
  const params = useParams<{ id: string; manuscriptId: string }>();
  const [project, setProject] = useState<ApiProject | null>(null);
  const [captures, setCaptures] = useState<ApiCapture[]>([]);
  const [linkedCaptures, setLinkedCaptures] = useState<ApiCapture[]>([]);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [panel, setPanel] = useState(true);
  const [saved, setSaved] = useState(true);
  const [loaded, setLoaded] = useState(false);
  const [query, setQuery] = useState("");
  const [captureType, setCaptureType] = useState<"all" | CaptureType>("all");
  const [tagId, setTagId] = useState("all");
  const [darkEditor, setDarkEditor] = useState(false);
  const saveTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    api.get<ApiProject>(`/projects/${params.id}`).then(setProject);
    api.get<ApiCapture[]>("/captures").then(setCaptures);
    api
      .get<
        ApiCapture[] | ApiProjectCaptureLink[]
      >(`/projects/${params.id}/captures`)
      .then((items) =>
        setLinkedCaptures(
          items.map((item) => ("captures" in item ? item.captures : item)),
        ),
      );
    api
      .get<ApiSettings>("/settings")
      .then((settings) => setDarkEditor(settings.darkEditorEnabled));
    api
      .get<ApiDocument>(
        `/projects/${params.id}/documents/${params.manuscriptId}`,
      )
      .then((doc) => {
        setTitle(doc.title);
        setBody(doc.content);
        setLoaded(true);
      });
  }, [params.id, params.manuscriptId]);

  useEffect(() => {
    if (!loaded) return;
    setSaved(false);
    if (saveTimer.current) clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(async () => {
      await api.patch(
        `/projects/${params.id}/documents/${params.manuscriptId}`,
        {
          title,
          content: body,
        },
      );
      setSaved(true);
    }, 800);
    return () => {
      if (saveTimer.current) clearTimeout(saveTimer.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [title, body, loaded]);

  const count = useMemo(() => body.length, [body]);
  const availableTags = useMemo(() => {
    const unique = new Map<string, string>();
    captures.forEach((capture) =>
      capture.tags.forEach((tag) => unique.set(tag.id, tag.name)),
    );
    return [...unique.entries()];
  }, [captures]);
  const visibleCaptures = useMemo(
    () =>
      captures.filter((capture) => {
        const matchesQuery =
          `${captureTitle(capture)} ${captureExcerpt(capture)}`
            .toLowerCase()
            .includes(query.toLowerCase());
        const matchesType =
          captureType === "all" || capture.type === captureType;
        const matchesTag =
          tagId === "all" || capture.tags.some((tag) => tag.id === tagId);
        return matchesQuery && matchesType && matchesTag;
      }),
    [captureType, captures, query, tagId],
  );
  const visibleLinkedCaptures = useMemo(() => {
    const visibleIds = new Set(visibleCaptures.map((capture) => capture.id));
    return linkedCaptures.filter((capture) => visibleIds.has(capture.id));
  }, [linkedCaptures, visibleCaptures]);
  const linkedIds = useMemo(
    () => new Set(linkedCaptures.map((capture) => capture.id)),
    [linkedCaptures],
  );
  const remainingCaptures = visibleCaptures.filter(
    (capture) => !linkedIds.has(capture.id),
  );

  const insertCapture = (capture: ApiCapture) => {
    setBody((current) => `${current}\n\n${captureExcerpt(capture)}`);
  };

  const connectCapture = async (capture: ApiCapture) => {
    await api.post(`/projects/${params.id}/captures`, {
      captureId: capture.id,
    });
    setLinkedCaptures((current) =>
      current.some((item) => item.id === capture.id)
        ? current
        : [...current, capture],
    );
  };

  return (
    <div
      className={`writer ${panel ? "panel-on" : ""} ${darkEditor ? "dark-editor" : ""}`}
    >
      <header className="writer-header">
        <div>
          <Link href={`/projects/${params.id}`}>
            <ArrowLeft />
          </Link>
          <Link href={`/projects/${params.id}`}>{project?.title}</Link>
          <ChevronRight />
          <span>{title || "새 원고"}</span>
        </div>
        <div>
          <span className={saved ? "saved" : "saving"}>
            {saved ? "저장됨" : "저장 중…"}
          </span>
        </div>
      </header>
      <main className="editor">
        <input
          className="editor-title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="제목을 입력하세요"
        />
        <textarea
          className="editor-body"
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder="마음에 남은 문장부터 시작해보세요."
        />
        <footer>
          <span>{count.toLocaleString()}자</span>
        </footer>
      </main>
      <button
        className={`reference-panel-tab ${panel ? "open" : ""}`}
        onClick={() => setPanel((current) => !current)}
        aria-label={panel ? "글감 패널 닫기" : "글감 패널 열기"}
        aria-expanded={panel}
      >
        {panel ? <PanelRightClose /> : <PanelRightOpen />}
        <span>글감</span>
      </button>
      <aside className="reference-panel">
        <div className="reference-head">
          <div>
            <b>글감 찾아보기</b>
            <small>
              연결 {linkedCaptures.length}개 · 전체 {captures.length}개
            </small>
          </div>
        </div>
        <CaptureSearchControls
          compact
          query={query}
          type={captureType}
          tagId={tagId}
          tags={availableTags}
          onQueryChange={setQuery}
          onTypeChange={setCaptureType}
          onTagChange={setTagId}
        />
        <div className="reference-list">
          <section className="reference-section">
            <div className="reference-section-title">
              <b>프로젝트에 연결된 글감</b>
              <span>{visibleLinkedCaptures.length}</span>
            </div>
            {visibleLinkedCaptures.map((capture) => (
              <CaptureReference
                key={capture.id}
                capture={capture}
                actionLabel="원고에 넣기"
                onAction={insertCapture}
              />
            ))}
            {!visibleLinkedCaptures.length && (
              <p className="reference-empty">조건에 맞는 연결 글감이 없어요.</p>
            )}
          </section>
          <section className="reference-section">
            <div className="reference-section-title">
              <b>모든 글감</b>
              <span>{remainingCaptures.length}</span>
            </div>
            {remainingCaptures.map((capture) => (
              <CaptureReference
                key={capture.id}
                capture={capture}
                actionLabel="프로젝트에 연결하기"
                onAction={connectCapture}
              />
            ))}
            {!remainingCaptures.length && (
              <p className="reference-empty">조건에 맞는 다른 글감이 없어요.</p>
            )}
          </section>
        </div>
      </aside>
    </div>
  );
}

function CaptureReference({
  capture,
  actionLabel,
  onAction,
}: {
  capture: ApiCapture;
  actionLabel: string;
  onAction: (capture: ApiCapture) => void | Promise<void>;
}) {
  const Icon = referenceIcons[capture.type];
  return (
    <article className="reference-capture-card">
      <span>
        <Icon />
      </span>
      <div>
        <CaptureMedia capture={capture} variant="reference" />
        <small>{captureTypeLabels[capture.type]}</small>
        {capture.type === "link" && capture.url ? (
          <a
            className="reference-link"
            href={capture.url}
            target="_blank"
            rel="noreferrer"
          >
            {captureTitle(capture)} ↗
          </a>
        ) : (
          <b>{captureTitle(capture)}</b>
        )}
        <p>{captureExcerpt(capture)}</p>
        <button onClick={() => void onAction(capture)}>{actionLabel}</button>
      </div>
    </article>
  );
}
