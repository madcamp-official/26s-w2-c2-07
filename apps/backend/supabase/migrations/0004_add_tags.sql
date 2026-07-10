-- tags: 사용자가 만드는 글감 분류 태그
create table tags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  color text,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

create index tags_user_id_idx on tags (user_id);

-- capture_tags: 글감 <-> 태그 다대다 연결
create table capture_tags (
  capture_id uuid not null references captures (id) on delete cascade,
  tag_id uuid not null references tags (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (capture_id, tag_id)
);

create index capture_tags_tag_id_idx on capture_tags (tag_id);

alter table tags enable row level security;
alter table capture_tags enable row level security;

create policy "tags: owner full access" on tags
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "capture_tags: owner full access" on capture_tags
  for all using (
    exists (select 1 from captures c where c.id = capture_tags.capture_id and c.user_id = auth.uid())
  );
