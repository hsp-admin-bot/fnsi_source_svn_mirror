ALTER TABLE
  mnt_websocket_certification
ADD COLUMN
  up_date timestamp(3)
;
COMMENT ON COLUMN "mnt_websocket_certification"."up_date" IS E'更新日時';
