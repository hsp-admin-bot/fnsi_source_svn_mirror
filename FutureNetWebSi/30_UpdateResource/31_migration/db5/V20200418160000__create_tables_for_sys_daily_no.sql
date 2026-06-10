-- テーブル削除
DROP TABLE IF EXISTS sys_daily_no;

-- テーブル作成
CREATE TABLE sys_daily_no
(
	ctl_no bigserial NOT NULL,  -- 管理番号
	facility_cd character varying(6) NOT NULL, -- 施設コード
	numbering_cd character varying(20), -- 採番種別
	current_no jsonb, -- 現在の採番値
	is_disp character varying(1) DEFAULT '1', -- 表示フラグ
	is_del character varying(1) DEFAULT '0', -- 削除フラグ
	up_date timestamp(3),  --更新日時
	reg_date timestamp(3),  --登録日時
	CONSTRAINT unq_sys_daitly_number_01 PRIMARY KEY (ctl_no)
)
WITH (
    OIDS=FALSE
);

-- コメント
COMMENT ON TABLE "sys_daily_no" IS E'受付番号採番';
COMMENT ON COLUMN "sys_daily_no"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_daily_no"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_daily_no"."numbering_cd" IS E'採番種別';
COMMENT ON COLUMN "sys_daily_no"."current_no" IS E'現在の採番値';
COMMENT ON COLUMN "sys_daily_no"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_daily_no"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_daily_no"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sys_daily_no"."reg_date" IS E'登録日時';
