DROP TABLE IF EXISTS mst_calc_setting;

-- 算定設定マスタ作成
CREATE TABLE mst_calc_setting (
    facility_cd     varchar(6)      NOT NULL
  , master_version  numeric(6,0)    NOT NULL
  , calc_cd         varchar(24)     NOT NULL
  , calc_name       varchar(200)
  , recept_cd       varchar(6)
  , disp_order      numeric(5,0)
  , is_del          varchar(1)      DEFAULT '0'
  , reg_date        timestamp(3) without time zone
  , up_date         timestamp(3) without time zone
  , CONSTRAINT pk_mst_calc_setting PRIMARY KEY (facility_cd, master_version, calc_cd)
);

CREATE INDEX idx_mst_calc_setting_01 
    ON mst_calc_setting (facility_cd, master_version);

-- 医事コードマスタ（施設・世代別）
DROP TABLE IF EXISTS mst_recept;

CREATE TABLE mst_recept (
  facility_cd character varying(6) NOT NULL
  , master_version numeric(6) NOT NULL
  , recept_cd character varying(6) NOT NULL
  , abbr_cd character varying(8)
  , section_type numeric(2)
  , section_sub_id numeric(2)
  , master_category numeric(1)
  , display_name character varying(72)
  , formal_name character varying(200)
  , input_unit character varying(6)
  , unit_price numeric(12, 4)
  , search_name character varying(8)
  , expiry_date numeric(8)
  , manage_no numeric(10)
  , reg_date timestamp(3) without time zone
  , up_date timestamp(3) without time zone
  , CONSTRAINT pk_mst_recept PRIMARY KEY (facility_cd, master_version, recept_cd)
) ;

CREATE INDEX idx_mst_recept_01
  ON mst_recept(facility_cd, master_version);

-- 診療区分表示順マスタ
DROP TABLE IF EXISTS mst_section_order;

CREATE TABLE mst_section_order (
  facility_cd character varying(6) NOT NULL
  , section_type numeric(3) NOT NULL
  , section_name character varying(100)
  , sort_order numeric(3)
  , disp_order numeric(3)
  , is_del character varying(1) DEFAULT '0'
  , reg_date timestamp(3) without time zone
  , up_date timestamp(3) without time zone
  , CONSTRAINT pk_mst_section_order PRIMARY KEY (facility_cd, section_type)
) ;

-- 剤出力マッピングマスタ
DROP TABLE IF EXISTS mst_zai_output_map;

CREATE TABLE mst_zai_output_map (
  facility_cd character varying(6) NOT NULL
  , map_calc_cd character varying(24)
  , map_calc_name character varying(100)
  , pattern_cd numeric(3)
  , disp_order numeric(3)
  , is_del character varying(1) DEFAULT '0'
  , reg_date timestamp(3) without time zone
  , up_date timestamp(3) without time zone
  , CONSTRAINT pk_mst_zai_output_map PRIMARY KEY (facility_cd, map_calc_cd)
) ;

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
  , claim_category_disp character varying(4)
  , claim_category_name character varying(64)
  , is_enabled character varying(1) DEFAULT '0'
  , disp_order numeric(3)
  , is_del character varying(1) DEFAULT '0'
  , reg_date timestamp(3) without time zone
  , up_date timestamp(3) without time zone
  , CONSTRAINT pk_mst_zai_output_pattern PRIMARY KEY (facility_cd, pattern_cd)
) ;

COMMENT ON TABLE mst_calc_setting IS '算定設定マスタ（施設・世代別の算定コード管理）';
COMMENT ON COLUMN mst_calc_setting.facility_cd IS '施設コード';
COMMENT ON COLUMN mst_calc_setting.master_version IS '世代（YYYYMM）';
COMMENT ON COLUMN mst_calc_setting.calc_cd IS '算定コード';
COMMENT ON COLUMN mst_calc_setting.calc_name IS '算定名';
COMMENT ON COLUMN mst_calc_setting.recept_cd IS '医事コード';
COMMENT ON COLUMN mst_calc_setting.disp_order IS '画面表示順';
COMMENT ON COLUMN mst_calc_setting.is_del IS '削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN mst_calc_setting.reg_date IS '登録日時';
COMMENT ON COLUMN mst_calc_setting.up_date IS '更新日時';

