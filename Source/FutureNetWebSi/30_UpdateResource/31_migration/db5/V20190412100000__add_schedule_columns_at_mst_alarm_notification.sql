-- 警報通知マスタにスケジュールの列を追加
ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_mon character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_mon character varying(5),
  ADD COLUMN end_time_mon character varying(5),
  ADD COLUMN is_next_day_mon character varying(1) NOT NULL DEFAULT '0';

ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_tue character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_tue character varying(5),
  ADD COLUMN end_time_tue character varying(5),
  ADD COLUMN is_next_day_tue character varying(1) NOT NULL DEFAULT '0';

ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_wed character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_wed character varying(5),
  ADD COLUMN end_time_wed character varying(5),
  ADD COLUMN is_next_day_wed character varying(1) NOT NULL DEFAULT '0';

ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_thu character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_thu character varying(5),
  ADD COLUMN end_time_thu character varying(5),
  ADD COLUMN is_next_day_thu character varying(1) NOT NULL DEFAULT '0';

ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_fri character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_fri character varying(5),
  ADD COLUMN end_time_fri character varying(5),
  ADD COLUMN is_next_day_fri character varying(1) NOT NULL DEFAULT '0';

ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_sat character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_sat character varying(5),
  ADD COLUMN end_time_sat character varying(5),
  ADD COLUMN is_next_day_sat character varying(1) NOT NULL DEFAULT '0';

ALTER TABLE
  mst_alarm_notification
  ADD COLUMN is_notice_sun character varying(1) NOT NULL DEFAULT '1',
  ADD COLUMN start_time_sun character varying(5),
  ADD COLUMN end_time_sun character varying(5),
  ADD COLUMN is_next_day_sun character varying(1) NOT NULL DEFAULT '0';

-- コメント修正
COMMENT ON COLUMN "mst_alarm_notification"."is_notice_mon" IS E'通知フラグ(月)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_mon" IS E'開始時間(月)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_mon" IS E'終了時間(月)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_mon" IS E'翌日フラグ(月)';

COMMENT ON COLUMN "mst_alarm_notification"."is_notice_tue" IS E'通知フラグ(火)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_tue" IS E'開始時間(火)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_tue" IS E'終了時間(火)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_tue" IS E'翌日フラグ(火)';

COMMENT ON COLUMN "mst_alarm_notification"."is_notice_wed" IS E'通知フラグ(水)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_wed" IS E'開始時間(水)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_wed" IS E'終了時間(水)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_wed" IS E'翌日フラグ(水)';

COMMENT ON COLUMN "mst_alarm_notification"."is_notice_thu" IS E'通知フラグ(木)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_thu" IS E'開始時間(木)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_thu" IS E'終了時間(木)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_thu" IS E'翌日フラグ(木)';

COMMENT ON COLUMN "mst_alarm_notification"."is_notice_fri" IS E'通知フラグ(金)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_fri" IS E'開始時間(金)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_fri" IS E'終了時間(金)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_fri" IS E'翌日フラグ(金)';

COMMENT ON COLUMN "mst_alarm_notification"."is_notice_sat" IS E'通知フラグ(土)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_sat" IS E'開始時間(土)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_sat" IS E'終了時間(土)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_sat" IS E'翌日フラグ(土)';

COMMENT ON COLUMN "mst_alarm_notification"."is_notice_sun" IS E'通知フラグ(日)';
COMMENT ON COLUMN "mst_alarm_notification"."start_time_sun" IS E'開始時間(日)';
COMMENT ON COLUMN "mst_alarm_notification"."end_time_sun" IS E'終了時間(日)';
COMMENT ON COLUMN "mst_alarm_notification"."is_next_day_sun" IS E'翌日フラグ(日)';
