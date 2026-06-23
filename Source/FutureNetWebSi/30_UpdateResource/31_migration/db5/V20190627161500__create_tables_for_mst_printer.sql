-- テーブル削除
DROP TABLE IF EXISTS mst_printer;
-- テーブル作成
CREATE TABLE mst_printer
(
  printer_cd bigserial NOT NULL, -- プリンターCD
  facility_cd character varying(6) NOT NULL, -- 施設コード
  client_key character varying(256), -- クライアント識別子
  printer_name character varying(256), -- プリンタ名
  disp_printer_name character varying(256),  --表示プリンタ名
  is_disp character varying(1) DEFAULT '1'::character varying, -- 表示フラグ
  is_del character varying(1) DEFAULT '0'::character varying, -- 削除フラグ
  reg_date timestamp(3) without time zone, -- 登録日時
  up_date timestamp(3) without time zone, -- 更新日時
  CONSTRAINT unq_mst_printer_01 PRIMARY KEY (printer_cd),
  CONSTRAINT mst_printer_facility_cd_fkey FOREIGN KEY (facility_cd)
      REFERENCES mst_facility (facility_cd) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
COMMENT ON TABLE mst_printer
  IS 'プリンターマスタ';
COMMENT ON COLUMN mst_printer.printer_cd IS 'プリンターCD';
COMMENT ON COLUMN mst_printer.facility_cd IS '施設コード';
COMMENT ON COLUMN mst_printer.client_key IS 'クライアント識別子';
COMMENT ON COLUMN mst_printer.printer_name IS 'プリンタ名';
COMMENT ON COLUMN mst_printer.disp_printer_name IS E'表示プリンタ名';
COMMENT ON COLUMN mst_printer.is_disp IS '表示フラグ';
COMMENT ON COLUMN mst_printer.is_del IS '削除フラグ';
COMMENT ON COLUMN mst_printer.reg_date IS '登録日時';
COMMENT ON COLUMN mst_printer.up_date IS '更新日時';
