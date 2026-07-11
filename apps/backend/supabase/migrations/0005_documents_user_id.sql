-- documents에 user_id를 비정규화해서 저장한다.
-- 기존에는 documents를 읽고/쓸 때마다 projects를 먼저 조회해 소유권을 확인하는
-- 왕복이 매번 추가로 발생했다 (특히 에디터 자동 저장처럼 자주 호출되는 경로에서 체감 지연이 컸다).
-- user_id를 직접 들고 있으면 project_id + user_id + id 필터 하나로 소유권 확인과
-- 조회/수정/삭제를 한 번의 쿼리로 끝낼 수 있다.
alter table documents add column user_id uuid references auth.users (id) on delete cascade;

update documents d
set user_id = p.user_id
from projects p
where d.project_id = p.id;

alter table documents alter column user_id set not null;

create index documents_user_id_idx on documents (user_id);

drop policy "documents: owner full access" on documents;
create policy "documents: owner full access" on documents
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
