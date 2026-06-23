
ALTER TABLE
  mst_machine
DROP COLUMN support_mode
,DROP COLUMN tmp_center
,ADD COLUMN is_support_hd character varying(1)
,ADD COLUMN is_support_ecum character varying(1)
,ADD COLUMN is_support_hdf character varying(1)
,ADD COLUMN is_support_hf character varying(1)
,ADD COLUMN is_support_hd_ho character varying(1)
,ADD COLUMN is_support_ecum_ho character varying(1)
,ADD COLUMN is_support_afbf character varying(1)
,ADD COLUMN is_support_ohdf character varying(1)
,ADD COLUMN is_support_ohf character varying(1)
,ADD COLUMN is_support_i_hdf character varying(1)
,ADD COLUMN tmp_center_hd integer
,ADD COLUMN tmp_center_ecum integer
,ADD COLUMN tmp_center_hdf integer
,ADD COLUMN tmp_center_hf integer
,ADD COLUMN tmp_center_hd_ho integer
,ADD COLUMN tmp_center_ohdf integer
,ADD COLUMN tmp_center_ohf integer
;
COMMENT ON COLUMN "mst_machine"."is_support_hd" IS E'対応可否フラグ(HD)';
COMMENT ON COLUMN "mst_machine"."is_support_ecum" IS E'対応可否フラグ(ECUM)';
COMMENT ON COLUMN "mst_machine"."is_support_hdf" IS E'対応可否フラグ(HDF)';
COMMENT ON COLUMN "mst_machine"."is_support_hf" IS E'対応可否フラグ(HF)';
COMMENT ON COLUMN "mst_machine"."is_support_hd_ho" IS E'対応可否フラグ(HD+補液)';
COMMENT ON COLUMN "mst_machine"."is_support_ecum_ho" IS E'対応可否フラグ(ECUM+補液)';
COMMENT ON COLUMN "mst_machine"."is_support_afbf" IS E'対応可否フラグ(AFBF)';
COMMENT ON COLUMN "mst_machine"."is_support_ohdf" IS E'対応可否フラグ(OHDF)';
COMMENT ON COLUMN "mst_machine"."is_support_ohf" IS E'対応可否フラグ(OHF)';
COMMENT ON COLUMN "mst_machine"."is_support_i_hdf" IS E'対応可否フラグ(I-HDF)';
COMMENT ON COLUMN "mst_machine"."tmp_center_hd" IS E'TMP初期補正中点(HD)';
COMMENT ON COLUMN "mst_machine"."tmp_center_ecum" IS E'TMP初期補正中点(ECUM)';
COMMENT ON COLUMN "mst_machine"."tmp_center_hdf" IS E'TMP初期補正中点(HDF)';
COMMENT ON COLUMN "mst_machine"."tmp_center_hf" IS E'TMP初期補正中点(HF)';
COMMENT ON COLUMN "mst_machine"."tmp_center_hd_ho" IS E'TMP初期補正中点(HD+補液)';
COMMENT ON COLUMN "mst_machine"."tmp_center_ohdf" IS E'TMP初期補正中点(OHDF)';
COMMENT ON COLUMN "mst_machine"."tmp_center_ohf" IS E'TMP初期補正中点(OHF)';

