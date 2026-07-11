import type {
  ApiCapture,
  ApiDocument,
  ApiProfile,
  ApiProject,
  ApiSettings,
  ApiTag,
} from "./api-types";

// TODO: 더미 데이터 삭제
// 백엔드가 응답하지 않는 로컬 프론트엔드 확인용 저장소입니다.
// 실제 API 응답이 있으면 이 데이터는 사용되지 않습니다.
const now = new Date().toISOString();
const userId = "00000000-0000-4000-8000-000000000001";

let tags: ApiTag[] = [
  {
    id: "tag-travel",
    user_id: userId,
    name: "여행",
    color: "#7f9584",
    created_at: now,
  },
  {
    id: "tag-daily",
    user_id: userId,
    name: "일상",
    color: "#b28f6b",
    created_at: now,
  },
  {
    id: "tag-reference",
    user_id: userId,
    name: "참고자료",
    color: "#8898a4",
    created_at: now,
  },
];

let captures: ApiCapture[] = [
  {
    id: "capture-quiet",
    user_id: userId,
    type: "text",
    content: "좋은 문장은 마음을 조용히 움직인다.",
    url: null,
    link_title: null,
    link_description: null,
    link_image_url: null,
    created_at: now,
    updated_at: now,
    tags: [tags[1]],
  },
  {
    id: "capture-rain",
    user_id: userId,
    type: "photo",
    content: "비 오는 오후의 창가와 천천히 번지는 불빛.",
    url: null,
    link_title: null,
    link_description: null,
    link_image_url: null,
    created_at: now,
    updated_at: now,
    tags: [tags[0], tags[1]],
  },
  {
    id: "capture-link",
    user_id: userId,
    type: "link",
    content: "원고를 꾸준히 쓰기 위해 다시 읽어볼 자료",
    url: "https://example.com/writing",
    link_title: "매일 쓰는 사람들의 작은 습관",
    link_description: "거창한 결심보다 작은 리듬이 글을 완성합니다.",
    link_image_url: null,
    created_at: now,
    updated_at: now,
    tags: [tags[2]],
  },
];

let projects: ApiProject[] = [
  {
    id: "project-travel",
    user_id: userId,
    title: "여행의 온도",
    description: "낯선 도시에서 만난 풍경과 마음을 기록합니다.",
    status: "active",
    created_at: now,
    updated_at: now,
  },
  {
    id: "project-complete",
    user_id: userId,
    title: "작은 기록들",
    description: "매일의 사소한 장면을 모은 글입니다.",
    status: "done",
    created_at: now,
    updated_at: now,
  },
];

let documents: ApiDocument[] = [
  {
    id: "document-rain",
    project_id: "project-travel",
    title: "비가 오던 도시에서",
    content: "그날의 도시는 유난히 천천히 젖어갔다.",
    created_at: now,
    updated_at: now,
  },
];
let linkedCaptureIds = new Set(["capture-quiet", "capture-rain"]);
let settings: ApiSettings = {
  captureAlertsEnabled: true,
  darkEditorEnabled: false,
};
let profile: ApiProfile = {
  id: userId,
  email: "local@nook.example",
  display_name: "로컬 작가",
  avatar_url: null,
  provider: "local dummy",
  created_at: now,
  settings,
};

const id = (prefix: string) => `${prefix}-${crypto.randomUUID()}`;
const bodyOf = (options: RequestInit) =>
  options.body ? JSON.parse(String(options.body)) : {};
const pathOnly = (path: string) => path.split("?")[0];

export function notifyMockMode() {
  mockModeActive = true;
  if (typeof window !== "undefined") {
    window.dispatchEvent(new CustomEvent("nook:mock-api"));
  }
}

let mockModeActive = false;
export const isMockModeActive = () => mockModeActive;

