"use client";

import {
  Bell,
  BookOpen,
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
import { usePathname } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { notifications, profile } from "../data";

const navigation = [
  { href: "/", icon: Home, label: "홈" },
  { href: "/captures", icon: BookOpen, label: "글감함" },
  { href: "/projects", icon: FolderKanban, label: "프로젝트" },
] as const;

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activePopup, setActivePopup] = useState<
    "notifications" | "account" | null
  >(null);
  const popupAreaRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const closeOnOutsideClick = (event: MouseEvent) => {
      if (!popupAreaRef.current?.contains(event.target as Node)) {
        setActivePopup(null);
      }
    };

    document.addEventListener("mousedown", closeOnOutsideClick);
    return () => document.removeEventListener("mousedown", closeOnOutsideClick);
  }, []);

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
              {profile.initial}
            </button>

            {activePopup === "notifications" && <NotificationPopup />}
            {activePopup === "account" && <AccountPopup />}
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

function AccountPopup() {
  return (
    <section className="top-popup account-popup" aria-label="계정 메뉴">
      <div className="account-summary">
        <span className="avatar">{profile.initial}</span>
        <div>
          <b>{profile.name}</b>
          <small>{profile.email}</small>
        </div>
      </div>
      <Link href="/profile">
        <UserRound /> 내 프로필
      </Link>
      <Link href="/login">
        <LogOut /> 로그아웃
      </Link>
      <button className="danger-menu-item">
        <Trash2 /> 회원 탈퇴
      </button>
      {/* TODO(backend): Supabase 로그아웃 및 계정 삭제 API와 연결해야 합니다. */}
    </section>
  );
}
