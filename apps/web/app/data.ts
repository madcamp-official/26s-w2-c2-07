export type CaptureType = "text" | "photo" | "link" | "video";
export type ProjectStatus = "active" | "done";

export interface Notification {
  id: string;
  source: "mobile" | "web";
  title: string;
  detail: string;
  time: string;
  unread: boolean;
}

// TODO(backend): 알림 API는 이번 연동 범위에서 제외되어 더미 데이터를 유지합니다.
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
