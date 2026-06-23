CREATE TABLE "ntss"."pat_exam_main_hst" (
  "exam_main_cd" int8 NOT NULL,
  "pat_id" int8 NOT NULL,
  "facility_cd" varchar(6) COLLATE "pg_catalog"."default" NOT NULL,
  "ord_no" int8,
  "fn_pat_id" varchar(12) COLLATE "pg_catalog"."default",
  "reg_exam_date" timestamp(3) NOT NULL,
  "reg_order_class" varchar(1) COLLATE "pg_catalog"."default" NOT NULL,
  "exam_status" varchar(1) COLLATE "pg_catalog"."default",
  "order_comment" varchar(50) COLLATE "pg_catalog"."default",
  "order_exam_set_info" jsonb,
  "exam_order_info" jsonb,
  "order_label_info" jsonb,
  "data_gen_class" varchar(1) COLLATE "pg_catalog"."default",
  "result_exam_date" timestamp(3),
  "result_comment" varchar(50) COLLATE "pg_catalog"."default",
  "exam_result_info" jsonb,
  "cop_order_no1" int8,
  "cop_order_no2" int8,
  "is_lock" varchar(1) COLLATE "pg_catalog"."default",
  "ind_user_id" int8,
  "is_del" varchar(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying,
  "reg_date" timestamp(3),
  "reg_staff" int8,
  "up_date" timestamp(3),
  "up_staff" int8,
  "is_order" varchar(1) COLLATE "pg_catalog"."default",
  PRIMARY KEY ("exam_main_cd")
)
;

ALTER TABLE "ntss"."pat_exam_main_hst" 
  OWNER TO "nkk5";

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."exam_main_cd" IS 'システムで管理する一意な検査結果コード';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."pat_id" IS 'システムで管理する一意な患者ID';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."facility_cd" IS '施設コード';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."ord_no" IS 'オーダ番号';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."fn_pat_id" IS 'FNW+で管理する施設内の一意な患者ID';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."reg_exam_date" IS '登録時検査日時';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."reg_order_class" IS '登録時検査区分';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."exam_status" IS '状況区分';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."order_comment" IS '依頼時コメント';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."order_exam_set_info" IS '検査依頼セット情報';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."exam_order_info" IS '検査依頼情報';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."order_label_info" IS 'ラベル情報';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."data_gen_class" IS 'データ登録区分';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."result_exam_date" IS '結果時検査日時';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."result_comment" IS '結果時コメント';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."exam_result_info" IS '検査結果情報';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."cop_order_no1" IS '連携オーダ番号１';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."cop_order_no2" IS '連携オーダ番号２';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."is_lock" IS '依頼変更可否フラグ';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."ind_user_id" IS '指示者';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."is_del" IS '削除フラグ';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."reg_date" IS '登録日時';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."reg_staff" IS '登録スタッフ';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."up_date" IS '更新日時';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."up_staff" IS '最終更新スタッフ';

COMMENT ON COLUMN "ntss"."pat_exam_main_hst"."is_order" IS '検査依頼登録フラグ';

COMMENT ON TABLE "ntss"."pat_exam_main_hst" IS '患者検査結果';
