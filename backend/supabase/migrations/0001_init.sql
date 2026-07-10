-- profiles: 1 row per auth.users, created via a trigger (or lazily by the API) on first sign-in
create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now()
);

-- captures: 글감 (조각글 / 사진 / 링크)
create table captures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('text', 'photo', 'link', 'video')),
  content text,
  url text,
  link_title text,
  link_description text,
  link_image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index captures_user_id_idx on captures (user_id);
create index captures_user_id_type_idx on captures (user_id, type);

-- capture_assets: 사진 글감에 업로드된 Storage 파일 정보 (capture 1개당 보통 1개)
create table capture_assets (
  id uuid primary key default gen_random_uuid(),
  capture_id uuid not null references captures (id) on delete cascade,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index capture_assets_capture_id_idx on capture_assets (capture_id);

-- projects: 글감을 묶어 글을 완성해가는 단위
create table projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'active' check (status in ('active', 'done', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index projects_user_id_idx on projects (user_id);

-- project_captures: 프로젝트 <-> 글감 다대다 연결
create table project_captures (
  project_id uuid not null references projects (id) on delete cascade,
  capture_id uuid not null references captures (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (project_id, capture_id)
);

create index project_captures_capture_id_idx on project_captures (capture_id);

-- documents: 프로젝트 안에서 쓰는 글 (프로젝트 1개당 여러 개 가능)
create table documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects (id) on delete cascade,
  title text not null default '제목 없음',
  content text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index documents_project_id_idx on documents (project_id);

-- Row Level Security: API 서버는 service-role 키로 우회하지만, 만약을 대비한 이중 방어선으로 설정
alter table profiles enable row level security;
alter table captures enable row level security;
alter table capture_assets enable row level security;
alter table projects enable row level security;
alter table project_captures enable row level security;
alter table documents enable row level security;

create policy "profiles: owner full access" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "captures: owner full access" on captures
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "capture_assets: owner full access" on capture_assets
  for all using (
    exists (select 1 from captures c where c.id = capture_assets.capture_id and c.user_id = auth.uid())
  );

create policy "projects: owner full access" on projects
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "project_captures: owner full access" on project_captures
  for all using (
    exists (select 1 from projects p where p.id = project_captures.project_id and p.user_id = auth.uid())
  );

create policy "documents: owner full access" on documents
  for all using (
    exists (select 1 from projects p where p.id = documents.project_id and p.user_id = auth.uid())
  );
