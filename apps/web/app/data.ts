export type CaptureType = "text" | "photo" | "link" | "video";
export type ProjectStatus = "active" | "done";

// 새 태그를 만들 때마다 이 팔레트를 순서대로 돌려가며 배정한다.
// 색상각을 서로 멀리 떨어뜨려 두어 태그가 몇 개든 인접한 두 태그가 같은 색으로 안 보이게 한다.
export const TAG_COLORS = [
  "#a8724c", // clay
  "#5f7a5c", // moss
  "#6d7fa3", // dusty blue
  "#b08a3e", // gold
  "#8a5a6b", // plum
  "#4b7a72", // teal
];

export function nextTagColor(existingTagCount: number): string {
  return TAG_COLORS[existingTagCount % TAG_COLORS.length];
}
