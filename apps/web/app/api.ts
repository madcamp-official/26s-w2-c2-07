import {
  flushDesktopOfflineQueue,
  getDesktopBackendUrl,
  queueDesktopOfflineMutation,
} from "./desktop-bridge";
import {
  isMockModeActive,
  mockApiResponse,
  mockDownload,
  notifyMockMode,
} from "./mock-api";
import { supabase } from "./supabase-client";

const API_URL = process.env.NEXT_PUBLIC_API_URL!;

class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  const apiUrl = (await getDesktopBackendUrl()) ?? API_URL;
  const authorizationHeader = session
    ? `Bearer ${session.access_token}`
    : undefined;

  let response: Response;

  try {
    response = await fetch(`${apiUrl}${path}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        "X-Client-Source": "web",
        ...(authorizationHeader ? { Authorization: authorizationHeader } : {}),
        ...options.headers,
      },
    });
  } catch {
    // TODO: 더미 데이터 삭제
    await queueDesktopOfflineMutation(path, options);
    notifyMockMode();
    return mockApiResponse<T>(path, options);
  }

  const text = await response.text();
  const data = text ? JSON.parse(text) : undefined;

  if (!response.ok) {
    if ([404, 501, 503].includes(response.status)) {
      // TODO: 더미 데이터 삭제
      await queueDesktopOfflineMutation(path, options);
      notifyMockMode();
      return mockApiResponse<T>(path, options);
    }

    throw new ApiError(
      response.status,
      data?.error?.message ?? `API error ${response.status}`,
    );
  }

  void flushDesktopOfflineQueue(apiUrl, authorizationHeader);

  return data as T;
}

async function download(path: string): Promise<Blob> {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  const apiUrl = (await getDesktopBackendUrl()) ?? API_URL;

  let response: Response;

  try {
    response = await fetch(`${apiUrl}${path}`, {
      headers: session
        ? { Authorization: `Bearer ${session.access_token}` }
        : {},
    });
  } catch {
    // TODO: 더미 데이터 삭제
    notifyMockMode();
    return mockDownload(path);
  }

  if (!response.ok) {
    if ([404, 501, 503].includes(response.status)) {
      // TODO: 더미 데이터 삭제
      notifyMockMode();
      return mockDownload(path);
    }

    const data = await response.json().catch(() => undefined);
    throw new ApiError(
      response.status,
      data?.error?.message ?? `API error ${response.status}`,
    );
  }

  return response.blob();
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body?: unknown) =>
    request<T>(path, {
      method: "POST",
      body: body ? JSON.stringify(body) : undefined,
    }),
  patch: <T>(path: string, body?: unknown) =>
    request<T>(path, {
      method: "PATCH",
      body: body ? JSON.stringify(body) : undefined,
    }),
  delete: <T>(path: string) => request<T>(path, { method: "DELETE" }),
  download,
  isUsingMockData: isMockModeActive,
};
