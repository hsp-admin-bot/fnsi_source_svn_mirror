-- テーブル削除(名寄せ)
DROP TABLE IF EXISTS pat_name_identification;
-- テーブル作成(名寄せ)
CREATE TABLE pat_name_identification
(
    pat_name_id bigserial NOT NULL primary key, --名寄せID
    pat_id_src bigint, --患者IDソース
    facility_cd_src character varying(6) NOT NULL, --施設IDソース
    pat_id_dst bigint, --患者IDの宛先
    facility_cd_dst character varying(6) NOT NULL, --施設コード宛先
	approve character varying(1), --承認
	receive character varying(1), --受理
	is_open character varying(1), --開示
	sign_up character varying(1), --登録
	doctor_in_charge character varying(256), --担当医
	approve_date timestamp(3), --承認日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3)  --更新日時
);
-- コメント追加(掲示板種別マスタ)
COMMENT ON TABLE "pat_name_identification" IS E'名寄せ';
COMMENT ON COLUMN "pat_name_identification"."pat_name_id" IS E'名寄せID';
COMMENT ON COLUMN "pat_name_identification"."pat_id_src" IS E'ソース患者ID';
COMMENT ON COLUMN "pat_name_identification"."facility_cd_src" IS E'ソース施設コード';
COMMENT ON COLUMN "pat_name_identification"."pat_id_dst" IS E'ターゲット患者ID';
COMMENT ON COLUMN "pat_name_identification"."facility_cd_dst" IS E'ターゲット施設コード';
COMMENT ON COLUMN "pat_name_identification"."approve" IS E'承認フラグ';
COMMENT ON COLUMN "pat_name_identification"."receive" IS E'受理フラグ';
COMMENT ON COLUMN "pat_name_identification"."is_open" IS E'開示フラグ';
COMMENT ON COLUMN "pat_name_identification"."sign_up" IS E'登録フラグ';
COMMENT ON COLUMN "pat_name_identification"."doctor_in_charge" IS E'担当医';
COMMENT ON COLUMN "pat_name_identification"."approve_date" IS E'承認日時';
COMMENT ON COLUMN "pat_name_identification"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_name_identification"."up_date" IS E'更新日時';
