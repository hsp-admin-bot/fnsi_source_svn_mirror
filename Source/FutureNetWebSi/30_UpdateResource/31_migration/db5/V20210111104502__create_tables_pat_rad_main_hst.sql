CREATE TABLE "ntss"."pat_rad_main_hst" (
  "rad_result_cd" int8 NOT NULL,
  "pat_id" int8 NOT NULL,
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default" NOT NULL,
  "fn_pat_id" varchar(12) COLLATE "pg_catalog"."default",
  "reg_rad_date" timestamp(3) NOT NULL,
  "reg_order_class" varchar(1) COLLATE "pg_catalog"."default" NOT NULL DEFAULT '3'::character varying,
  "rad_status" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "order_rad_set_info" jsonb,
  "cop_order_no1" int8,
  "cop_order_no2" int8,
  "is_lock" varchar(1) COLLATE "pg_catalog"."default",
  "ind_user_id" int8,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "reg_date" timestamp(3),
  "reg_staff" int8,
  "up_date" timestamp(3),
  "up_staff" int8,
  PRIMARY KEY ("rad_result_cd")
)
;

ALTER TABLE "ntss"."pat_rad_main_hst" 
  OWNER TO "nkk5";

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."rad_result_cd" IS 'システムで管理する一意な放射線検査結果コード';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."pat_id" IS 'システムで管理する一意な患者ID';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."facility_cd" IS '施設コード';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."fn_pat_id" IS 'FNW+で管理する施設内の一意な患者ID';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."reg_rad_date" IS '登録時放射線検査日時';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."reg_order_class" IS '登録時放射線検査区分';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."rad_status" IS '状況区分';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."order_rad_set_info" IS '放射線検査依頼セット情報';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."cop_order_no1" IS '連携オーダ番号１';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."cop_order_no2" IS '連携オーダ番号２';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."is_lock" IS '依頼変更可否フラグ';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."ind_user_id" IS '指示者';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."is_del" IS '削除フラグ';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."reg_date" IS '登録日時';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."reg_staff" IS '登録スタッフ';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."up_date" IS '更新日時';

COMMENT ON COLUMN "ntss"."pat_rad_main_hst"."up_staff" IS '最終更新スタッフ';

COMMENT ON TABLE "ntss"."pat_rad_main_hst" IS '患者放射線検査DB';