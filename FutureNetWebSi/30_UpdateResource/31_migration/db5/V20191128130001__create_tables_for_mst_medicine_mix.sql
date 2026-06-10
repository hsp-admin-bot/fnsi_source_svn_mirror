-- テーブル削除
DROP TABLE IF EXISTS mst_medicine_mix;

-- テーブル作成
CREATE TABLE mst_medicine_mix
(
medicine_mix_cd serial NOT NULL,  --調整薬剤コード
facility_cd character varying(6),  --施設コード
fn_set_medicine_cd character varying(10),  --FNW+で管理する施設内の一意なセット薬剤名称コード
medicine_mix_name character varying,  --調整薬剤名
medicine_mix_short_name character varying,  --省略調整薬剤名
class_cd integer,  --薬剤分類コード
unit character varying,  --指示単位
amount_unit integer,  --指示単位基準量
amount_ml integer,  --ml単位基準量
mix_info jsonb,  --調整薬剤情報
is_shot character varying(1),  --注射
is_medicated character varying(1),  --投薬実施フラグ
use_start_date character varying(8),  --使用開始日
use_end_date character varying(8),  --使用終了日
in_hospital_cd_1 character varying(20),  --院内コード１
in_hospital_cd_2 character varying(20),  --院内コード２
in_hospital_cd_3 character varying(20),  --院内コード３
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_medicine_mix_01 PRIMARY KEY (medicine_mix_cd)
);

-- コメント追加
COMMENT ON TABLE "mst_medicine_mix" IS E'調整薬剤マスタ';
COMMENT ON COLUMN "mst_medicine_mix"."medicine_mix_cd" IS E'調整薬剤コード';
COMMENT ON COLUMN "mst_medicine_mix"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicine_mix"."fn_set_medicine_cd" IS E'FNW+で管理する施設内の一意なセット薬剤名称コード';
COMMENT ON COLUMN "mst_medicine_mix"."medicine_mix_name" IS E'調整薬剤名';
COMMENT ON COLUMN "mst_medicine_mix"."medicine_mix_short_name" IS E'省略調整薬剤名';
COMMENT ON COLUMN "mst_medicine_mix"."class_cd" IS E'薬剤分類コード';
COMMENT ON COLUMN "mst_medicine_mix"."unit" IS E'指示単位';
COMMENT ON COLUMN "mst_medicine_mix"."amount_unit" IS E'指示単位基準量';
COMMENT ON COLUMN "mst_medicine_mix"."amount_ml" IS E'ml単位基準量';
COMMENT ON COLUMN "mst_medicine_mix"."mix_info" IS E'調整薬剤情報';
COMMENT ON COLUMN "mst_medicine_mix"."is_shot" IS E'注射';
COMMENT ON COLUMN "mst_medicine_mix"."is_medicated" IS E'投薬実施フラグ';
COMMENT ON COLUMN "mst_medicine_mix"."use_start_date" IS E'使用開始日';
COMMENT ON COLUMN "mst_medicine_mix"."use_end_date" IS E'使用終了日';
COMMENT ON COLUMN "mst_medicine_mix"."in_hospital_cd_1" IS E'院内コード１';
COMMENT ON COLUMN "mst_medicine_mix"."in_hospital_cd_2" IS E'院内コード２';
COMMENT ON COLUMN "mst_medicine_mix"."in_hospital_cd_3" IS E'院内コード３';
COMMENT ON COLUMN "mst_medicine_mix"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicine_mix"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicine_mix"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicine_mix"."up_date" IS E'更新日時';

