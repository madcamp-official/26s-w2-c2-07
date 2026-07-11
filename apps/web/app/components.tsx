import Link from "next/link";
import { Plus } from "lucide-react";
import type { CaptureType, ProjectStatus } from "./data";

export { AppShell as Shell } from "./components/app-shell";

interface PageHeadProps {
  title: React.ReactNode;
  eyebrow?: string;
  desc?: string;
  action?: React.ReactNode;
}

export function PageHead({ eyebrow, title, desc, action }: PageHeadProps) {
  return (
    <div className="page-head">
      <div>
        {eyebrow && <p className="eyebrow">{eyebrow}</p>}
        <h1>{title}</h1>
        {desc && <p className="subtitle">{desc}</p>}
      </div>
      {action}
    </div>
  );
}

const captureTypeLabels: Record<CaptureType, string> = {
  text: "조각글",
  photo: "사진",
  link: "링크",
  video: "동영상",
};

export function TypeBadge({ type }: { type: CaptureType }) {
  return <span className={`type type-${type}`}>{captureTypeLabels[type]}</span>;
}

export { captureTypeLabels };

const projectStatusLabels: Record<ProjectStatus, string> = {
  active: "진행 중",
  done: "완료",
};

export function StatusBadge({ status }: { status: ProjectStatus }) {
  return (
    <span className="status">
      <i />
      {projectStatusLabels[status]}
    </span>
  );
}

export { projectStatusLabels };

interface AddButtonProps {
  href?: string;
  children?: React.ReactNode;
}

export function AddButton({
  href = "/captures/new",
  children = "새 글감",
}: AddButtonProps) {
  return (
    <Link className="button primary" href={href}>
      <Plus />
      {children}
    </Link>
  );
}
