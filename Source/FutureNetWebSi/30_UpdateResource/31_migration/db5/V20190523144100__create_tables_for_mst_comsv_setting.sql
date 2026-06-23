-- テーブル削除
DROP TABLE IF EXISTS mst_comsv_setting;
-- テーブル作成
CREATE TABLE mst_comsv_setting
(
    comsv_cd bigserial NOT NULL,  --通信サーバー管理コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    device_edge_no numeric(2,0) NOT NULL,  --デバイスエッジ番号
    is_timeset character varying(1) DEFAULT '0',  --新通信一斉時刻合わせ
    timeset_time character varying(4),  --新通信一斉時刻合わせ時刻
    is_timeset_nx character varying(1) DEFAULT '0',  --NX通信一斉時刻合わせ
    timeset_nx_time character varying(4),  --NX通信一斉時刻合わせ時刻
    lcd_log_time character varying(1) DEFAULT '0',  --仮想端末ログ時間
    lcd_log_type character varying(1) DEFAULT '0',  --仮想端末ログ内容
    is_lcd_medi character varying(1) DEFAULT '0',  --仮想端末投与時間帯表示
    end_wait_time smallint,  --排液判定待機時間
    pat_timing character varying(1),  --患者切り替えタイミング
    is_notice character varying(1),  --お知らせ機能
    notice_time smallint,  --お知らせ機能補正時間
    log_upload_time character varying(4),  --ログのアップロード実施時刻
    lcd_menu jsonb,  --仮想端末メニュー表示設定
    lcd_npat jsonb,  --次患者情報表示設定
    lcd_report jsonb,  --透析日報表示設定
    lcd_graph1 jsonb,  --検査１グラフ表示設定
    lcd_graph2 jsonb,  --検査２グラフ表示設定
    lcd_radar jsonb,  --検査レーダーチャート表示設定
    lcd_staff_list jsonb,  --仮想端末スタッフ一覧
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_comsv_setting_01 PRIMARY KEY (comsv_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_comsv_setting" IS E'通信サーバー設定';
COMMENT ON COLUMN "mst_comsv_setting"."comsv_cd" IS E'通信サーバー管理コード';
COMMENT ON COLUMN "mst_comsv_setting"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_comsv_setting"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mst_comsv_setting"."is_timeset" IS E'新通信一斉時刻合わせ';
COMMENT ON COLUMN "mst_comsv_setting"."timeset_time" IS E'新通信一斉時刻合わせ時刻';
COMMENT ON COLUMN "mst_comsv_setting"."is_timeset_nx" IS E'NX通信一斉時刻合わせ';
COMMENT ON COLUMN "mst_comsv_setting"."timeset_nx_time" IS E'NX通信一斉時刻合わせ時刻';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_log_time" IS E'仮想端末ログ時間';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_log_type" IS E'仮想端末ログ内容';
COMMENT ON COLUMN "mst_comsv_setting"."is_lcd_medi" IS E'仮想端末投与時間帯表示';
COMMENT ON COLUMN "mst_comsv_setting"."end_wait_time" IS E'排液判定待機時間';
COMMENT ON COLUMN "mst_comsv_setting"."pat_timing" IS E'患者切り替えタイミング';
COMMENT ON COLUMN "mst_comsv_setting"."is_notice" IS E'お知らせ機能';
COMMENT ON COLUMN "mst_comsv_setting"."notice_time" IS E'お知らせ機能補正時間';
COMMENT ON COLUMN "mst_comsv_setting"."log_upload_time" IS E'ログのアップロード実施時刻';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_menu" IS E'仮想端末メニュー表示設定';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_npat" IS E'次患者情報表示設定';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_report" IS E'透析日報表示設定';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_graph1" IS E'検査１グラフ表示設定';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_graph2" IS E'検査２グラフ表示設定';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_radar" IS E'検査レーダーチャート表示設定';
COMMENT ON COLUMN "mst_comsv_setting"."lcd_staff_list" IS E'仮想端末スタッフ一覧';
COMMENT ON COLUMN "mst_comsv_setting"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_comsv_setting"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_comsv_setting"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_comsv_setting"."up_date" IS E'更新日時';

-- sys_master_define
insert into sys_master_define
  (master_physical_name,master_name,disp_class,mode,allow_sort,allow_add_record,disp_order,column_info,combo_data,reg_date,up_date,reference_combo_def,edit_level)
  values
  ('mst_comsv_setting',
  '通信サーバーマスタ',
  '2','2','1','1',2000,
  '{"fields": [{"type": "number", "alias": "code", "title": "主キー", "physical_name": "comsv_cd"}, {"type": "modal", "title": "詳細"}, {"type": "combo1", "title": "デバイスエッジ", "validation": {"max": 99, "min": 1, "required": true}, "physical_name": "device_edge_no"}, {"type": "string", "title": "施設コード", "hidden": "true", "editable": "true", "physical_name": "facility_cd"}, {"type": "string", "title": "新通信一斉時刻合わせ", "hidden": "true", "editable": "true", "physical_name": "is_timeset"}, {"type": "string", "title": "新通信一斉時刻合わせ時刻", "hidden": "true", "editable": "true", "physical_name": "timeset_time"}, {"type": "string", "title": "NX新通信一斉時刻合わせ", "hidden": "true", "editable": "true", "physical_name": "is_timeset_nx"}, {"type": "string", "title": "NX新通信一斉時刻合わせ時刻", "hidden": "true", "editable": "true", "physical_name": "timeset_nx_time"}, {"type": "string", "title": "仮想端末ログ時間", "hidden": "true", "editable": "true", "physical_name": "lcd_log_time"}, {"type": "string", "title": "仮想端末ログ内容", "hidden": "true", "editable": "true", "physical_name": "lcd_log_type"}, {"type": "string", "title": "仮想端末投与時間帯表示", "hidden": "true", "editable": "true", "physical_name": "is_lcd_medi"}, {"type": "number", "title": "排液判定待機時間", "hidden": "true", "editable": "true", "physical_name": "end_wait_time"}, {"type": "string", "title": "患者切り替えタイミング", "hidden": "true", "editable": "true", "physical_name": "pat_timing"}, {"type": "string", "title": "お知らせ機能", "hidden": "true", "editable": "true", "physical_name": "is_notice"}, {"type": "number", "title": "お知らせ機能補正時間", "hidden": "true", "editable": "true", "physical_name": "notice_time"}, {"type": "string", "title": "ログのアップロード実施時刻", "hidden": "true", "editable": "true", "physical_name": "log_upload_time"}, {"type": "json", "title": "仮想端末メニュー表示設定", "hidden": "true", "editable": "true", "physical_name": "lcd_menu"}, {"type": "json", "title": "次患者情報表示設定", "hidden": "true", "editable": "true", "physical_name": "lcd_npat"}, {"type": "json", "title": "透析日報表示設定", "hidden": "true", "editable": "true", "physical_name": "lcd_report"}, {"type": "json", "title": "検査１グラフ表示設定", "hidden": "true", "editable": "true", "physical_name": "lcd_graph1"}, {"type": "json", "title": "検査２グラフ表示設定", "hidden": "true", "editable": "true", "physical_name": "lcd_graph2"}, {"type": "json", "title": "検査レーダーチャート表示設定", "hidden": "true", "editable": "true", "physical_name": "lcd_radar"}, {"type": "string", "title": "仮想端末スタッフ一覧", "hidden": "true", "editable": "true", "physical_name": "lcd_staff_list"}, {"type": "del", "title": "削除", "physical_name": "is_del"}, {"type": "disp", "title": "削除", "physical_name": "is_disp"}]}','{"combos": [{"values": [{"text": "DCS3(I)", "value": "I"}, {"text": "DBB3(J)", "value": "J"}, {"text": "DCG3(M)", "value": "M"}, {"text": "DBG3(N)", "value": "N"}, {"text": "DCG3(P)", "value": "P"}, {"text": "DBG3(Q)", "value": "Q"}, {"text": "DAB", "value": "A"}, {"text": "DAD", "value": "D"}, {"text": "DRO", "value": "R"}], "physical_name": "com_format_cd"}, {"values": [{"text": "なし", "value": "0"}, {"text": "あり", "value": "1"}], "physical_name": "is_ftp"}, {"values": [{"text": "新通信", "value": "1"}, {"text": "NX通信", "value": "2"}], "physical_name": "com_type"}, {"values": [{"text": "使用可能", "value": "0"}, {"text": "使用不可", "value": "1"}], "physical_name": "is_disable"}]}',
  now(),now(),null,'0');
