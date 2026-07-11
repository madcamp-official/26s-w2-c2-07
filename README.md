# 26s-w2-c2-07

## 공통과제 II : 협업형 실전 산출물 제작 (2인 1팀)

**목적:** 실시간 인터랙션, LLM Wrapper, Cross-Platform 중 하나의 옵션을 선택해 구현하며, 선택한 기술을 실제로 동작하는 형태의 산출물로 완성한다.

**선택 옵션:**

| 옵션 | 설명 |
|---|---|
| 실시간 인터랙션 | 사용자 간 상태 변화, 실시간 데이터 흐름, 스트리밍 응답 등 실시간성이 드러나는 기능을 구현 |
| LLM Wrapper | LLM API를 활용하여 AI 기능이 포함된 산출물을 구현 |
| Cross-Platform | 하나의 산출물을 여러 실행 환경에서 사용할 수 있도록 구현* |

> *데스크톱 앱 ↔ 모바일 앱; 혹은 다른 폼팩터에서의 앱; 웹만/웹 기반 프레임워크(Electron, Tauri 등) 대신 다른 프레임워크를 시도해보는 것을 적극 권장

**결과물:** 선택한 옵션이 적용된 작동 가능한 산출물, 실행 가능한 코드, 시연 자료 및 관련 문서

---

## 팀원

