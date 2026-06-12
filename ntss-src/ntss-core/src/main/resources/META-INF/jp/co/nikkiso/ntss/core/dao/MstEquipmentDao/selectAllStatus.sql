WITH PAT_INFO AS (
  SELECT
    pat_id,
    elem ->> 'category_class' as category_class,
  elem ->> 'taboo_allergy_class' as taboo_allergy_class,
  (elem ->> 'taboo_allergy_cd')::int as taboo_allergy_cd
FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements (taboo_allergy_info) elem
WHERE pat_id = (/* params.get("patId") */0)::int
  ),TABOO_ALLERGY AS (
SELECT
  pd.pat_id,
  elem ->> 'classCd' as category_class,
  pd.taboo_allergy_class,
  (elem ->> 'cd')::int as cd
FROM PAT_INFO pd
  INNER JOIN mst_taboo_allergy mta
on pd.taboo_allergy_cd = mta.taboo_allergy_cd
  and pd.category_class = '0'
  CROSS JOIN LATERAL jsonb_array_elements (mta.detail_info) elem
WHERE elem ->> 'classCd' in ('1','2','3','4')
  ),TABOO_ALLERGY_TMP as (
select * from TABOO_ALLERGY
UNION
select pat_id, category_class, taboo_allergy_class, taboo_allergy_cd as cd
from PAT_INFO
where category_class in ('1','2','3','4')
  ),TABOO_ALLERGY_medicine_mix_tmp as (
SELECT
  tat.pat_id,
  '2' as category_class,
  tat.taboo_allergy_class,
  mmm.medicine_mix_cd as cd
FROM TABOO_ALLERGY_TMP tat
  INNER JOIN mst_medicine_mix mmm
ON mmm.mix_info @> jsonb_build_array(jsonb_build_object('cd', tat.cd))
WHERE tat.category_class = '1'
  ),TABOO_ALLERGY_data_pat as (
SELECT
  pat_id,
  category_class,
  cd,
  BOOL_OR(taboo_allergy_class = '1') AS is_taboo,
  BOOL_OR(taboo_allergy_class = '2') AS is_allergy
FROM (
  select * from TABOO_ALLERGY_medicine_mix_tmp
  UNION
  select * from TABOO_ALLERGY_TMP
  ) t
GROUP BY pat_id, category_class, cd
  ),TABOO_ALLERGY_TO_MST AS (
SELECT DISTINCT *
from TABOO_ALLERGY_data_pat
where category_class = '3'
  ),
BASE AS (
  SELECT
      A.equipment_cd            AS "equipmentCd",
      A.facility_cd             AS "facilityCd",
      A.fn_equipment_cd         AS "fnEquipmentCd",
      A.standard_equipment_cd   AS "standardEquipmentCd",
      A.is_trial                AS "isTrial",
      A.equipment_name          AS "equipmentName",
      A.equipment_short_name    AS "equipmentShortName",
      A.class_cd                AS "classCd",
      A.unit                    AS "unit",
      A.use_start_date          AS "useStartDate",
      A.use_end_date            AS "useEndDate",
      A.in_hospital_cd_1        AS "inHospitalCd1",
      A.in_hospital_cd_2        AS "inHospitalCd2",
      A.in_hospital_cd_3        AS "inHospitalCd3",
      A.is_disp                 AS "isDisp",
      A.is_del                  AS "isDel",
      A.reg_date                AS "regDate",
      A.up_date                 AS "upDate",
      A.in_hospital_cd_4        AS "inHospitalCd4",

      CASE
          WHEN ms.code IS NOT NULL THEN 0 ELSE 1
      END                      AS "sortGroup",
      ms.selector_index        AS "medicineMixSelectorIndex",
      CASE
        WHEN TATM.is_taboo AND TATM.is_allergy THEN '【禁忌・ｱﾚﾙｷﾞｰ】'
        WHEN TATM.is_taboo THEN '【禁忌】'
        WHEN TATM.is_allergy THEN '【ｱﾚﾙｷﾞｰ】'
        ELSE ''
      END                      AS "tabooAllergy",
      CASE
        WHEN
          (A.use_start_date IS NOT NULL AND A.use_start_date >
            /*%if params.get("treatDate") != null && !params.get("treatDate").trim().isEmpty() */
              /* params.get("treatDate") */'20000101'
            /*%else */
              TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
            /*%end */
          )
            OR
          (A.use_end_date   IS NOT NULL AND A.use_end_date   <
            /*%if params.get("treatDate") != null && !params.get("treatDate").trim().isEmpty() */
              /* params.get("treatDate") */'20000101'
            /*%else */
              TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
            /*%end */
          )
          THEN '【期限切れ】'
        ELSE ''
      END                      AS "expired",
      CASE
        WHEN /* params.get("classType") */'' <> ''
             AND (
               MEC.class_type IS NULL
               OR NOT (MEC.class_type = ANY(string_to_array(/* params.get("classType") */'0', ',')::int[]))
             )
          THEN '【分類不一致】'
        ELSE ''
      END                      AS "classInconsistent"
  FROM
      mst_equipment A
      LEFT JOIN mst_equipment_class MEC
        ON MEC.class_cd = A.class_cd
      LEFT JOIN TABOO_ALLERGY_TO_MST TATM ON A.equipment_cd = TATM.cd
      LEFT JOIN LATERAL (
          SELECT
              mss.facility_cd      AS facility_cd,
              ms.code              AS code,
              ms.name              AS name,
              ROW_NUMBER() OVER () AS selector_index
          FROM
              mst_selector mss
              CROSS JOIN LATERAL jsonb_to_recordset(
                  mss.order_settings -> 'items'
              ) AS ms(code BIGINT, name TEXT)
          WHERE
              mss.master_physical_name = 'mst_equipment'
      ) ms
          ON A.facility_cd = ms.facility_cd
         AND A.equipment_cd = ms.code
  WHERE
      A.facility_cd = /* params.get("facilityCd") */'0'
),
MAIN AS (
  SELECT
    B.*,
    '' AS "deleted",
    '' AS "includeDeleted"
  FROM BASE B
  WHERE
    B."isDisp" = '1'
    AND B."isDel" = '0'
    /*%if params.get("excludeEquipmentCdList") != null && !params.get("excludeEquipmentCdList").trim().isEmpty()*/
    AND NOT (
      B."equipmentCd" = ANY(string_to_array(/* params.get("excludeEquipmentCdList") */'0', ',')::int[])
    )
    /*%end*/
    /*%if params.get("classType") != null && !params.get("classType").trim().isEmpty()*/
    AND B."classInconsistent" = ''
    /*%end*/
),
INIT AS (
  SELECT
    B.*,
    CASE
      WHEN B."isDisp" = '0' OR B."isDel" = '1'
        THEN '【削除済み】'
      ELSE ''
    END AS "deleted",
    '' AS "includeDeleted"
  FROM BASE B
  WHERE
    /*%if params.get("initEquipmentCd") != null && !params.get("initEquipmentCd").trim().isEmpty() */
    B."equipmentCd" = (/* params.get("initEquipmentCd") */0)::int
    /*%else */
    1 = 0
    /*%end */
)
SELECT *
FROM MAIN
UNION ALL
SELECT I.*
FROM INIT I
WHERE NOT EXISTS (
  SELECT 1
  FROM MAIN M
  WHERE M."equipmentCd" = I."equipmentCd"
)
ORDER BY
    "sortGroup" ASC,
    "medicineMixSelectorIndex" NULLS LAST,
    "equipmentCd";
