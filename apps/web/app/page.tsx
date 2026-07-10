"use client";

import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  Feather,
  FolderKanban,
  Image,
  Link2,
  Type,
  Video,
} from "lucide-react";
import { useEffect, useState } from "react";
import { api } from "./api";
import type { ApiCapture, ApiProject } from "./api-types";
import { captureDate, captureExcerpt, captureTitle } from "./capture-display";
import { AddButton, PageHead, Shell, StatusBadge, TypeBadge } from "./components";

const icons = {
  text: Type,
  photo: Image,
  link: Link2,
  video: Video,
};

export default function Home() {
  const [captures, setCaptures] = useState<ApiCapture[]>([]);
  const [projects, setProjects] = useState<ApiProject[]>([]);

  useEffect(() => {
    api.get<ApiCapture[]>("/captures").then(setCaptures).catch(() => setCaptures([]));
    api.get<ApiProject[]>("/projects").then(setProjects).catch(() => setProjects([]));
  }, []);

  return (
    <Shell>
      <div className="page">
        <PageHead
          title={
            <>
              오늘의 생각이
              <br />
              내일의 글이 되도록.
            </>
          }
          desc="스치는 영감을 모으고, 나만의 문장으로 천천히 이어가세요."
          action={<AddButton />}
        />
        <section className="quick">
          <div className="quick-mark">
            <Feather />
          </div>
          <div>
            <b>무엇을 남겨볼까요?</b>
            <p>문장, 사진, 링크를 가볍게 기록해보세요.</p>
          </div>
          <Link href="/captures/new">
            기록하기 <ArrowRight />
          </Link>
        </section>
        <section className="section">
          <div className="section-title">
            <div>
              <BookOpen />
              <h2>최근 글감</h2>
            </div>
            <Link href="/captures">
              모두 보기 <ArrowRight />
            </Link>
          </div>
          <div className="capture-list">
            {" "}
            {captures.slice(0, 4).map((c) => {
              const Icon = icons[c.type];
              return (
                <Link
                  href={`/captures/${c.id}`}
                  className="capture-row"
                  key={c.id}
                >
                  <span className="capture-icon">
                    <Icon />
                  </span>
                  <div>
                    <b>{captureTitle(c)}</b>
                    <p>{captureExcerpt(c)}</p>
                  </div>
                  <TypeBadge type={c.type} />
                  <time>{captureDate(c)}</time>
                </Link>
              );
            })}
          </div>
        </section>
        <section className="section">
          <div className="section-title">
            <div>
              <FolderKanban />
              <h2>이어 쓰는 프로젝트</h2>
            </div>
            <Link href="/projects">
              모두 보기 <ArrowRight />
            </Link>
          </div>
          <div className="project-grid">
            {" "}
            {projects.map((p, i) => (
              <Link
                href={`/projects/${p.id}`}
                className={`project-card tone-${i}`}
                key={p.id}
              >
                <StatusBadge status={p.status} />
                <h3>{p.title}</h3>
                <p>{p.description}</p>
                <div>
                  <time>{new Date(p.updated_at).toLocaleDateString("ko-KR")}</time>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </div>
    </Shell>
  );
}
