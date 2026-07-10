"use client";

import { Bell, Moon, Save, Smartphone } from "lucide-react";
import { useState } from "react";
import { PageHead, Shell } from "../components";

export default function SettingsPage() {
  const [saved, setSaved] = useState(false);
  const [settings, setSettings] = useState({
    captureAlerts: true,
    mobileSync: true,
    darkMode: false,
    autosave: "800",
  });

  const toggle = (key: "captureAlerts" | "mobileSync" | "darkMode") =>
    setSettings((current) => ({ ...current, [key]: !current[key] }));

  return (
    <Shell>
      <div className="page narrow">
        <PageHead
          title="서비스 설정"
          desc="알림, 동기화와 글쓰기 환경을 내 방식에 맞게 조정하세요."
        />
        <section className="preference-card">
          <h2>알림 및 동기화</h2>
          <SettingToggle
            icon={<Bell />}
            title="새 글감 알림"
            description="모바일이나 웹에서 새 글감이 추가되면 알려드려요."
            checked={settings.captureAlerts}
            onClick={() => toggle("captureAlerts")}
          />
          <SettingToggle
            icon={<Smartphone />}
            title="모바일 자동 동기화"
            description="같은 계정의 모바일 글감을 웹에 바로 표시해요."
            checked={settings.mobileSync}
            onClick={() => toggle("mobileSync")}
          />
        </section>
        <section className="preference-card">
          <h2>글쓰기 환경</h2>
          <SettingToggle
            icon={<Moon />}
            title="어두운 편집 화면"
            description="원고 편집기에서 눈이 편안한 어두운 배경을 사용해요."
            checked={settings.darkMode}
            onClick={() => toggle("darkMode")}
          />
          <label className="preference-select">
            <div>
              <b>자동 저장 간격</b>
              <small>입력을 멈춘 뒤 저장할 시간을 선택하세요.</small>
            </div>
            <select
              value={settings.autosave}
              onChange={(event) =>
                setSettings({ ...settings, autosave: event.target.value })
              }
            >
              <option value="800">0.8초</option>
              <option value="1500">1.5초</option>
              <option value="3000">3초</option>
            </select>
          </label>
        </section>
        <button
          className="button primary settings-save"
          onClick={() => {
            setSaved(true);
            setTimeout(() => setSaved(false), 1500);
          }}
        >
          <Save /> {saved ? "저장했어요" : "설정 저장"}
        </button>
        {/* TODO(backend): 사용자별 서비스 설정 조회·저장 API와 연결해야 합니다. */}
      </div>
    </Shell>
  );
}

function SettingToggle({
  icon,
  title,
  description,
  checked,
  onClick,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  checked: boolean;
  onClick: () => void;
}) {
  return (
    <div className="preference-row">
      <span className="preference-icon">{icon}</span>
      <div>
        <b>{title}</b>
        <small>{description}</small>
      </div>
      <button
        className={`toggle ${checked ? "on" : ""}`}
        onClick={onClick}
        role="switch"
        aria-checked={checked}
      >
        <i />
      </button>
    </div>
  );
}
