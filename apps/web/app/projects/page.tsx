"use client";

import Link from "next/link";
import { ArrowRight, Plus } from "lucide-react";
import { useEffect, useState } from "react";
import { api } from "../api";
import type { ApiProject } from "../api-types";
import { PageHead, Shell, StatusBadge } from "../components";

export default function Projects() {
  const [projects, setProjects] = useState<ApiProject[]>([]);

  useEffect(() => {
    api.get<ApiProject[]>("/projects").then(setProjects).catch(() => setProjects([]));
  }, []);

  return (
    <Shell>
      <div className="page">
        <PageHead
          title="프로젝트"
          desc="모아둔 영감을 여러 편의 원고로 천천히 완성해보세요."
          action={
            <Link className="button primary" href="/projects/new">
              <Plus /> 새 프로젝트
            </Link>
          }
        />
        <div className="projects-list">
          {" "}
          {projects.map((p, i) => (
            <Link
              href={`/projects/${p.id}`}
              className="project-wide"
              key={p.id}
            >
              <div className={`project-cover tone-${i}`}>
                <span>N</span>
              </div>
              <div className="project-info">
                <StatusBadge status={p.status} />
                <h2>{p.title}</h2>
                <p>{p.description}</p>
                <div className="counts">
                  <time>마지막 수정 {new Date(p.updated_at).toLocaleDateString("ko-KR")}</time>
                </div>
              </div>
              <ArrowRight className="arrow" />
            </Link>
          ))}
        </div>
      </div>
    </Shell>
  );
}
