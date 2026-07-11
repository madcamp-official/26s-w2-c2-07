"use client";

import { ArrowRight, Plus } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { api } from "../api";
import type { ApiProject } from "../api-types";
import { PageHead, Shell, StatusBadge } from "../components";

export default function ProjectsPage() {
  const [projects, setProjects] = useState<ApiProject[]>([]);

  useEffect(() => {
    api
      .get<ApiProject[]>("/projects")
      .then(setProjects)
      .catch(() => setProjects([]));
  }, []);

  const activeProjects = projects.filter(
    (project) => project.status === "active",
  );
  const completedProjects = projects.filter(
    (project) => project.status === "done",
  );

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
        <ProjectSection
          title="진행 중"
          projects={activeProjects}
          emptyMessage="진행 중인 프로젝트가 없어요."
        />
        <ProjectSection
          title="완료"
          projects={completedProjects}
          emptyMessage="완료한 프로젝트가 아직 없어요."
        />
      </div>
    </Shell>
  );
}

function ProjectSection({
  title,
  projects,
  emptyMessage,
}: {
  title: string;
  projects: ApiProject[];
  emptyMessage: string;
}) {
  return (
    <section className="project-status-section">
      <div className="section-title">
        <div>
          <h2>{title}</h2>
          <span className="number">{projects.length}</span>
        </div>
      </div>
      <div className="projects-list">
        {projects.map((project, index) => (
          <Link
            href={`/projects/${project.id}`}
            className="project-wide"
            key={project.id}
          >
            <div className={`project-cover tone-${index % 3}`}>
              <span>N</span>
            </div>
            <div className="project-info">
              <StatusBadge status={project.status} />
              <h2>{project.title}</h2>
              <p>{project.description}</p>
              <div className="counts">
                <time>
                  마지막 수정{" "}
                  {new Date(project.updated_at).toLocaleDateString("ko-KR")}
                </time>
              </div>
            </div>
            <ArrowRight className="arrow" />
          </Link>
        ))}
        {!projects.length && (
          <div className="empty project-empty">{emptyMessage}</div>
        )}
      </div>
    </section>
  );
}
