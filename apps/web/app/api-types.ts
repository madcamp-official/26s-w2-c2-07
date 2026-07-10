export interface ApiCaptureTag {
  id: string;
  name: string;
  color: string | null;
}

export interface ApiCapture {
  id: string;
  user_id: string;
  type: "text" | "photo" | "link" | "video";
  content: string | null;
  url: string | null;
  link_title: string | null;
  link_description: string | null;
  link_image_url: string | null;
  created_at: string;
  updated_at: string;
  tags: ApiCaptureTag[];
}

export interface ApiProject {
  id: string;
  user_id: string;
  title: string;
  description: string | null;
  status: "active" | "done" | "archived";
  created_at: string;
  updated_at: string;
}

export interface ApiDocument {
  id: string;
  project_id: string;
  title: string;
  content: string;
  created_at: string;
  updated_at: string;
}

export interface ApiProjectCaptureLink {
  capture_id: string;
  captures: ApiCapture;
}

export interface ApiTag {
  id: string;
  user_id: string;
  name: string;
  color: string | null;
  created_at: string;
}

export interface ApiProfile {
  id: string;
  display_name: string | null;
  avatar_url: string | null;
  created_at: string;
}
