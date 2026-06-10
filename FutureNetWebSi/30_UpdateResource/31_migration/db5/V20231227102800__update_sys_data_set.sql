DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-604173);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604173, 'with rst_cond_info AS (
  SELECT
    jsonb_object_keys (ord.rst_cond_info) AS ntss_cd,
    ord.rst_cond_info -> jsonb_object_keys (ord.rst_cond_info) AS rst_cond_info
  FROM
    ord_main AS ord
  WHERE
    ord.ord_no = @ordNo
)
SELECT
  info ->> ''cd'' as equip_cd,
  info ->> ''name'' as equip_name,
  info ->> ''class_type'' as class_type,
  info ->> ''class_cd'' as class_cd,
  info ->> ''class_name'' as class_name,
  info ->> ''amount'' as amount,
  info ->> ''unit'' as unit,
  info ->> ''cop_order_no'' as cop_order_no,
  info ->> ''is_editable'' as is_editable,
  meqa.reg_date,
  meqa.in_hospital_cd_1,
  meqa.in_hospital_cd_2
FROM
  ord_main as ord
  cross join lateral json_array_elements (ord.rst_equip_info :: json) info
  LEFT OUTER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(info ->> ''cd'', ''999999999999'')
WHERE
  ord.ord_no = @ordNo
UNION ALL
SELECT
  cond.rst_cond_info ->> ''value'' as equip_cd,
  cond.rst_cond_info ->> ''value_name_1'' as equip_name,
  cond.rst_cond_info ->> ''input_class'' as class_type,
  meqa.class_cd::text as class_cd,
  meqc.class_name,
  ''1'' as amount,
  meqa.unit,
  cond.rst_cond_info ->> ''cop_order_no'' as cop_order_no,
  cond.rst_cond_info ->> ''is_editable'' as is_editable,
  meqa.reg_date,
  meqa.in_hospital_cd_1,
  meqa.in_hospital_cd_2
FROM 
  rst_cond_info as cond
  INNER JOIN mst_equipment AS meqa -- 医療材料マスタ
  ON meqa.equipment_cd = TO_NUMBER(cond.rst_cond_info ->> ''value'', ''999999999999'')
  AND cond.ntss_cd in (''7'',''8'',''9'',''10'',''11'',''13'')
  INNER JOIN mst_equipment_class AS meqc -- 医療材料クラスマスタ
  ON meqa.class_cd = meqc.class_cd 
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(医療材料)', '2023-12-07 14:03:17.031', CURRENT_TIMESTAMP, NULL);
