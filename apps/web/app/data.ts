export type CaptureType = "text" | "photo" | "link" | "video";
export type ProjectStatus = "active" | "done" | "archived";

export interface Tag {
  id: string;
  name: string;
  color: string;
  count: number;
}

export interface Capture {
  id: string;
  type: CaptureType;
  title: string;
  excerpt: string;
  date: string;
  tags: string[];
  project?: string;
  color?: string;
}

export interface Manuscript {
  id: string;
  title: string;
  excerpt: string;
  updated: string;
  words: number;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  status: ProjectStatus;
  updated: string;
  captures: number;
  manuscripts: Manuscript[];
}

export interface Notification {
  id: string;
  source: "mobile" | "web";
  title: string;
  detail: string;
  time: string;
  unread: boolean;
}

// TODO(backend): Supabase tags 및 capture_tags 조회 결과로 교체해야 하는 더미 데이터입니다.
export const tags: Tag[] = [
  { id: "travel", name: "여행", color: "#7f9584", count: 3 },
  { id: "sentence", name: "문장", color: "#b28f6b", count: 2 },
  { id: "daily", name: "일상", color: "#8898a4", count: 2 },
  { id: "reference", name: "참고자료", color: "#9b879d", count: 2 },
];

// TODO(backend): Supabase captures 테이블 조회 결과로 교체해야 하는 더미 데이터입니다.
export const captures: Capture[] = [
  {
    id: "quiet-sentence",
    type: "text",
    title: "좋은 문장은 마음을 조용히 움직인다",
    excerpt: "설명하지 않아도 오래 곁에 머무는 문장에 대하여.",
    date: "오늘 10:23",
    project: "여행의 온도",
    tags: ["문장", "여행"],
  },
  {
    id: "rainy-window",
    type: "photo",
    title: "비 오는 오후의 창가",
    excerpt: "창에 맺힌 물방울과 느리게 번지는 도시의 불빛.",
    date: "어제 16:42",
    color: "#b9c3bf",
    tags: ["일상"],
  },
  {
    id: "writing-habits",
    type: "link",
    title: "매일 쓰는 사람들의 작은 습관",
    excerpt: "거창한 결심보다 작은 리듬이 글을 완성한다.",
    date: "7월 7일",
    project: "나의 작은 기록들",
    tags: ["참고자료", "문장"],
  },
  {
    id: "recording",
    type: "text",
    title: "기록은 나를 이해하는 방법이다",
    excerpt: "잊기 위해 적었는데, 적고 나니 비로소 알게 되었다.",
    date: "7월 5일",
    tags: ["일상"],
  },
  {
    id: "summer-table",
    type: "photo",
    title: "여름 오후의 작업 테이블",
    excerpt: "식어가는 차와 펼쳐 둔 노트, 길어진 그림자.",
    date: "7월 3일",
    color: "#d7c5aa",
    tags: ["일상"],
  },
  {
    id: "slow-travel",
    type: "link",
    title: "천천히 여행하는 법",
    excerpt: "도착보다 머무는 일에 집중하는 여행 안내서.",
    date: "6월 28일",
    project: "여행의 온도",
    tags: ["여행", "참고자료"],
  },
];

// TODO(backend): Supabase projects/documents 조회 결과로 교체해야 하는 더미 데이터입니다.
export const projects: Project[] = [
  {
    id: "travel-temperature",
    title: "여행의 온도",
    description: "낯선 도시에서 만난 풍경과 사람, 그때의 마음을 기록합니다.",
    status: "active",
    updated: "오늘 09:15",
    captures: 12,
    manuscripts: [
      {
        id: "rainy-city",
        title: "비가 오던 도시에서",
        excerpt: "그날의 도시는 유난히 천천히 젖어갔다.",
        updated: "오늘 09:15",
        words: 1284,
      },
      {
        id: "morning-market",
        title: "아침 시장을 걷는 법",
        excerpt: "여행지의 하루는 시장에서 가장 먼저 깨어난다.",
        updated: "어제 21:08",
        words: 862,
      },
      {
        id: "empty-platform",
        title: "비어 있는 플랫폼",
        excerpt: "기차가 떠난 뒤에도 한동안 그 자리에 서 있었다.",
        updated: "7월 6일",
        words: 540,
      },
    ],
  },
  {
    id: "small-records",
    title: "나의 작은 기록들",
    description: "매일의 사소한 장면을 잊지 않기 위한 짧은 산문 모음.",
    status: "active",
    updated: "7월 8일",
    captures: 8,
    manuscripts: [
      {
        id: "cup-of-tea",
        title: "차 한 잔이 식는 동안",
        excerpt: "오후 네 시, 창문을 조금 열어 두었다.",
        updated: "7월 8일",
        words: 734,
      },
      {
        id: "walking-home",
        title: "집으로 걷는 길",
        excerpt: "일부러 한 정거장 먼저 내려 천천히 걸었다.",
        updated: "7월 2일",
        words: 418,
      },
    ],
  },
  {
    id: "letters-to-season",
    title: "계절에게 보내는 편지",
    description: "지나가는 계절마다 한 편씩 남기는 편지.",
    status: "active",
    updated: "6월 30일",
    captures: 5,
    manuscripts: [
      {
        id: "early-summer",
        title: "초여름에게",
        excerpt: "너는 늘 예고 없이 창문 너머로 찾아온다.",
        updated: "6월 30일",
        words: 960,
      },
    ],
  },
];

// TODO(backend): 웹·모바일 capture 생성 이벤트 알림 조회 결과로 교체해야 하는 더미 데이터입니다.
export const notifications: Notification[] = [
  {
    id: "n1",
    source: "mobile",
    title: "새 사진 글감이 도착했어요",
    detail: "비 오는 오후의 창가",
    time: "5분 전",
    unread: true,
  },
  {
    id: "n2",
    source: "web",
    title: "조각글이 저장되었어요",
    detail: "좋은 문장은 마음을 조용히 움직인다",
    time: "1시간 전",
    unread: true,
  },
  {
    id: "n3",
    source: "mobile",
    title: "새 링크를 확인해보세요",
    detail: "천천히 여행하는 법",
    time: "어제",
    unread: false,
  },
];

// TODO(backend): Supabase profiles 및 활동 통계 조회 결과로 교체해야 하는 더미 데이터입니다.
export const profile = {
  name: "김누리",
  email: "nuri@nook.kr",
  bio: "매일의 작은 장면을 기록합니다.",
  initial: "누",
  joined: "2026년 4월",
  captureCount: 36,
  projectCount: 3,
  manuscriptCount: 6,
};
