"use client";

import {
  Bell,
  BookOpen,
  Compass,
  FolderKanban,
  Home,
  LogOut,
  Menu,
  Settings,
  Trash2,
  UserRound,
  X,
} from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { api } from "../api";
import type { ApiProfile } from "../api-types";
import { notifications } from "../data";
import { supabase } from "../supabase-client";

const navigation = [
  { href: "/", icon: Home, label: "홈" },
  { href: "/captures", icon: BookOpen, label: "글감함" },
  { href: "/projects", icon: FolderKanban, label: "프로젝트" },
  { href: "/surf", icon: Compass, label: "글감 서핑" },
] as const;

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activePopup, setActivePopup] = useState<
    "notifications" | "account" | null
  >(null);
  const popupAreaRef = useRef<HTMLDivElement>(null);
  const [profile, setProfile] = useState<ApiProfile | null>(null);
  const [email, setEmail] = useState<string | undefined>();
  const [authChecked, setAuthChecked] = useState(false);
  const [mockMode, setMockMode] = useState(false);

  useEffect(() => {
    const closeOnOutsideClick = (event: MouseEvent) => {
      if (!popupAreaRef.current?.contains(event.target as Node)) {
        setActivePopup(null);
      }
    };

    document.addEventListener("mousedown", closeOnOutsideClick);
    return () => document.removeEventListener("mousedown", closeOnOutsideClick);
  }, []);

  useEffect(() => {
    const showMockBanner = () => setMockMode(true);
    window.addEventListener("nook:mock-api", showMockBanner);
    return () => window.removeEventListener("nook:mock-api", showMockBanner);
  }, []);

  useEffect(() => {
    const { data: subscription } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        if (!session) {
          router.replace("/login");
          setProfile(null);
          setEmail(undefined);
        } else {
          setEmail(session.user.email);
          api
            .get<ApiProfile>("/me")
            .then(setProfile)
            .catch(() => setProfile(null));
        }
        setAuthChecked(true);
      },
    );
    return () => subscription.subscription.unsubscribe();
  }, [router]);

  const signOut = async () => {
    await supabase.auth.signOut();
    router.push("/login");
  };

  const deleteAccount = async () => {
    await api.delete("/me");
    if (api.isUsingMockData()) {
      alert("API 연결이 필요합니다");
      return;
    }
    await supabase.auth.signOut();
    router.push("/login");
  };

  if (!authChecked) return null;

  const isActive = (href: string) =>
    href === "/" ? pathname === href : pathname.startsWith(href);

  const togglePopup = (popup: "notifications" | "account") => {
    setActivePopup((current) => (current === popup ? null : popup));
  };

  return (
    <div className="shell">
      <button
        className="mobile-menu"
        onClick={() => setMobileMenuOpen(true)}
        aria-label="메뉴 열기"
      >
        <Menu />
      </button>

      <aside className={`sidebar ${mobileMenuOpen ? "open" : ""}`}>
        <div className="brand-row">
          <Link href="/" className="brand">
            Nook<span>.</span>
          </Link>
          <button
            className="mobile-close"
            onClick={() => setMobileMenuOpen(false)}
            aria-label="메뉴 닫기"
          >
            <X />
          </button>
        </div>
        <p className="brand-note">생각이 머무는 작은 공간</p>

        <nav>
          {navigation.map(({ href, icon: Icon, label }) => (
            <Link
              key={href}
              href={href}
              className={isActive(href) ? "active" : ""}
              onClick={() => setMobileMenuOpen(false)}
            >
              <Icon />
              <span>{label}</span>
            </Link>
          ))}
        </nav>

        <div className="side-bottom">
          <Link
            href="/settings"
            className={pathname.startsWith("/settings") ? "active" : ""}
          >
            <Settings />
            <span>설정</span>
          </Link>
        </div>
      </aside>

      <main className="main">
        {mockMode && (
          <div className="mock-data-banner" role="status">
            로컬 더미 데이터로 화면을 표시하고 있습니다. 실제 저장 내용이
            아닙니다.
          </div>
        )}
        <header className="topbar">
          <div />
          <div className="topbar-actions" ref={popupAreaRef}>
            <button
              className="icon-btn notification-trigger"
              onClick={() => togglePopup("notifications")}
              aria-label="알림"
              aria-expanded={activePopup === "notifications"}
            >
              <Bell />
              <span className="unread-dot" />
            </button>
            <button
              className="avatar"
              onClick={() => togglePopup("account")}
              aria-label="계정 메뉴"
              aria-expanded={activePopup === "account"}
            >
              {profile?.display_name?.[0] ?? "?"}
            </button>

            {activePopup === "notifications" && <NotificationPopup />}
            {activePopup === "account" && (
              <AccountPopup
                profile={profile}
                email={email}
                onSignOut={signOut}
                onDeleteAccount={deleteAccount}
              />
            )}
          </div>
        </header>
        {children}
      </main>
    </div>
  );
}

function NotificationPopup() {
  return (
    <section className="top-popup notification-popup" aria-label="최근 알림">
      <div className="popup-heading">
        <div>
          <b>최근 알림</b>
          <small>모바일과 웹에서 모은 글감</small>
        </div>
        <button>모두 읽음</button>
      </div>
      <div className="notification-list">
        {notifications.map((notification) => (
          <article
            key={notification.id}
            className={notification.unread ? "unread" : ""}
          >
            <span className={`source-icon source-${notification.source}`}>
              {notification.source === "mobile" ? "M" : "W"}
            </span>
            <div>
              <b>{notification.title}</b>
              <p>{notification.detail}</p>
              <small>{notification.time}</small>
            </div>
          </article>
        ))}
      </div>
      {/* TODO(backend): 실시간 capture 생성 알림 조회 및 읽음 처리 API와 연결해야 합니다. */}
    </section>
  );
}

function AccountPopup({
  profile,
  email,
  onSignOut,
  onDeleteAccount,
}: {
  profile: ApiProfile | null;
  email: string | undefined;
  onSignOut: () => void;
  onDeleteAccount: () => void;
}) {
  return (
    <section className="top-popup account-popup" aria-label="계정 메뉴">
      <div className="account-summary">
        <span className="avatar">{profile?.display_name?.[0] ?? "?"}</span>
        <div>
          <b>{profile?.display_name ?? "이름 없음"}</b>
          <small>{email}</small>
        </div>
      </div>
      <Link href="/profile">
        <UserRound /> 내 프로필
      </Link>
      <button onClick={onSignOut}>
        <LogOut /> 로그아웃
      </button>
      <button className="danger-menu-item" onClick={onDeleteAccount}>
        <Trash2 /> 회원 탈퇴
      </button>
    </section>
  );
}
