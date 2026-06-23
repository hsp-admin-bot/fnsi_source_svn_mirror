-- 剤出力パターンマスタ
DROP TABLE IF EXISTS mst_zai_output_pattern;

CREATE TABLE mst_zai_output_pattern (
  facility_cd character varying(6) NOT NULL
  , pattern_cd numeric(3) NOT NULL
  , pattern_name character varying(100)
  , recept_cd character varying(6)
  , is_close character varying(1) DEFAULT '0'
  , is_individual character varying(1) DEFAULT '0'
  , start_recept_cd character varying(6)
  , start_comment character varying(40)
  , end_recept_cd character varying(6)
  , end_comment character varying(40)
  , rezept_type numeric(2)
  , claim_section_disp character varying(4)
  , claim_section_name character varying(64)
  , is_enabled character varying(1) DEFAULT '0'
  , disp_order numeric(3)
  , is_del character varying(1) DEFAULT '0'
  , reg_date timestamp(3) without time zone
  , up_date timestamp(3) without time zone
  , CONSTRAINT pk_mst_zai_output_pattern PRIMARY KEY (facility_cd, pattern_cd)
) ;

COMMENT ON TABLE mst_zai_output_pattern IS '剤出力パターンマスタ';
COMMENT ON COLUMN mst_zai_output_pattern.facility_cd IS '施設コード';
COMMENT ON COLUMN mst_zai_output_pattern.pattern_cd IS '剤出力パターンコード';
COMMENT ON COLUMN mst_zai_output_pattern.pattern_name IS '剤出力パターン名称';
COMMENT ON COLUMN mst_zai_output_pattern.recept_cd IS '医事コード';
COMMENT ON COLUMN mst_zai_output_pattern.is_close IS '剤閉じフラグ';
COMMENT ON COLUMN mst_zai_output_pattern.is_individual IS '個別剤フラグ';
COMMENT ON COLUMN mst_zai_output_pattern.start_recept_cd IS '開始：医事コード';
COMMENT ON COLUMN mst_zai_output_pattern.start_comment IS '開始：コメント';
COMMENT ON COLUMN mst_zai_output_pattern.end_recept_cd IS '終了：医事コード';
COMMENT ON COLUMN mst_zai_output_pattern.end_comment IS '終了：コメント';
COMMENT ON COLUMN mst_zai_output_pattern.rezept_type IS 'レセプト診区';
COMMENT ON COLUMN mst_zai_output_pattern.claim_section_disp IS 'レセプト表示診区名';
COMMENT ON COLUMN mst_zai_output_pattern.claim_section_name IS 'レセプト診区名';
COMMENT ON COLUMN mst_zai_output_pattern.is_enabled IS '有効フラグ（0：有効、1：無効）';
COMMENT ON COLUMN mst_zai_output_pattern.disp_order IS '表示順';
COMMENT ON COLUMN mst_zai_output_pattern.is_del IS '削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN mst_zai_output_pattern.reg_date IS '登録日時';
COMMENT ON COLUMN mst_zai_output_pattern.up_date IS '更新日時';
