-- テーブル削除
DROP TABLE IF EXISTS "ntss".shr_pat_info;
DROP SEQUENCE IF EXISTS ntss.shr_pat_info_shr_pat_info_id_seq CASCADE;
CREATE SEQUENCE ntss.shr_pat_info_shr_pat_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- テーブル作成
CREATE TABLE "ntss"."shr_pat_info" (
  "shr_pat_info_id" int8 NOT NULL DEFAULT nextval('shr_pat_info_shr_pat_info_id_seq'::regclass),
  "from_facility_cd" varchar(8) COLLATE "pg_catalog"."default",
  "from_pat_id" int8,
  "to_facility_cd" varchar(8) COLLATE "pg_catalog"."default",
  "to_pat_id" int8,
  "share_direction" varchar(1) COLLATE "pg_catalog"."default",
  "is_from_consent" varchar(1) COLLATE "pg_catalog"."default",
  "from_user_id" int8,
  "is_to_consent" varchar(1) COLLATE "pg_catalog"."default",
  "to_user_id" int8,
  "is_pat_consent" varchar(1) COLLATE "pg_catalog"."default",
  "shr_attachment" jsonb,
  "reg_date" timestamp(3),
  "from_up_date" timestamp(3),
  "to_up_date" timestamp(3),
  "from_upd_user_id" int8,
  "to_upd_user_id" int8,
  "is_disp" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '1'::character varying,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  CONSTRAINT "shr_pat_info_pkey" PRIMARY KEY ("shr_pat_info_id")
)
;

-- コメント追加
COMMENT ON COLUMN "ntss"."shr_pat_info"."shr_pat_info_id" IS '管理番号';

COMMENT ON COLUMN "ntss"."shr_pat_info"."from_facility_cd" IS '共有元施設コード';

COMMENT ON COLUMN "ntss"."shr_pat_info"."from_pat_id" IS '共有元患者ID';

COMMENT ON COLUMN "ntss"."shr_pat_info"."to_facility_cd" IS '共有先施設コード';

COMMENT ON COLUMN "ntss"."shr_pat_info"."to_pat_id" IS '共有先患者ID';

COMMENT ON COLUMN "ntss"."shr_pat_info"."share_direction" IS '依頼方向';

COMMENT ON COLUMN "ntss"."shr_pat_info"."is_from_consent" IS '共有元合意フラグ';

COMMENT ON COLUMN "ntss"."shr_pat_info"."from_user_id" IS '共有元担当者';

COMMENT ON COLUMN "ntss"."shr_pat_info"."is_to_consent" IS '共有先合意フラグ';

COMMENT ON COLUMN "ntss"."shr_pat_info"."to_user_id" IS '共有先担当者';

COMMENT ON COLUMN "ntss"."shr_pat_info"."is_pat_consent" IS '患者合意フラグ';

COMMENT ON COLUMN "ntss"."shr_pat_info"."shr_attachment" IS '添付ファイル';

COMMENT ON COLUMN "ntss"."shr_pat_info"."reg_date" IS '登録日時';

COMMENT ON COLUMN "ntss"."shr_pat_info"."from_up_date" IS '共有元最終更新日時';

COMMENT ON COLUMN "ntss"."shr_pat_info"."to_up_date" IS '共有先最終更新日時';

COMMENT ON COLUMN "ntss"."shr_pat_info"."from_upd_user_id" IS '共有元施設最終更新者';

COMMENT ON COLUMN "ntss"."shr_pat_info"."to_upd_user_id" IS '共有先施設最終更新者';

COMMENT ON COLUMN "ntss"."shr_pat_info"."is_disp" IS '表示フラグ';

COMMENT ON COLUMN "ntss"."shr_pat_info"."is_del" IS '削除フラグ';

COMMENT ON TABLE "ntss"."shr_pat_info" IS '患者情報共有';

