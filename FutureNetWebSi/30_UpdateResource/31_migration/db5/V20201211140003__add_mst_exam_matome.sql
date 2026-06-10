-- 検査まとめ表   
CREATE TABLE ntss.mst_exam_matome (
	update_type numeric(1) NULL, -- 変更区分
	exam_matome_early_cd varchar(17) NULL, -- JLAC10ｺｰﾄﾞ（１5/17桁）
	exam_matome_cd varchar(17) NOT NULL, -- JLAC10ｺｰﾄﾞ（１７桁）
	analytical_material varchar(3) NULL, -- 分析物（拡張）
	analytical_material_cd varchar(5) NULL, -- 分析物（コード）
	analytical_material_name varchar(64) NULL, -- 分析物（名称）
	identify varchar(3) NULL, -- 識別（拡張）
	identify_cd numeric(4) NULL, -- 識別（コード）
	identify_name varchar(64) NULL, -- 識別（名称）
	material varchar(3) NULL, -- 材料（拡張）
	material_cd numeric(3) NULL, -- 材料（コード）
	material_name varchar(64) NULL, -- 材料（名称）
	assay varchar(3) NULL, -- 測定法（拡張）
	assay_cd numeric(3) NULL, -- 測定法（コード）
	assay_name varchar(64) NULL, -- 測定法（名称）
	result_recognition_common varchar(3) NULL, -- 結果識別（共通）（拡張）
	result_recognition_common_cd numeric(5) NULL, -- 結果識別（共通）（コード）
	result_recognition_common_name varchar(64) NULL, -- 結果識別（共通）（名称）
	result_recognition_inherent varchar(3) NULL, -- 結果識別（固有）（拡張）
	result_recognition_inherent_name varchar(64) NULL, -- 結果識別（固有）（名称）
	result_identification_searcher varchar(11) NULL, -- 結果識別検索子（分析物＋識別＋結果）
	standard_inspection_name varchar(64) NULL, -- 標準検査名称
	reference_result_identification_cd numeric(2) NULL, -- 参考（結果識別コード）
	reference_unit varchar(32) NULL, -- 参考（単位）
	insured varchar(1) NULL, -- 保険内
	medical_practice_cd numeric(9) NULL, -- 診療行為コード
	medical_practice_name1 varchar(64) NULL, -- 診療行為名称１（旧名称）
	medical_practice_name2 varchar(64) NULL, -- 診療行為名称２
	points numeric(10) NULL, -- 点数
	chapter varchar(1) NULL, -- 章
	category_number numeric(3) NULL, -- 区分番号
	item_number numeric(2) NULL, -- 項番
	update_date numeric(8) NULL, -- 更新年月日
	is_disp varchar(1) NULL DEFAULT '1'::character varying, -- 表示フラグ
	is_del varchar(1) NULL DEFAULT '0'::character varying, -- 削除フラグ
	reg_date timestamp NULL, -- 登録日時
	up_date timestamp NULL, -- 更新日時
	CONSTRAINT unq_mst_exam_matome_01 PRIMARY KEY (exam_matome_cd)
);
COMMENT ON TABLE ntss.mst_exam_matome IS '検査まとめ表';

-- Column comments

COMMENT ON COLUMN ntss.mst_exam_matome.update_type IS '変更区分';
COMMENT ON COLUMN ntss.mst_exam_matome.exam_matome_early_cd IS 'JLAC10ｺｰﾄﾞ（１5/17桁）';
COMMENT ON COLUMN ntss.mst_exam_matome.exam_matome_cd IS 'JLAC10ｺｰﾄﾞ（１７桁）';
COMMENT ON COLUMN ntss.mst_exam_matome.analytical_material IS '分析物（拡張）';
COMMENT ON COLUMN ntss.mst_exam_matome.analytical_material_cd IS '分析物（コード）';
COMMENT ON COLUMN ntss.mst_exam_matome.analytical_material_name IS '分析物（名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.identify IS '識別（拡張）';
COMMENT ON COLUMN ntss.mst_exam_matome.identify_cd IS '識別（コード）';
COMMENT ON COLUMN ntss.mst_exam_matome.identify_name IS '識別（名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.material IS '材料（拡張）';
COMMENT ON COLUMN ntss.mst_exam_matome.material_cd IS '材料（コード）';
COMMENT ON COLUMN ntss.mst_exam_matome.material_name IS '材料（名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.assay IS '測定法（拡張）';
COMMENT ON COLUMN ntss.mst_exam_matome.assay_cd IS '測定法（コード）';
COMMENT ON COLUMN ntss.mst_exam_matome.assay_name IS '測定法（名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.result_recognition_common IS '結果識別（共通）（拡張）';
COMMENT ON COLUMN ntss.mst_exam_matome.result_recognition_common_cd IS '結果識別（共通）（コード）';
COMMENT ON COLUMN ntss.mst_exam_matome.result_recognition_common_name IS '結果識別（共通）（名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.result_recognition_inherent IS '結果識別（固有）（拡張）';
COMMENT ON COLUMN ntss.mst_exam_matome.result_recognition_inherent_name IS '結果識別（固有）（名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.result_identification_searcher IS '結果識別検索子（分析物＋識別＋結果）';
COMMENT ON COLUMN ntss.mst_exam_matome.standard_inspection_name IS '標準検査名称';
COMMENT ON COLUMN ntss.mst_exam_matome.reference_result_identification_cd IS '参考（結果識別コード）';
COMMENT ON COLUMN ntss.mst_exam_matome.reference_unit IS '参考（単位）';
COMMENT ON COLUMN ntss.mst_exam_matome.insured IS '保険内';
COMMENT ON COLUMN ntss.mst_exam_matome.medical_practice_cd IS '診療行為コード';
COMMENT ON COLUMN ntss.mst_exam_matome.medical_practice_name1 IS '診療行為名称１（旧名称）';
COMMENT ON COLUMN ntss.mst_exam_matome.medical_practice_name2 IS '診療行為名称２';
COMMENT ON COLUMN ntss.mst_exam_matome.points IS '点数';
COMMENT ON COLUMN ntss.mst_exam_matome.chapter IS '章';
COMMENT ON COLUMN ntss.mst_exam_matome.category_number IS '区分番号';
COMMENT ON COLUMN ntss.mst_exam_matome.item_number IS '項番';
COMMENT ON COLUMN ntss.mst_exam_matome.update_date IS '更新年月日';
COMMENT ON COLUMN ntss.mst_exam_matome.is_disp IS '表示フラグ';
COMMENT ON COLUMN ntss.mst_exam_matome.is_del IS '削除フラグ';
COMMENT ON COLUMN ntss.mst_exam_matome.reg_date IS '登録日時';
COMMENT ON COLUMN ntss.mst_exam_matome.up_date IS '更新日時';
