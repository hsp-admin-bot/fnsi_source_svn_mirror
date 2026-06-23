-- 新しい列を追加する
ALTER TABLE pat_event
  ADD COLUMN event_start_time character varying(4),
  ADD COLUMN event_end_time character varying(4);

COMMENT ON COLUMN "pat_event"."event_start_time" IS E'イベント開始時刻';
COMMENT ON COLUMN "pat_event"."event_end_time" IS E'イベント終了時刻';
-- 名前を変える
ALTER TABLE pat_event RENAME COLUMN event_date TO event_start_date;

COMMENT ON COLUMN "pat_event"."event_start_date" IS E'イベント開始日';
COMMENT ON COLUMN "pat_event"."event_end_date" IS E'イベント終了日';
-- タイプを変更
ALTER TABLE pat_event ALTER COLUMN event_start_date TYPE character varying(19);
ALTER TABLE pat_event ALTER COLUMN event_end_date TYPE character varying(19);
-- データを変換する
UPDATE pat_event SET event_start_time = replace(substring(event_start_date, 12, 5), ':', '')
WHERE event_start_date IS NOT NULL;

UPDATE pat_event SET event_end_time = replace(substring(event_end_date, 12, 5), ':', '')
WHERE event_end_date IS NOT NULL;

UPDATE pat_event SET event_start_date = replace(substring(event_start_date, 1, 10), '-', '')
WHERE event_start_date IS NOT NULL;

UPDATE pat_event SET event_end_date = replace(substring(event_end_date, 1, 10), '-', '')
WHERE event_end_date IS NOT NULL;
-- タイプをもう一度変更
ALTER TABLE pat_event ALTER COLUMN event_start_date TYPE character varying(8);
ALTER TABLE pat_event ALTER COLUMN event_end_date TYPE character varying(8);