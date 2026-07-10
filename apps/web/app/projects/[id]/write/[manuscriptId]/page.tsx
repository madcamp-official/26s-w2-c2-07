"use client";
import Link from "next/link";
import {
  ArrowLeft,
  ChevronRight,
  Image,
  Link2,
  PanelRightClose,
  PanelRightOpen,
  Search,
  Type,
  Video,
} from "lucide-react";
import { useParams } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { api } from "../../../../api";
import type { ApiDocument, ApiProject, ApiProjectCaptureLink } from "../../../../api-types";
import { captureExcerpt, captureTitle } from "../../../../capture-display";
import { captureTypeLabels } from "../../../../components";
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
  const [links, setLinks] = useState<ApiProjectCaptureLink[]>([]);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [panel, setPanel] = useState(true);
  const [saved, setSaved] = useState(true);
  const [loaded, setLoaded] = useState(false);
  const [query, setQuery] = useState("");
  const saveTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    api.get<ApiProject>(`/projects/${params.id}`).then(setProject);
    api.get<ApiProjectCaptureLink[]>(`/projects/${params.id}/captures`).then(setLinks);
    api
      .get<ApiDocument>(`/projects/${params.id}/documents/${params.manuscriptId}`)
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
      await api.patch(`/projects/${params.id}/documents/${params.manuscriptId}`, {
        title,
        content: body,
      });
      setSaved(true);
    }, 800);
    return () => {
      if (saveTimer.current) clearTimeout(saveTimer.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [title, body, loaded]);

  const count = useMemo(() => body.length, [body]);
  const visibleLinks = useMemo(
    () =>
      links.filter(({ captures: c }) =>
        `${captureTitle(c)} ${captureExcerpt(c)}`.includes(query),
      ),
    [links, query],
  );

  return (
    <div className={`writer ${panel ? "panel-on" : ""}`}>
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
          <button className="icon-btn" onClick={() => setPanel(!panel)}>
            {panel ? <PanelRightClose /> : <PanelRightOpen />}
          </button>
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
      <aside className="reference-panel">
        <div className="reference-head">
          <div>
            <b>연결된 글감</b>
            <small>{links.length}개의 영감</small>
          </div>
          <button className="icon-btn" onClick={() => setPanel(false)}>
            <PanelRightClose />
          </button>
        </div>
        <label className="search">
          <Search />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="글감 검색"
          />
        </label>
        <div className="reference-list">
          {visibleLinks.map(({ capture_id, captures: c }) => {
            const I = referenceIcons[c.type];
            return (
              <article key={capture_id}>
                <span>
                  <I />
                </span>
                <div>
                  <small>{captureTypeLabels[c.type]}</small>
                  <b>{captureTitle(c)}</b>
                  <p>{captureExcerpt(c)}</p>
                  <button
                    onClick={() => setBody((v) => `${v}\n\n${captureExcerpt(c)}`)}
                  >
                    원고에 넣기
                  </button>
                </div>
              </article>
            );
          })}
        </div>
      </aside>
    </div>
  );
}
