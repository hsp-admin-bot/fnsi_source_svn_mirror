DROP TABLE IF EXISTS mst_coop_layout_tmp;
create table mst_coop_layout_tmp (like mst_coop_layout);
alter table mst_coop_layout_tmp add column coop_cd_index varchar;

--- backup to mst_coop_layout_tmp
insert into mst_coop_layout_tmp
(
  ctl_no
  ,facility_cd
  ,coop_cd
  ,coop_cd_index
  ,direction
  ,coop_cd_sub 
  ,coop_format 
  ,coop_name
  ,coop_vender
  ,description
  ,is_editable
  ,coop_setting
  ,coop_ext_setting
  ,is_disp 
  ,is_del 
  ,user_id 
  ,reg_date
  ,up_date

)
select 
  ctl_no
  ,facility_cd
  ,coop_cd
  ,''
  ,direction
  ,coop_cd_sub 
  ,coop_format 
  ,coop_name
  ,coop_vender
  ,description
  ,is_editable
  ,coop_setting
  ,coop_ext_setting
  ,is_disp 
  ,is_del 
  ,user_id 
  ,reg_date
  ,up_date
from
    mst_coop_layout;
	
DROP TABLE IF EXISTS mst_coop_layout;
-- テーブル作成
-- テーブル削除
DROP TABLE IF EXISTS mst_coop_layout;
-- テーブル作成
CREATE TABLE mst_coop_layout
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_cd character varying(20) NOT NULL,  --電文種別
    coop_cd_index character varying(10) NOT NULL,  --付帯情報（電文）
    direction character varying(1) NOT NULL,  --向き（送受信）
    coop_cd_sub character varying NOT NULL,  --電文種別補足コード
    coop_format character varying,  --電文フォーマット
    coop_name character varying,  --レイアウト名称
    coop_vender character varying,  --対応ベンダー名
    description character varying,  --説明
    is_editable character varying(1),  --編集可否フラグ
    coop_setting XML,  --連携設定
    coop_ext_setting jsonb,  --拡張設定
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_layout_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_coop_layout" IS E'連携電文設定マスタ';
COMMENT ON COLUMN "mst_coop_layout"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_layout"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_layout"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "mst_coop_layout"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_layout"."coop_cd_sub" IS E'電文種別補足コード';
COMMENT ON COLUMN "mst_coop_layout"."coop_format" IS E'電文フォーマット';
COMMENT ON COLUMN "mst_coop_layout"."coop_name" IS E'レイアウト名称';
COMMENT ON COLUMN "mst_coop_layout"."coop_vender" IS E'対応ベンダー名';
COMMENT ON COLUMN "mst_coop_layout"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_layout"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_coop_layout"."coop_setting" IS E'連携設定';
COMMENT ON COLUMN "mst_coop_layout"."coop_ext_setting" IS E'拡張設定';
COMMENT ON COLUMN "mst_coop_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_layout"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_layout"."up_date" IS E'更新日時';



--- write back to mst_coop_layout
insert into mst_coop_layout
(
  ctl_no
  ,facility_cd
  ,coop_cd
  ,coop_cd_index
  ,direction
  ,coop_cd_sub 
  ,coop_format 
  ,coop_name
  ,coop_vender
  ,description
  ,is_editable
  ,coop_setting
  ,coop_ext_setting
  ,is_disp
  ,is_del
  ,user_id
  ,reg_date
  ,up_date
) select
  ctl_no
  ,facility_cd
  ,coop_cd
  ,coop_cd_index
  ,direction
  ,coop_cd_sub 
  ,coop_format 
  ,coop_name
  ,coop_vender
  ,description
  ,is_editable
  ,coop_setting
  ,coop_ext_setting
  ,is_disp
  ,is_del
  ,user_id
  ,reg_date
  ,up_date
from
    mst_coop_layout_tmp;

--- seqの調整
select setval('mst_coop_layout_ctl_no_seq', (select max(ctl_no) from mst_coop_layout) + 1, false);

--- delete temp tabl
drop table mst_coop_layout_tmp;