COMMENT ON TABLE mst_recept IS '医事コードマスタ（施設・世代別）';
COMMENT ON COLUMN mst_recept.facility_cd IS '施設コード';
COMMENT ON COLUMN mst_recept.master_version IS '世代（YYYYMM）';
COMMENT ON COLUMN mst_recept.recept_cd IS '医事コード';
COMMENT ON COLUMN mst_recept.abbr_cd IS '略称コード';
COMMENT ON COLUMN mst_recept.section_type IS '診区';
COMMENT ON COLUMN mst_recept.section_sub_id IS '診区枝番';
COMMENT ON COLUMN mst_recept.master_category IS 'マスタ区分';
COMMENT ON COLUMN mst_recept.display_name IS '表示名称';
COMMENT ON COLUMN mst_recept.formal_name IS '正式名称';
COMMENT ON COLUMN mst_recept.input_unit IS '入力単位';
COMMENT ON COLUMN mst_recept.unit_price IS '単価（点数・金額）';
COMMENT ON COLUMN mst_recept.search_name IS '読み（検索用）';
COMMENT ON COLUMN mst_recept.expiry_date IS '使用期限日（YYYYMMDD）';
COMMENT ON COLUMN mst_recept.manage_no IS '管理番号';
COMMENT ON COLUMN mst_recept.reg_date IS '登録日時';
COMMENT ON COLUMN mst_recept.up_date IS '更新日時';

COMMENT ON TABLE mst_section_order IS '診療区分表示順マスタ';
COMMENT ON COLUMN mst_section_order.facility_cd IS '施設コード';
COMMENT ON COLUMN mst_section_order.section_type IS '診療区分コード';
COMMENT ON COLUMN mst_section_order.section_name IS '診療区分コード名';
COMMENT ON COLUMN mst_section_order.sort_order IS 'ソート番号';
COMMENT ON COLUMN mst_section_order.disp_order IS '表示順';
COMMENT ON COLUMN mst_section_order.is_del IS '削除フラグ（0:有効 1:削除）';
COMMENT ON COLUMN mst_section_order.reg_date IS '登録日時';
COMMENT ON COLUMN mst_section_order.up_date IS '更新日時';

COMMENT ON TABLE mst_zai_output_map IS '剤出力マッピングマスタ';
COMMENT ON COLUMN mst_zai_output_map.facility_cd IS '施設コード';
COMMENT ON COLUMN mst_zai_output_map.map_calc_cd IS '算定コード';
COMMENT ON COLUMN mst_zai_output_map.map_calc_name IS '算定名';
COMMENT ON COLUMN mst_zai_output_map.pattern_cd IS '剤パターンコード';
COMMENT ON COLUMN mst_zai_output_map.disp_order IS '表示順';
COMMENT ON COLUMN mst_zai_output_map.is_del IS '削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN mst_zai_output_map.reg_date IS '登録日時';
COMMENT ON COLUMN mst_zai_output_map.up_date IS '更新日時';

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
COMMENT ON COLUMN mst_zai_output_pattern.claim_category_disp IS 'レセプト表示診区名';
COMMENT ON COLUMN mst_zai_output_pattern.claim_category_name IS 'レセプト診区名';
COMMENT ON COLUMN mst_zai_output_pattern.is_enabled IS 'is_enabled';
COMMENT ON COLUMN mst_zai_output_pattern.disp_order IS '表示順';
COMMENT ON COLUMN mst_zai_output_pattern.is_del IS '削除フラグ（0：有効、1：削除）';
COMMENT ON COLUMN mst_zai_output_pattern.reg_date IS '登録日時';
COMMENT ON COLUMN mst_zai_output_pattern.up_date IS '更新日時';
