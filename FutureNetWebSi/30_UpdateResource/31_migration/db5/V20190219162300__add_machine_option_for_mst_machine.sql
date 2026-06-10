ALTER TABLE
  mst_machine
ADD COLUMN setting_date timestamp(3)
,ADD COLUMN delete_date timestamp(3)
,ADD COLUMN "version" character varying(20)
,ADD COLUMN machine_option jsonb
,ADD COLUMN memo character varying(256)
,ADD COLUMN is_disable character varying(1)
,ADD COLUMN support_mode jsonb
,ADD COLUMN tmp_center jsonb
;
COMMENT ON COLUMN "mst_machine"."setting_date" IS E'設置日';
COMMENT ON COLUMN "mst_machine"."delete_date" IS E'廃棄日';
COMMENT ON COLUMN "mst_machine"."version" IS E'バージョン';
COMMENT ON COLUMN "mst_machine"."machine_option" IS E'装置オプション';
COMMENT ON COLUMN "mst_machine"."memo" IS E'メモ';
COMMENT ON COLUMN "mst_machine"."is_disable" IS E'使用不可フラグ';
COMMENT ON COLUMN "mst_machine"."support_mode" IS E'モード';
COMMENT ON COLUMN "mst_machine"."tmp_center" IS E'TMP初期補正中点';