export function mockApiResponse<T>(path: string, options: RequestInit = {}): T {
  const method = options.method ?? "GET";
  const route = pathOnly(path);
  const body = bodyOf(options);

  if (route === "/me") {
    if (method === "PATCH")
      profile = {
        ...profile,
        display_name: body.displayName ?? profile.display_name,
        avatar_url: body.avatarUrl ?? profile.avatar_url,
      };
    return profile as T;
  }
  if (route === "/settings") {
    if (method === "PATCH") settings = { ...settings, ...body };
    return settings as T;
  }
  if (route === "/tags") {
    if (method === "POST") {
      const tag: ApiTag = {
        id: id("tag"),
        user_id: userId,
        name: body.name,
        color: body.color ?? null,
        created_at: now,
      };
      tags = [...tags, tag];
      return tag as T;
    }
    return tags as T;
  }
  if (/^\/tags\/[^/]+$/.test(route) && method === "DELETE") {
    const tagId = route.split("/").at(-1);
    tags = tags.filter((tag) => tag.id !== tagId);
    captures = captures.map((capture) => ({
      ...capture,
      tags: capture.tags.filter((tag) => tag.id !== tagId),
    }));
    return undefined as T;
  }
  if (route === "/captures") {
    if (method === "POST") {
      const capture: ApiCapture = {
        id: id("capture"),
        user_id: userId,
        type: body.type,
        content: body.content ?? null,
        url: body.url ?? null,
        link_title: body.type === "link" ? "로컬 링크 미리보기" : null,
        link_description:
          body.type === "link"
            ? "백엔드 연결 전 표시되는 링크 정보입니다."
            : null,
        link_image_url: null,
        created_at: now,
        updated_at: now,
        tags: tags.filter((tag) => body.tagIds?.includes(tag.id)),
      };
      captures = [capture, ...captures];
      return capture as T;
    }
    const projectId = new URLSearchParams(path.split("?")[1] ?? "").get(
      "projectId",
    );
    return captures.map((capture) => ({
      ...capture,
      isLinked: projectId ? linkedCaptureIds.has(capture.id) : undefined,
    })) as T;
  }
  const captureMatch = route.match(/^\/captures\/([^/]+)$/);
  if (captureMatch) {
    const capture = captures.find((item) => item.id === captureMatch[1]);
    if (method === "PATCH" && capture) {
      Object.assign(capture, {
        content: body.content ?? capture.content,
        url: body.url ?? capture.url,
        tags: body.tagIds
          ? tags.filter((tag) => body.tagIds.includes(tag.id))
          : capture.tags,
        updated_at: now,
      });
    }
    if (method === "DELETE")
      captures = captures.filter((item) => item.id !== captureMatch[1]);
    return capture as T;
  }
  if (route === "/projects") {
    if (method === "POST") {
      const project: ApiProject = {
        id: id("project"),
        user_id: userId,
        title: body.title,
        description: body.description ?? null,
        status: "active",
        created_at: now,
        updated_at: now,
      };
      projects = [project, ...projects];
      return project as T;
    }
    return projects as T;
  }
  const projectMatch = route.match(/^\/projects\/([^/]+)$/);
  if (projectMatch) {
    const project = projects.find((item) => item.id === projectMatch[1]);
    if (method === "PATCH" && project)
      Object.assign(project, { ...body, updated_at: now });
    if (method === "DELETE")
      projects = projects.filter((item) => item.id !== projectMatch[1]);
    return project as T;
  }
  const statusMatch = route.match(/^\/projects\/([^/]+)\/status$/);
  if (statusMatch) {
    const project = projects.find((item) => item.id === statusMatch[1]);
    if (project) project.status = body.status;
    return project as T;
  }
  const documentsMatch = route.match(/^\/projects\/([^/]+)\/documents$/);
  if (documentsMatch) {
    if (method === "POST") {
      const document: ApiDocument = {
        id: id("document"),
        project_id: documentsMatch[1],
        title: body.title ?? "제목 없음",
        content: body.content ?? "",
        created_at: now,
        updated_at: now,
      };
      documents = [...documents, document];
      return document as T;
    }
    return documents.filter(
      (document) => document.project_id === documentsMatch[1],
    ) as T;
  }
  const documentMatch = route.match(
    /^\/projects\/([^/]+)\/documents\/([^/]+)$/,
  );
  if (documentMatch) {
    const document = documents.find((item) => item.id === documentMatch[2]);
    if (method === "PATCH" && document)
      Object.assign(document, body, { updated_at: now });
    return document as T;
  }
  const linksMatch = route.match(
    /^\/projects\/([^/]+)\/captures(?:\/([^/]+))?$/,
  );
  if (linksMatch) {
    if (method === "POST") linkedCaptureIds.add(body.captureId);
    if (method === "DELETE" && linksMatch[2])
      linkedCaptureIds.delete(linksMatch[2]);
    return captures.filter((capture) => linkedCaptureIds.has(capture.id)) as T;
  }
  if (route.includes("/assets/"))
    return { uploadUrl: "", storagePath: "local-dummy", token: "" } as T;
  return undefined as T;
}

export function mockDownload(path: string): Blob {
  const format =
    new URLSearchParams(path.split("?")[1] ?? "").get("format") ?? "txt";
  return new Blob(
    [
      `Nook 로컬 더미 프로젝트 (${format.toUpperCase()})\n\n백엔드 연결 후 실제 문서로 교체됩니다.`,
    ],
    { type: "text/plain;charset=utf-8" },
  );
}
