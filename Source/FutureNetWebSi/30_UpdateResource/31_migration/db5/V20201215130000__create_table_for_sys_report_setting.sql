-- Drop table

-- DROP TABLE ntss.sys_report_setting;

CREATE TABLE ntss.sys_report_setting (
	function_cd varchar NOT NULL, -- 機能コード
	function_name varchar(100) NULL, -- 機能名
	print_report_class json NULL, -- 機能帳票種別設定
	is_disp varchar(1) NULL DEFAULT '1'::character varying, -- 表示フラグ
	is_del varchar(1) NULL DEFAULT '0'::character varying, -- 削除フラグ
	reg_date timestamp NULL, -- 登録日時
	up_date timestamp NULL, -- 更新日時
	report_setting_no int4 NULL, -- 機能コードデジタル
	CONSTRAINT unq_sys_report_setting_01 PRIMARY KEY (function_cd)
);

-- Column comments

COMMENT ON COLUMN ntss.sys_report_setting.function_cd IS '機能コード';
COMMENT ON COLUMN ntss.sys_report_setting.function_name IS '機能名';
COMMENT ON COLUMN ntss.sys_report_setting.print_report_class IS '機能帳票種別設定';
COMMENT ON COLUMN ntss.sys_report_setting.is_disp IS '表示フラグ';
COMMENT ON COLUMN ntss.sys_report_setting.is_del IS '削除フラグ';
COMMENT ON COLUMN ntss.sys_report_setting.reg_date IS '登録日時';
COMMENT ON COLUMN ntss.sys_report_setting.up_date IS '更新日時';
COMMENT ON COLUMN ntss.sys_report_setting.report_setting_no IS '機能コードデジタル';

-- Permissions

ALTER TABLE ntss.sys_report_setting OWNER TO nkk5;
GRANT ALL ON TABLE ntss.sys_report_setting TO nkk5;
