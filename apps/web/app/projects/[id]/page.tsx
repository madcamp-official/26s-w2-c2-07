import { ArrowLeft } from "lucide-react";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Shell } from "../../components";
import { projects } from "../../data";
import { ProjectDetailClient } from "./project-detail-client";

export default async function ProjectDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const project = projects.find((item) => item.id === id);
  if (!project) notFound();

  return (
    <Shell>
      <div className="page">
        <Link href="/projects" className="back">
          <ArrowLeft /> 프로젝트
        </Link>
        <ProjectDetailClient project={project} />
      </div>
    </Shell>
  );
}
