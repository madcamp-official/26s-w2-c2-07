# nook backend

Express 5 + Supabase (Auth / PostgreSQL / Storage) API 서버.

## 실행 방법

```bash
cp .env.example .env   # Supabase 프로젝트 값 채우기
npm install
npm run dev             # http://localhost:4000
```

Supabase 대시보드의 SQL Editor에서 `supabase/migrations/0001_init.sql`을 실행해 테이블을 만드세요.
Storage에는 `SUPABASE_STORAGE_BUCKET`(기본값 `capture-assets`) 버킷을 미리 만들어야 합니다.

## 폴더 구조

```
src/
├─ index.ts            # 서버 진입점 (listen)
├─ app.ts              # Express 앱 조립 (미들웨어 + 라우트 등록)
├─ config/env.ts        # 환경변수 로드 + zod 검증
├─ lib/supabase.ts       # Supabase 클라이언트 (admin / auth 검증용)
├─ types/                # Express Request 타입 보강, DB 타입 placeholder
├─ middlewares/          # 인증(auth), 에러 핸들러, 404 핸들러
├─ schemas/              # zod 요청 검증 스키마
├─ routes/               # HTTP 메서드+경로 -> 컨트롤러 매핑
├─ controllers/          # 요청 파싱 -> 서비스 호출 -> 응답
├─ services/             # 비즈니스 로직 (여러 repository/외부 API 조합)
└─ repositories/         # Supabase 테이블에 대한 실제 쿼리
```

요청 흐름: `routes → controllers (zod 검증) → services (비즈니스 로직) → repositories (DB 쿼리)`

## 인증

모든 보호된 라우트는 `Authorization: Bearer <supabase-access-token>` 헤더가 필요합니다.
`middlewares/auth.ts`가 토큰을 검증해 `req.user`를 채우고, 이후 모든 소유권 판별은 `req.user.id` 기준입니다
(요청 바디에 담긴 사용자 ID는 신뢰하지 않습니다).

## 데이터 모델

`profiles / captures / capture_assets / projects / project_captures / documents` — 자세한 스키마는
`supabase/migrations/0001_init.sql` 참고. 프로젝트 1개는 문서 여러 개를 가질 수 있습니다.
