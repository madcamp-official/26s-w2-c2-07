type DesktopOfflineQueueItem = {
  id: string;
  path: string;
  method: string;
  body?: string;
  headers?: Record<string, string>;
  createdAt: string;
};

type DesktopBridge = {
  getEnv: () => Promise<{
    backendUrl?: string;
    webAppUrl?: string;
    offlineQueuePath?: string;
  }>;
  readOfflineQueue: () => Promise<DesktopOfflineQueueItem[]>;
  writeOfflineQueue: (
    items: DesktopOfflineQueueItem[],
  ) => Promise<DesktopOfflineQueueItem[]>;
};

declare global {
  interface Window {
    nookDesktop?: DesktopBridge;
  }
}

const MUTATING_METHODS = new Set(["POST", "PATCH", "PUT", "DELETE"]);

function isDesktopBridgeAvailable() {
  return typeof window !== "undefined" && Boolean(window.nookDesktop);
}

export async function getDesktopBackendUrl() {
  if (!isDesktopBridgeAvailable()) return undefined;

  const env = await window.nookDesktop!.getEnv();
  return env.backendUrl || undefined;
}

export async function queueDesktopOfflineMutation(
  path: string,
  options: RequestInit,
) {
  if (!isDesktopBridgeAvailable()) return;

  const method = (options.method || "GET").toUpperCase();
  if (!MUTATING_METHODS.has(method)) return;

  const currentQueue = await window.nookDesktop!.readOfflineQueue();
  await window.nookDesktop!.writeOfflineQueue([
    ...currentQueue,
    {
      id: crypto.randomUUID(),
      path,
      method,
      body: typeof options.body === "string" ? options.body : undefined,
      headers: normalizeHeaders(options.headers),
      createdAt: new Date().toISOString(),
    },
  ]);
}

export async function flushDesktopOfflineQueue(
  apiUrl: string,
  authorizationHeader?: string,
) {
  if (!isDesktopBridgeAvailable()) return;

  const queue = await window.nookDesktop!.readOfflineQueue();
  if (queue.length === 0) return;

  const remaining: DesktopOfflineQueueItem[] = [];

  for (const item of queue) {
    try {
      const response = await fetch(`${apiUrl}${item.path}`, {
        method: item.method,
        body: item.body,
        headers: {
          "Content-Type": "application/json",
          ...(authorizationHeader
            ? { Authorization: authorizationHeader }
            : {}),
          ...item.headers,
        },
      });

      if (!response.ok) remaining.push(item);
    } catch {
      remaining.push(item);
    }
  }

  if (remaining.length !== queue.length) {
    await window.nookDesktop!.writeOfflineQueue(remaining);
  }
}

function normalizeHeaders(headers: RequestInit["headers"]) {
  if (!headers) return undefined;
  if (headers instanceof Headers) return Object.fromEntries(headers.entries());
  if (Array.isArray(headers)) return Object.fromEntries(headers);
  return headers as Record<string, string>;
}
