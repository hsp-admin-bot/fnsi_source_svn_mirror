WITH main AS (
  SELECT
    addition_cd AS "additionCd",
    fn_add_cd AS "fnAddCd",
    addition_name AS "additionName",
    addition_short_name AS "additionShortName",
    addition_kind AS "additionKind",
    addition_class AS "additionClass",
    addition_span AS "additionSpan",
    addition_limit AS "additionLimit",
    addition_limit_type AS "additionLimitType",
    add_cnt_1 AS "addCnt1",
    addition_cond AS "additionCond",
    addition_tar_cd AS "additionTarCd",
    in_hospital_cd_1 AS "inHospitalCd1",
    in_hospital_cd_2 AS "inHospitalCd2",
    in_hospital_cd_3 AS "inHospitalCd3",
    addition_dialysis_time AS "additionDialysisTime",
    facility_cd AS "facilityCd",
    is_disp AS "isDisp",
    is_del AS "isDel",
    CASE
      WHEN is_disp = '0' OR is_del = '1'
        THEN '【削除済み】'
      ELSE ''
    END AS "deleted"
  FROM mst_addition
  WHERE facility_cd = /* params.get("facilityCd") */'1'
    AND (is_disp <> '0' AND is_del <> '1')
),

init AS (
  SELECT
    addition_cd AS "additionCd",
    fn_add_cd AS "fnAddCd",
    addition_name AS "additionName",
    addition_short_name AS "additionShortName",
    addition_kind AS "additionKind",
    addition_class AS "additionClass",
    addition_span AS "additionSpan",
    addition_limit AS "additionLimit",
    addition_limit_type AS "additionLimitType",
    add_cnt_1 AS "addCnt1",
    addition_cond AS "additionCond",
    addition_tar_cd AS "additionTarCd",
    in_hospital_cd_1 AS "inHospitalCd1",
    in_hospital_cd_2 AS "inHospitalCd2",
    in_hospital_cd_3 AS "inHospitalCd3",
    addition_dialysis_time AS "additionDialysisTime",
    facility_cd AS "facilityCd",
    is_disp AS "isDisp",
    is_del AS "isDel",
    CASE
      WHEN is_disp = '0' OR is_del = '1'
        THEN '【削除済み】'
      ELSE ''
    END AS "deleted"
  FROM mst_addition
  WHERE facility_cd = /* params.get("facilityCd") */'1'
    AND addition_cd = /* params.get("initAdditionCd") */0
)
SELECT * FROM main
UNION
SELECT * FROM init
ORDER BY "additionCd"