| 이름 | 학교 | GitHub | 역할 |
|---|---|---|---|
| 양우현 | KAIST | [hyun020215](https://github.com/hyun020215) | 기획, 웹 프론트엔드, QA |
| 이서영 | 성균관대학교 | [sksy930](https://github.com/sksy930) | 백엔드, Supabase, QA |

---

## 선택 옵션

- [ ] 실시간 인터랙션
- [ ] LLM Wrapper
- [x] Cross-Platform

---

## 기획안

- **산출물 주제:** 일상의 영감을 수집하고 여러 원고와 프로젝트로 발전시키는 웹·모바일 서비스 Nook
- **제작 목적:** 서로 다른 앱에 흩어지는 문장·사진·링크를 같은 계정으로 수집하고, 웹에서 글쓰기까지 자연스럽게 이어지도록 한다.
- **선택 옵션:** Cross-Platform
- **핵심 구현 요소:**
  - 웹과 모바일에서 같은 Supabase Auth 계정 및 글감 데이터 사용
  - 조각글·사진·링크, 다중 태그, 프로젝트·원고 관리
  - 원고 자동 저장과 완료 프로젝트 PDF·DOCX·TXT 내보내기
- **사용 / 시연 시나리오:** Google 로그인 → 모바일 또는 웹에서 태그와 글감 저장 → 웹 글감함에서 수정·검색 → 프로젝트에 글감 연결 → 여러 원고 작성 → 프로젝트 완료 → 파일 내보내기
- **팀원별 역할:** 웹·백엔드·모바일을 기능 단위로 분담하고 API 계약, 인증, 통합 QA는 공동 검증한다.

### 개발 일정

| 날짜 | 목표 |
|---|---|
| Day 1 | 저장소·Supabase·인증·공통 레이아웃 구성 |
| Day 2 | 글감 CRUD, 사진 업로드, 링크 미리보기 |
| Day 3 | 태그, 프로젝트, 프로젝트-글감 연결 |
| Day 4 | 복수 원고, 자동 저장, 전체 글감 검색·삽입 |
| Day 5 | 모바일 수집 화면과 웹·모바일 데이터 연동 |
| Day 6 | 설정, 프로필 연동, 상태 전환, 내보내기 및 QA |
| Day 7 | 반응형 수정, 회귀 테스트, 문서화, 배포 |

---

## 구현 명세서

| 구현 요소 | 설명 | 우선순위 |
|---|---|---|
| 인증·프로필 | Google 로그인 계정과 프로필을 동일 사용자 ID로 연동 | 필수 |
| 글감·태그 | 글감 CRUD, 작성 중 태그 생성, 다중 태그 연결, 검색·필터 | 필수 |
| 프로젝트·원고 | 상태별 프로젝트, 전체 글감 연결 모달, 복수 원고, 멱등 생성, 자동 저장 | 필수 |
| Cross-Platform | 모바일에서 저장한 글감을 별도 설정 없이 웹에 동기화 | 필수 |
| 내보내기 | 완료 프로젝트를 PDF·DOCX·TXT로 다운로드 | 선택 |
| 사용자 설정 | 실제 저장되는 알림·편집 화면 설정 | 선택 |

---

## 아키텍처

```text
Next.js Web ─┐
             ├─ Bearer Access Token ─ Express REST API
Expo Mobile ─┘                         ├─ Zod 입력 검증
                                      ├─ 사용자 소유권 검증
                                      ├─ 링크 미리보기 / 문서 내보내기
                                      └─ Supabase
                                           ├─ Auth
                                           ├─ PostgreSQL + RLS
                                           └─ Storage
```

웹과 모바일은 동일한 REST API 계약을 사용한다. API 서버가 service-role 키를 사용하더라도 PostgreSQL RLS를 유지하여 이중으로 보호한다.

---

## 설계 문서

> 프로젝트 성격에 따라 필요한 항목만 작성

### 화면 / 인터페이스 설계

<!-- Figma 링크, 화면 이미지, CLI 사용 예시, 앱 화면 등 -->
- 웹: 로그인, 홈, 글감함, 글감 작성·상세·수정, 프로젝트 목록·상세, 원고 편집, 프로필, 설정
- 모바일: 로그인, 최근 글감, 조각글·사진·링크 작성, 글감 상세, 프로필
- 프로젝트 목록은 `진행 중`과 `완료` 섹션으로 구분한다.
- 프로젝트 상태는 정보 수정 모달이 아닌 별도 `완료하기` / `다시 진행하기` 버튼으로 변경한다.
- 프로젝트 글감 연결 모달과 원고 편집 패널은 사용자의 모든 글감을 검색한다.
- 완료 프로젝트에서만 PDF·DOCX·TXT 다운로드 메뉴를 표시한다.
- 모바일 동기화와 원고 자동 저장은 항상 켜져 있으므로 설정 항목을 제공하지 않는다.

### 데이터 구조

> 아래 내용은 현재 스키마를 기준으로 다음 변경을 반영한 명세이다. 아직 실제 마이그레이션에는 적용하지 않았다.

```text
auth.users
  ├─ profiles (1:1)
  ├─ user_settings (1:1)
  ├─ captures
  │   ├─ capture_assets
  │   ├─ capture_tags ─ tags
  │   └─ project_captures ─ projects
  └─ projects
      ├─ project_captures ─ captures
      └─ documents
```

#### 핵심 테이블

```sql
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  capture_alerts_enabled boolean not null default true,
  dark_editor_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.captures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('text', 'photo', 'link', 'video')),
  content text,
  url text,
  link_title text,
  link_description text,
  link_image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (type <> 'link' or url is not null)
);

create table public.capture_assets (
  id uuid primary key default gen_random_uuid(),
  capture_id uuid not null references public.captures (id) on delete cascade,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create table public.tags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 30),
  color text,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

create table public.capture_tags (
  capture_id uuid not null references public.captures (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (capture_id, tag_id)
);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'active' check (status in ('active', 'done')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.project_captures (
  project_id uuid not null references public.projects (id) on delete cascade,
  capture_id uuid not null references public.captures (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (project_id, capture_id)
);

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  client_request_id uuid not null,
  title text not null default '제목 없음',
  content text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (project_id, client_request_id)
);
```

#### 데이터 규칙

- `profiles.id = auth.users.id`이며 가입 트리거가 Google 이름과 프로필 사진을 초기화한다. 이메일은 중복 저장하지 않고 Auth 정보와 프로필을 `/me`에서 결합한다.
- 링크 글감의 사용자 메모는 `captures.content`, 외부 페이지 설명은 `link_description`에 저장한다. 미리보기가 사용자 메모를 덮어쓰면 안 된다.
- 한 글감에는 여러 태그를 연결할 수 있다. `(user_id, name)`과 `(capture_id, tag_id)` 고유 제약으로 중복을 막는다.
- 프로젝트 상태는 `active`, `done`만 사용하며 `archived`는 제거한다.
- `documents.client_request_id`는 원고 추가 버튼 중복 클릭과 네트워크 재시도로 인한 중복 원고를 막는 멱등성 키다.
- 사용자 설정에는 실제 선택 가능한 알림·편집 테마만 저장한다. 모바일 동기화와 자동 저장 설정 컬럼은 만들지 않는다.
- `profiles`, `user_settings`, `captures`, `tags`, `projects`는 직접 소유자 기준 RLS를 사용한다. 연결 테이블은 부모 글감 또는 프로젝트의 소유권을 검사한다.

#### 공통 글감 DTO

연결된 글감 포맷이 화면마다 달라지는 문제를 방지하기 위해 글감 목록·상세·프로젝트 연결·원고 검색에서 같은 평탄화 응답을 사용한다.

```ts
interface Capture {
  id: string;
  userId: string;
  type: 'text' | 'photo' | 'link' | 'video';
  content: string | null;
  url: string | null;
  linkTitle: string | null;
  linkDescription: string | null;
  linkImageUrl: string | null;
  tags: Array<{ id: string; name: string; color: string | null }>;
  isLinked?: boolean;
  createdAt: string;
  updatedAt: string;
}
```

### API / 외부 서비스 연동

모든 엔드포인트는 `/api` 기준이며 `Authorization: Bearer <supabase_access_token>`을 사용한다. 오류 응답은 `{ "error": { "code", "message", "details" } }` 형식으로 통일한다.

| Method / 방식 | Endpoint / 서비스 | 설명 | 요청 | 응답 | 비고 |
|---|---|---|---|---|---|
| GET | `/me` | Auth 계정·프로필·설정 결합 조회 | - | 사용자·설정 | 이메일은 Auth 기준 |
| PATCH | `/me` | 이름·프로필 사진 수정 | `displayName`, `avatarUrl` | 사용자 | 이메일 변경 제외 |
| GET/PATCH | `/settings` | 실제 서비스 설정 조회·저장 | 알림, 편집 테마 | 설정 | 동기화·자동 저장 제외 |
| GET | `/captures` | 모든 내 글감 검색·필터 | `q`, `type`, `tagIds`, `projectId`, `cursor` | `Capture[]` | 원고·연결 모달 공용 |
| POST | `/captures` | 글감과 복수 태그 생성 | `type`, `content`, `url`, `tagIds` | `Capture` | 링크 메모 보존 |
| GET | `/captures/:id` | 글감 상세 조회 | - | `Capture` | 소유권 검증 |
| PATCH | `/captures/:id` | 글감과 태그 수정 | `content`, `url`, `tagIds` | `Capture` | URL 변경 시 미리보기 갱신 |
| DELETE | `/captures/:id` | 글감 삭제 | - | `204` | 자산·연결 cascade |
| POST | `/captures/:id/assets/upload-url` | 사진 업로드 URL 발급 | 파일명·MIME | signed URL | 기존 API 유지 |
| POST | `/captures/:id/assets/complete` | 업로드 완료 기록 | storage path | asset | 기존 API 유지 |
| GET/POST | `/tags` | 내 태그 목록·생성 | `name`, `color` | 태그 | 글감 작성 중 생성 가능 |
| PATCH/DELETE | `/tags/:id` | 태그 수정·삭제 | `name`, `color` | 태그 또는 `204` | 연결 자동 해제 |
| POST/DELETE | `/captures/:id/tags[...]` | 태그 연결·해제 | `tagId` | `204` | 기존 API 유지 |
| POST | `/link-preview` | 외부 링크 정보 추출 | `url` | 제목·설명·이미지 | `content` 변경 금지 |
| GET/POST | `/projects` | 상태별 목록·프로젝트 생성 | `status` 또는 프로젝트 정보 | 프로젝트 | 목록은 상태별 섹션 |
| GET/PATCH/DELETE | `/projects/:id` | 상세·이름/설명 수정·삭제 | `title`, `description` | 프로젝트 | 상태 수정 제외 |
| PATCH | `/projects/:id/status` | 전용 버튼으로 상태 전환 | `active` 또는 `done` | 프로젝트 | `archived` 금지 |
| GET | `/projects/:id/captures` | 연결 글감 조회 | - | `Capture[]` | 응답 평탄화 |
| POST/DELETE | `/projects/:id/captures[...]` | 글감 연결·해제 | `captureId` | `204` | 복합 PK로 중복 방지 |
| GET/POST | `/projects/:id/documents` | 원고 목록·멱등 생성 | `clientRequestId`, 제목, 본문 | 원고 | 동일 키면 기존 원고 반환 |
| GET/PATCH/DELETE | `/projects/:id/documents/:documentId` | 원고 조회·자동 저장·삭제 | 제목·본문 | 원고 또는 `204` | 자동 저장 상시 활성화 |
| GET | `/projects/:id/export?format=pdf\|docx\|txt` | 완료 프로젝트 내보내기 | format | 파일 stream | `done`만 허용 |

#### 주요 요청 계약

글감 작성 중 새 태그 생성:

```text
POST /tags
→ 응답 tag.id를 선택 목록에 추가
→ POST /captures의 tagIds에 포함
```

글감 생성·수정:

```json
{
  "type": "link",
  "content": "사용자가 직접 작성한 메모",
  "url": "https://example.com/article",
  "tagIds": ["tag-uuid-1", "tag-uuid-2"]
}
```

프로젝트 연결 모달과 원고 글감 검색:

```http
GET /captures?q=여행&type=text&projectId=<project-id>&limit=30&cursor=...
```

`projectId`가 있으면 각 응답의 `isLinked`를 채운다. 원고 편집기는 `projectId` 없이 호출하여 연결 여부와 무관하게 모든 글감을 검색한다.

원고 멱등 생성:

```json
{
  "clientRequestId": "클릭 시 한 번 생성한 UUID",
  "title": "제목 없음",
  "content": ""
}
```

동일 키에는 기존 원고를 반환하고, 클라이언트는 첫 요청이 끝날 때까지 추가 버튼을 비활성화한다.

프로젝트 상태 전환:

```json
{ "status": "done" }
```

허용 전이는 `active ↔ done`뿐이다. 완료 프로젝트만 PDF·DOCX·TXT로 내보낼 수 있으며 원고를 목록 순서대로 합친다.

---

## 산출물 및 실행 방법

- **산출물 설명:** 웹과 모바일에서 글감을 수집하고 웹에서 프로젝트·복수 원고로 발전시키는 Nook 프로토타입
- **실행 환경:** Node.js, 웹 브라우저, Expo 지원 Android/iOS 기기 또는 에뮬레이터
- **실행 방법:** 각 앱의 환경 변수를 구성하고 backend, web, mobile을 순서대로 실행
- **시연 영상 / 이미지:** (추후 추가)

### 실행 방법

```bash
# Backend
cd apps/backend
cp .env.example .env
npm install
npm run dev

# Web
cd apps/web
cp .env.example .env
npm install
npm run dev

# Mobile
cd apps/mobile
cp .env.example .env
npm install
npm start
```

### 기술 구성

| 분류 | 사용 기술 |
|---|---|
| 핵심 기술 | Cross-Platform 웹·모바일 데이터 연동 |
| 실행 환경 | Next.js, Expo React Native, Node.js Express |
| 데이터 저장 | Supabase PostgreSQL, Storage, Row Level Security |
| 외부 API / 서비스 | Supabase Auth, 링크 미리보기 대상 웹 페이지 |
| 기타 | TypeScript, Zod, PDF·DOCX·TXT 생성 라이브러리 |

---

## 회고 문서

> [KPT 방법론 참고](https://velog.io/@habwa/%EB%8B%A8%EA%B8%B0-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%ED%9A%8C%EA%B3%A0-KPT-%EB%B0%A9%EB%B2%95%EB%A1%A0)

### Keep — 잘 된 점, 다음에도 유지할 것

-
-
-

### Problem — 아쉬웠던 점, 개선이 필요한 것

-
-
-

### Try — 다음번에 시도해볼 것

-
-
-

### 팀원별 소감

**양우현:**

> 

**이서영:**

> 

---

## 참고 자료

### 실시간 인터랙션

**WebSocket**
- https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API
- https://techblog.woowahan.com/5268/
- https://tech.kakao.com/posts/391
- https://daleseo.com/websocket/
- https://kakaoentertainment-tech.tistory.com/110

**Socket.IO**
- https://socket.io/docs/v4/
- https://inpa.tistory.com/entry/SOCKET-%F0%9F%93%9A-Namespace-Room-%EA%B8%B0%EB%8A%A5
- https://adjh54.tistory.com/549
- https://fred16157.github.io/node.js/nodejs-socketio-communication-room-and-namespace/

**SSE (Server-Sent Events)**
- https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
- https://developer.mozilla.org/ko/docs/Web/API/Server-sent_events/Using_server-sent_events
- https://api7.ai/ko/blog/what-is-sse

**TCP / UDP Socket**
- https://docs.python.org/3/library/socket.html
- https://inpa.tistory.com/entry/NW-%F0%9F%8C%90-%EC%95%84%EC%A7%81%EB%8F%84-%EB%AA%A8%ED%98%B8%ED%95%9C-TCP-UDP-%EA%B0%9C%EB%85%90-%E2%9D%93-%EC%89%BD%EA%B2%8C-%EC%9D%B4%ED%95%B4%ED%95%98%EC%9E%90

**gRPC Streaming**
- https://grpc.io/docs/what-is-grpc/core-concepts/
- https://tech.ktcloud.com/entry/gRPC%EC%9D%98-%EB%82%B4%EB%B6%80-%EA%B5%AC%EC%A1%B0-%ED%8C%8C%ED%97%A4%EC%B9%98%EA%B8%B0-HTTP2-Protobuf-%EA%B7%B8%EB%A6%AC%EA%B3%A0-%EC%8A%A4%ED%8A%B8%EB%A6%AC%EB%B0%8D
- https://tech.ktcloud.com/entry/gRPC%EC%9D%98-%EB%82%B4%EB%B6%80-%EA%B5%AC%EC%A1%B0-%ED%8C%8C%ED%97%A4%EC%B9%98%EA%B8%B02-Channel-Stub
- https://inspirit941.tistory.com/371
- https://devocean.sk.com/blog/techBoardDetail.do?ID=167433

**WebRTC**
- https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API
- https://webrtc.org/getting-started/overview
- https://web.dev/articles/webrtc-basics?hl=ko
- https://devocean.sk.com/blog/techBoardDetail.do?ID=164885
- https://beomkey-nkb.github.io/%EA%B0%9C%EB%85%90%EC%A0%95%EB%A6%AC/webRTC%EC%A0%95%EB%A6%AC/
- https://gh402.tistory.com/45
- https://on.com2us.com/tech/webrtc-coturn-turn-stun-server-setup-guide/

**QUIC / WebTransport**
- https://developer.mozilla.org/en-US/docs/Web/API/WebTransport_API
- https://datatracker.ietf.org/doc/html/rfc9000
- https://news.hada.io/topic?id=13888

#### KCLOUD VM / Cloudflare Tunnel 환경별 주의사항

| 환경 | 사용 가능(권장) 기술 | 포트/조건 | 주의할 기술 |
|---|---|---|---|
| **로컬 / 일반 VM** | HTTP/REST, WebSocket, Socket.IO, SSE, TCP Socket, gRPC Streaming, WebRTC, QUIC/WebTransport 등 대부분 가능 | 직접 포트 개방 가능. 예: 3000, 5000, 8000, 8080, 9000 등. 외부 공개 시 방화벽/보안그룹/공인 IP 설정 필요 | WebRTC는 STUN/TURN 필요 가능. QUIC/WebTransport는 HTTP/3 · UDP 지원 필요 |
| **KCLOUD VM (VPN 내부)** | HTTP/REST, WebSocket, Socket.IO, SSE, WebRTC 시그널링 | 접속 기기 VPN 필요. 기본 허용 포트: **22, 80, 443**. 개발 포트(3000, 8000, 8080 등)는 직접 접근 제한 가능 | TCP Socket은 포트 제한 있음. gRPC는 HTTP/2 설정 필요. WebRTC 미디어·UDP·QUIC/WebTransport 비권장 |
| **KCLOUD VM + Tunnel** | HTTP/REST, WebSocket, Socket.IO, SSE, WebRTC 시그널링 | VM의 `localhost:<port>`를 도메인에 연결. `localPort`는 **1024~65535**. 예: 3000, 8000, 8080 가능 | 순수 TCP Socket, UDP, WebRTC 미디어/DataChannel, QUIC/WebTransport 불가. gRPC 보장 어려움 |
| **외부 서비스 + 우리 도메인** | HTTP/REST, WebSocket, Socket.IO, SSE, WebRTC 시그널링 | Vercel/Netlify/Railway/Render/AWS/GCP 등에 배포 후 CNAME/A 레코드 연결. 보통 외부는 **443** 사용 | WebSocket/gRPC/TCP/UDP는 플랫폼 지원 여부 확인 필요. 서버리스 플랫폼은 장시간 연결 제한 가능 |
| **서버 없이 외부 SaaS 사용** | Supabase Realtime, Firebase, Pusher/Ably, LLM API Streaming | 직접 포트 관리 불필요. 각 서비스 SDK/API 사용 | 커스텀 TCP/UDP 서버 구현 불가. WebRTC는 STUN/TURN 필요할 수 있음 |

### LLM Wrapper

- https://github.com/teddylee777/openai-api-kr
- https://github.com/teddylee777/langchain-kr
- https://devocean.sk.com/blog/techBoardDetail.do?ID=167407
- https://mastra.ai/docs

### Cross-Platform

- https://flutter.dev/
- https://reactnative.dev/
- https://docs.expo.dev/
- https://kotlinlang.org/multiplatform/
