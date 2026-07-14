import type { ApiProfile } from "./api-types";

const PROFILE_CACHE_KEY = "nook:profile-cache";

export function readCachedProfile() {
  if (typeof window === "undefined") return null;

  try {
    const raw = window.localStorage.getItem(PROFILE_CACHE_KEY);
    return raw ? (JSON.parse(raw) as ApiProfile) : null;
  } catch {
    return null;
  }
}

export function writeCachedProfile(profile: ApiProfile | null) {
  if (typeof window === "undefined") return;

  if (!profile) {
    window.localStorage.removeItem(PROFILE_CACHE_KEY);
    return;
  }

  window.localStorage.setItem(PROFILE_CACHE_KEY, JSON.stringify(profile));
}
