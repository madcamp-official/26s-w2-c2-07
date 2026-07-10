import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  Feather,
  FolderKanban,
  Image,
  Link2,
  Type,
} from "lucide-react";
import { AddButton, PageHead, Shell, TypeBadge } from "./components";
import { captures, projects } from "./data";

const icons = {
  text: Type,
  image: Image,
  link: Link2,
};

export default function Home() {
  return (
    <Shell>
      <div className="page">
        <PageHead
          eyebrow="2026년 7월 10일, 금요일"
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
                    <b>{c.title}</b>
                    <p>{c.excerpt}</p>
                  </div>
                  <TypeBadge type={c.type} />
                  <time>{c.date}</time>
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
                <span className="status">
                  <i />
                  {p.status}
                </span>
                <h3>{p.title}</h3>
                <p>{p.description}</p>
                <div>
                  <span>원고 {p.manuscripts.length}</span>
                  <span>글감 {p.captures}</span>
                  <time>{p.updated}</time>
                </div>
              </Link>
            ))}
          </div>
        </section>
      </div>
    </Shell>
  );
}
