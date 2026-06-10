-- テーブル削除（チェックリストマスタ）
DROP TABLE IF EXISTS mst_checklist;
-- テーブル作成（チェックリストマスタ）
CREATE TABLE mst_checklist
(
    checklist_cd bigserial NOT NULL,  --システムで管理する一意なチェックリストコード
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd),  --登録施設コード
    checklist_settings jsonb,  --チェックリスト設定
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_checklist_01 PRIMARY KEY (checklist_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加（チェックリストマスタ）
COMMENT ON TABLE "mst_checklist" IS E'チェックリストマスタ';
COMMENT ON COLUMN "mst_checklist"."checklist_cd" IS E'システムで管理する一意なチェックリストコード';
COMMENT ON COLUMN "mst_checklist"."facility_cd" IS E'登録施設コード';
COMMENT ON COLUMN "mst_checklist"."checklist_settings" IS E'チェックリスト設定';
COMMENT ON COLUMN "mst_checklist"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_checklist"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_checklist"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_checklist"."up_date" IS E'更新日時';

-- テーブル削除（チェックリスト実績）
DROP TABLE IF EXISTS ord_checklist;
-- テーブル作成（チェックリスト実績）
CREATE TABLE ord_checklist
(
    checklist_ctl_no bigserial NOT NULL,  --システムで管理する一意なチェックリスト管理番号
    ord_no bigint,  --システムで管理する一意なオーダ番号
    is_check character varying(1) DEFAULT '0',  --実施状態
    rst_class smallint,  --実績区分
    list_cd smallint,  --リストコード
    func_class smallint,  --機能種別
    rst_checklist_info jsonb,  --チェックリスト項目情報
    reg_staff_info jsonb DEFAULT E'{"reg_staff_cd":null,"reg_staff_update":null}',  --実施者情報
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    occur_date timestamp(3),  --発生日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_ord_checklist_01 PRIMARY KEY (checklist_ctl_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加（チェックリスト実績）
COMMENT ON TABLE "ord_checklist" IS E'チェックリスト実績';
COMMENT ON COLUMN "ord_checklist"."checklist_ctl_no" IS E'システムで管理する一意なチェックリスト管理番号';
COMMENT ON COLUMN "ord_checklist"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "ord_checklist"."is_check" IS E'実施状態';
COMMENT ON COLUMN "ord_checklist"."rst_class" IS E'実績区分';
COMMENT ON COLUMN "ord_checklist"."list_cd" IS E'リストコード';
COMMENT ON COLUMN "ord_checklist"."func_class" IS E'機能種別';
COMMENT ON COLUMN "ord_checklist"."rst_checklist_info" IS E'チェックリスト項目情報';
COMMENT ON COLUMN "ord_checklist"."reg_staff_info" IS E'実施者情報';
COMMENT ON COLUMN "ord_checklist"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "ord_checklist"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_checklist"."occur_date" IS E'発生日時';
COMMENT ON COLUMN "ord_checklist"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_checklist"."up_date" IS E'更新日時';