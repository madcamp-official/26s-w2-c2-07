"use client";

import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, ExternalLink, Trash2 } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { api } from "../../api";
import type { ApiCapture } from "../../api-types";
import { captureDate, captureExcerpt, captureTitle } from "../../capture-display";
import { Shell, TypeBadge } from "../../components";

export default function CaptureDetail() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [capture, setCapture] = useState<ApiCapture | null>(null);
  const [notFound, setNotFound] = useState(false);

  useEffect(() => {
    api
      .get<ApiCapture>(`/captures/${id}`)
      .then(setCapture)
      .catch(() => setNotFound(true));
  }, [id]);

  const remove = async () => {
    if (!capture) return;
    await api.delete(`/captures/${capture.id}`);
    router.push("/captures");
  };

  if (notFound) {
    return (
      <Shell>
        <div className="page narrow">
          <p>글감을 찾을 수 없어요.</p>
        </div>
      </Shell>
    );
  }

  if (!capture) return null;

  return (
    <Shell>
      <div className="page narrow">
        <Link href="/captures" className="back">
          <ArrowLeft /> 글감함으로
        </Link>
        <article className="detail-paper">
          <div className="detail-meta">
            <TypeBadge type={capture.type} />
            <time>{captureDate(capture)}</time>
          </div>
          <h1>{captureTitle(capture)}</h1>
          <p className="detail-body">{captureExcerpt(capture)}</p>
          {capture.type === "link" && capture.url && (
            <a className="link-preview" href={capture.url} target="_blank" rel="noreferrer">
              <div>
                <small>{capture.url}</small>
                <b>{capture.link_title ?? capture.url}</b>
                <p>{capture.link_description}</p>
              </div>
              <ExternalLink />
            </a>
          )}
          <div className="detail-actions">
            <button className="danger" onClick={remove}>
              <Trash2 /> 삭제
            </button>
          </div>
        </article>
      </div>
    </Shell>
  );
}
