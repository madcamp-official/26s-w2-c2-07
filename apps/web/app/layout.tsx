import type { Metadata } from "next";
import "./globals.css";
import "./responsive.css";
import "./styles/capture-browser.css";

export const metadata: Metadata = {
  title: "Nook — 나만의 조용한 글쓰기 공간",
  description: "생각을 모으고 글로 이어가는 따뜻한 기록 공간",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
