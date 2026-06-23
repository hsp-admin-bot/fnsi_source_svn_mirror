-- sys_function

-- テーブル削除
DROP TABLE IF EXISTS sys_function;
-- テーブル作成
CREATE TABLE sys_function
(
    function_cd character varying(4) NOT NULL,  --機能コード
    function_name character varying(100),  --メニュー機能名
    is_disp character varying(1) DEFAULT '1',  --表示設定
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_function_01 PRIMARY KEY (function_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "sys_function" IS E'機能一覧';
COMMENT ON COLUMN "sys_function"."function_cd" IS E'機能コード';
COMMENT ON COLUMN "sys_function"."function_name" IS E'メニュー機能名';
COMMENT ON COLUMN "sys_function"."is_disp" IS E'表示設定';
COMMENT ON COLUMN "sys_function"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_function"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_function"."up_date" IS E'更新日時';

--初期データ登録
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('001', '遠隔監視', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('002', '生体モニタリング', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('003', 'デバイスエッジ稼働監視', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('004', '患者経過総合ビューア', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('005', 'マスタ一覧', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('006', '治療記録', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('007', '患者情報', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('008', 'マルチ患者一覧', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('009', 'スケジュール表', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('010', '装置設定', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('011', '治療状況リスト', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('012', '治療状況マップ', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('013', '体重計・条件送信', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('014', '体重計測定記録', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('015', 'チェックリスト', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('016', '観察記録', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('017', '新規患者登録', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('018', '検査結果', '1', '0', current_timestamp, current_timestamp);
insert into sys_function (function_cd, function_name, is_disp, is_del, reg_date, up_date) values ('019', '帳票', '1', '0', current_timestamp, current_timestamp);
