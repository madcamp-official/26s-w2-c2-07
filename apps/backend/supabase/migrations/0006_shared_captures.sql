-- 글감 서핑: 사용자가 글감을 공유하고, 다른 사용자가 둘러보며 저장/신고할 수 있게 한다.
alter table captures add column is_shared boolean not null default false;
alter table captures add column shared_visibility text not null default 'visible'
  check (shared_visibility in ('visible', 'limited'));
alter table captures add column saved_count integer not null default 0;
alter table captures add column report_count integer not null default 0;

create index captures_is_shared_idx on captures (is_shared) where is_shared;

-- capture_saves: 누가 어떤 공유 글감을 저장했는지 기록 (중복 저장 방지 + saved_count 산출 근거)
create table capture_saves (
  id uuid primary key default gen_random_uuid(),
  capture_id uuid not null references captures (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (capture_id, user_id)
);

create index capture_saves_user_id_idx on capture_saves (user_id);

-- capture_reports: 누가 어떤 공유 글감을 신고했는지 기록 (중복 신고 방지 + report_count 산출 근거)
create table capture_reports (
  id uuid primary key default gen_random_uuid(),
  capture_id uuid not null references captures (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  reason text not null,
  created_at timestamptz not null default now(),
  unique (capture_id, user_id)
);

create index capture_reports_capture_id_idx on capture_reports (capture_id);

alter table capture_saves enable row level security;
alter table capture_reports enable row level security;

create policy "capture_saves: owner full access" on capture_saves
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "capture_reports: owner full access" on capture_reports
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- captures 테이블은 기존에 "본인 소유만 접근" 정책만 있었다. 서핑 화면에서 다른 사용자의
-- 공유 글감을 읽을 수 있도록 읽기 전용 정책을 추가한다 (쓰기는 여전히 본인 글감만 가능).
create policy "captures: read shared visible captures" on captures
  for select using (is_shared = true and shared_visibility = 'visible');
