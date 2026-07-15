-- notifications: 글감이 등록될 때(모바일/웹) 생성되는 알림 피드
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  source text not null check (source in ('mobile', 'web')),
  title text not null,
  detail text,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index notifications_user_id_created_at_idx on notifications (user_id, created_at desc);

alter table notifications enable row level security;

create policy "notifications: owner full access" on notifications
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
