-- 'archived' 상태 제거: 보관됨 로우는 완료(done) 처리된 것으로 간주해 이관한다.
update projects set status = 'done' where status = 'archived';

alter table projects drop constraint projects_status_check;
alter table projects add constraint projects_status_check check (status in ('active', 'done'));

-- 설정 화면에서 실제로 반영되는 값만 저장한다 (모바일 동기화/자동 저장 간격은 항상 켜져 있으므로 컬럼이 필요 없다).
alter table profiles add column notify_enabled boolean not null default true;
alter table profiles add column dark_editor boolean not null default false;
