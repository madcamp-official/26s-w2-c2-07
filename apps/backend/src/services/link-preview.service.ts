export interface LinkPreview {
  url: string;
  title: string | null;
  description: string | null;
  imageUrl: string | null;
}

function extractMeta(html: string, property: string): string | null {
  const regex = new RegExp(
    `<meta[^>]+(?:property|name)=["']${property}["'][^>]+content=["']([^"']*)["']`,
    "i",
  );
  return html.match(regex)?.[1] ?? null;
}

/**
 * Best-effort OG-tag scrape. Never throws — on any failure (network error,
 * timeout, non-HTML response) it returns a preview with null fields so the
 * capture can still be saved with just the raw URL.
 */
export async function fetchLinkPreview(url: string): Promise<LinkPreview> {
  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    const res = await fetch(url, { signal: controller.signal, headers: { "user-agent": "nook-link-preview/1.0" } });
    clearTimeout(timeout);

    if (!res.ok) return { url, title: null, description: null, imageUrl: null };

    const html = await res.text();

    return {
      url,
      title: extractMeta(html, "og:title"),
      description: extractMeta(html, "og:description"),
      imageUrl: extractMeta(html, "og:image"),
    };
  } catch {
    return { url, title: null, description: null, imageUrl: null };
  }
}
