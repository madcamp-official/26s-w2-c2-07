import Link from "next/link";
import { Plus } from "lucide-react";
import type { CaptureType } from "./data";

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
  image: "사진",
  link: "링크",
};

export function TypeBadge({ type }: { type: CaptureType }) {
  return <span className={`type type-${type}`}>{captureTypeLabels[type]}</span>;
}

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
