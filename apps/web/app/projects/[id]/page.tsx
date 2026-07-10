"use client";

import { ArrowLeft } from "lucide-react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { Shell } from "../../components";
import { ProjectDetailClient } from "./project-detail-client";

export default function ProjectDetailPage() {
  const { id } = useParams<{ id: string }>();

  return (
    <Shell>
      <div className="page">
        <Link href="/projects" className="back">
          <ArrowLeft /> 프로젝트
        </Link>
        <ProjectDetailClient projectId={id} />
      </div>
    </Shell>
  );
}
