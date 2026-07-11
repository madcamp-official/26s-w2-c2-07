"use client";

import { Bell, Moon, Save } from "lucide-react";
import { useEffect, useState } from "react";
import { api } from "../api";
import type { ApiSettings } from "../api-types";
import { PageHead, Shell } from "../components";

const defaultSettings: ApiSettings = {
  captureAlertsEnabled: true,
  darkEditorEnabled: false,
};

export default function SettingsPage() {
  const [settings, setSettings] = useState(defaultSettings);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    api
      .get<ApiSettings>("/settings")
      .then(setSettings)
      .finally(() => setLoading(false));
  }, []);

  const save = async () => {
    setSaving(true);
    try {
      const result = await api.patch<ApiSettings>("/settings", settings);
      setSettings(result);
      setSaved(true);
      setTimeout(() => setSaved(false), 1500);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Shell>
      <div className="page narrow">
        <PageHead
          title="서비스 설정"
          desc="알림과 글쓰기 환경을 내 방식에 맞게 조정하세요."
        />
        <section className="preference-card">
          <h2>알림</h2>
          <SettingToggle
            icon={<Bell />}
            title="새 글감 알림"
            description="모바일이나 웹에서 새 글감이 추가되면 알려드려요."
            checked={settings.captureAlertsEnabled}
            disabled={loading}
            onClick={() =>
              setSettings((current) => ({
                ...current,
                captureAlertsEnabled: !current.captureAlertsEnabled,
              }))
            }
          />
        </section>
        <section className="preference-card">
          <h2>글쓰기 환경</h2>
          <SettingToggle
            icon={<Moon />}
            title="어두운 편집 화면"
            description="원고 편집기에서 눈이 편안한 어두운 배경을 사용해요."
            checked={settings.darkEditorEnabled}
            disabled={loading}
            onClick={() =>
              setSettings((current) => ({
                ...current,
                darkEditorEnabled: !current.darkEditorEnabled,
              }))
            }
          />
        </section>
        <p className="settings-note">
          모바일 동기화와 원고 자동 저장은 기본으로 항상 적용됩니다.
        </p>
        <button
          className="button primary settings-save"
          onClick={save}
          disabled={loading || saving}
        >
          <Save /> {saving ? "저장 중…" : saved ? "저장했어요" : "설정 저장"}
        </button>
      </div>
    </Shell>
  );
}

function SettingToggle({
  icon,
  title,
  description,
  checked,
  disabled,
  onClick,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  checked: boolean;
  disabled?: boolean;
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
        disabled={disabled}
        role="switch"
        aria-checked={checked}
      >
        <i />
      </button>
    </div>
  );
}
