DROP TABLE IF EXISTS sys_coop_journal_tmp;
create table sys_coop_journal_tmp (like sys_coop_journal);

--- backup to sys_coop_journal_tmp
insert into sys_coop_journal_tmp
(
  ctl_no
  ,facility_cd
  ,coop_cd
  ,coop_cd_index
  ,crud
  ,direction
  ,ord_no
  ,coop_ord_no
  ,hosp_pat_id
  ,pat_id
  ,accept_no
  ,ana_result
  ,in_ana_date
  ,out_ana_date
  ,coop_result
  ,in_reg_date
  ,out_reg_date
  ,dump_path
  ,dump
  ,is_editable
  ,is_del
  ,user_id
  ,reg_date
  ,up_date
)
select 
    ctl_no
    ,facility_cd
    ,coop_cd
    ,coop_cd_index
    ,crud
    ,direction
    ,ord_no
    ,coop_ord_no
    ,hosp_pat_id
    ,pat_id
    ,accept_no
    ,ana_result
    ,in_ana_date
    ,out_ana_date
    ,coop_result
    ,in_reg_date
    ,out_reg_date
    ,dump_path
    ,dump
    ,is_editable
    ,is_del
    ,user_id
    ,reg_date
    ,up_date
from
    sys_coop_journal;

--- is_editableでnullのレコードがあるかも
update
  sys_coop_journal_tmp
set
  is_editable = '1'
where
  is_editable is null;

--- sys_coop_journalのremake
-- テーブル削除
DROP TABLE IF EXISTS sys_coop_journal;
-- テーブル作成
CREATE TABLE sys_coop_journal
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_cd character varying(20) NOT NULL,  --電文種別
    coop_cd_index character varying(10) NOT NULL DEFAULT '',  --付帯情報（電文）
    crud character varying(1) NOT NULL,  --作成更新区分
    direction character varying(1) NOT NULL,  --向き（送受信）
    ord_no bigint,  --（次世代FN)オーダ番号
    coop_ord_no character varying,  --（連携先)オーダ番号
    hosp_pat_id character varying(12),  --患者番号（連携用）
    pat_id bigint,  --患者番号（システム）
    accept_no bigint,  --受付番号
    ana_result character varying(2) NOT NULL DEFAULT '0',  --変換処理ステータス
    in_ana_date timestamp(3),  --変換処理開始日時
    out_ana_date timestamp(3),  --変換処理完了日時
    coop_result character varying(2) NOT NULL DEFAULT '0',  --配信処理ステータス
    in_reg_date timestamp(3),  --配信処理開始日時
    out_reg_date timestamp(3),  --配信処理完了日時
    message character varying,  --メッセージ
    dump_path character varying,  --電文パス
    dump bytea,  --電文内容
    is_editable character varying(1) NOT NULL DEFAULT '1',  --編集可否フラグ
    is_del character varying(1) NOT NULL DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_coop_journal_01 PRIMARY KEY (ctl_no)
)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "sys_coop_journal" IS E'外部連携用ジャーナル';
COMMENT ON COLUMN "sys_coop_journal"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_coop_journal"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_coop_journal"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "sys_coop_journal"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "sys_coop_journal"."crud" IS E'作成更新区分';
COMMENT ON COLUMN "sys_coop_journal"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "sys_coop_journal"."ord_no" IS E'（次世代FN)オーダ番号';
COMMENT ON COLUMN "sys_coop_journal"."coop_ord_no" IS E'（連携先)オーダ番号';
COMMENT ON COLUMN "sys_coop_journal"."hosp_pat_id" IS E'患者番号（連携用）';
COMMENT ON COLUMN "sys_coop_journal"."pat_id" IS E'患者番号（システム）';
COMMENT ON COLUMN "sys_coop_journal"."accept_no" IS E'受付番号';
COMMENT ON COLUMN "sys_coop_journal"."ana_result" IS E'変換処理ステータス';
COMMENT ON COLUMN "sys_coop_journal"."in_ana_date" IS E'変換処理開始日時';
COMMENT ON COLUMN "sys_coop_journal"."out_ana_date" IS E'変換処理完了日時';
COMMENT ON COLUMN "sys_coop_journal"."coop_result" IS E'配信処理ステータス';
COMMENT ON COLUMN "sys_coop_journal"."in_reg_date" IS E'配信処理開始日時';
COMMENT ON COLUMN "sys_coop_journal"."out_reg_date" IS E'配信処理完了日時';
COMMENT ON COLUMN "sys_coop_journal"."message" IS E'メッセージ';
COMMENT ON COLUMN "sys_coop_journal"."dump_path" IS E'電文パス';
COMMENT ON COLUMN "sys_coop_journal"."dump" IS E'電文内容';
COMMENT ON COLUMN "sys_coop_journal"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "sys_coop_journal"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_coop_journal"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "sys_coop_journal"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_coop_journal"."up_date" IS E'更新日時';


--- write back to sys_coop_journal
insert into sys_coop_journal
(
    ctl_no
    ,facility_cd
    ,coop_cd
    ,coop_cd_index
    ,crud
    ,direction
    ,ord_no
    ,coop_ord_no
    ,hosp_pat_id
    ,pat_id
    ,accept_no
    ,ana_result
    ,in_ana_date
    ,out_ana_date
    ,coop_result
    ,in_reg_date
    ,out_reg_date
    ,message
    ,dump_path
    ,dump
    ,is_editable
    ,is_del
    ,user_id
    ,reg_date
    ,up_date

) select
    ctl_no
    ,facility_cd
    ,coop_cd
    ,coop_cd_index
    ,crud
    ,direction
    ,ord_no
    ,coop_ord_no
    ,hosp_pat_id
    ,pat_id
    ,accept_no
    ,ana_result
    ,in_ana_date
    ,out_ana_date
    ,coop_result
    ,in_reg_date
    ,out_reg_date
    ,null
    ,dump_path
    ,dump
    ,is_editable
    ,is_del
    ,user_id
    ,reg_date
    ,up_date
from
    sys_coop_journal_tmp;

--- seqの調整
select setval('sys_coop_journal_ctl_no_seq', (select max(ctl_no) from sys_coop_journal) + 1, false);

drop table sys_coop_journal_tmp;
