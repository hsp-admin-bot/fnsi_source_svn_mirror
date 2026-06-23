DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (118, 120, 121, 122, 123, 124, 125, 126);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (118, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 1
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト1", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト1", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト1", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト1", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト1", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト1 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (120, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 2
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト2", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト2", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト2", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト2", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト2", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト2 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (121, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 3
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト3", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト3", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト3", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト3", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト3", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト3 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (122, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 4
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト4", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト4", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト4", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト4", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト4", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト4 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (123, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 5
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト5", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト5", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト5", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト5", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト5", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト5 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (124, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 6
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト6", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト6", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト6", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト6", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト6", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト6 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (125, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 7
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト7", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト7", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト7", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト7", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト7", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト7 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (126, 'WITH latest_checklist AS (
SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = @facilityCd and is_del = ''0'' ORDER BY checklist_cd DESC LIMIT 1
)
, mst_info AS (
  SELECT
    checklist_cd,
    elem ->> ''list_cd'' AS list_cd,
    item ->> ''class_cd'' AS class_cd,
    item ->> ''list_name'' AS item_list_name,
    item ->> ''func_class'' AS func_class,
    item ->> ''item_number'' AS item_number,
    item ->> ''ord_checklist_change_flg'' AS ord_checklist_change_flg,
    elem ->> ''list_name'' AS list_name,
    elem ->> ''operation'' AS operation,
    elem ->> ''dialysis_prog_cd'' AS dialysis_prog_cd,
    elem ->> ''dialysis_prog_name'' AS dialysis_prog_name
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item
  WHERE
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    CASE
        WHEN v.new_class_cd = 6 THEN ''吸着カラム''
        WHEN v.new_class_cd = 7 THEN ''一次膜''
        WHEN v.new_class_cd = 8 THEN ''二次膜''
        ELSE item ->> ''list_name''
    END AS item_list_name,
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (6), (7), (8)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''5''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''

  UNION ALL

  SELECT
    checklist_cd,
    elem ->> ''list_cd'',
    new_class_cd::text AS class_cd,
    item ->> ''list_name'',
    item ->> ''func_class'',
    item ->> ''item_number'',
    item ->> ''ord_checklist_change_flg'',
    elem ->> ''list_name'',
    elem ->> ''operation'',
    elem ->> ''dialysis_prog_cd'',
    elem ->> ''dialysis_prog_name''
  FROM
    latest_checklist,
    LATERAL jsonb_array_elements(checklist_settings) AS elem,
    LATERAL jsonb_array_elements(elem -> ''funclist'') AS item,
    LATERAL (VALUES (10), (11)) AS v(new_class_cd)
  WHERE
    item ->> ''class_cd'' = ''9''
    AND
    elem ->> ''dialysis_prog_cd'' in (''0'', ''1'', ''2'')
    AND
    item ->> ''func_class'' = ''1''
),
ord_main_info as (
select *  from ord_main om
where om.ord_no = @ordNo and
  om.facility_cd = @facilityCd
  
),
ord_checklist_info as (
  select oci.*,
    oci.rst_checklist_info ->> ''code'' as code,
    oci.rst_checklist_info ->> ''name'' as name,
    oci.rst_checklist_info ->> ''unit'' as unit,
    oci.rst_checklist_info ->> ''amount'' as amount,
    oci.rst_checklist_info ->> ''class_cd'' as class_cd,
    oci.rst_checklist_info ->> ''equip_type'' as equip_type,
    oci.rst_checklist_info ->> ''item_number'' as item_number,
    (oci.rst_checklist_info ->> ''medicine_no'')::int as medicine_no,
    oci.rst_checklist_info ->> ''checklist_cd'' as checklist_cd,
    oci.rst_checklist_info ->> ''medicine_type'' as medicine_type
  from ord_checklist oci JOIN ord_main_info omi ON oci.ord_no = omi.ord_no
    and oci.facility_cd = @facilityCd
    and oci.is_disp = ''1''
    and oci.is_del = ''0''
),
ord_cond_info as (
SELECT
  om.ord_no,
  (jsonb_each(om.ind_cond_info)).key as class_cd,
  (jsonb_each(om.ind_cond_info)).value as elem,
  om.facility_cd
FROM
  ord_main_info om
),
ord_cond_amount as (
SELECT
  om.ord_no,
  om.facility_cd,
  CASE
    WHEN class_cd = ''17'' THEN ''15''
    WHEN class_cd = ''22'' THEN ''19''
    WHEN class_cd IN (''26'', ''28'') THEN ''25''
  END AS class_cd,
  SUM(COALESCE(NULLIF(elem ->> ''value'', ''''), ''0'')::numeric) AS amount
FROM
  ord_cond_info om
WHERE
  class_cd IN (''17'', ''22'', ''26'', ''28'')
GROUP BY ord_no, facility_cd,
         CASE
          WHEN class_cd = ''17'' THEN ''15''
          WHEN class_cd = ''22'' THEN ''19''
          WHEN class_cd IN (''26'', ''28'') THEN ''25''
         END
),
mst_medicine_cond as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' = ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_medicine_mix_cond as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    where oci.elem ->> ''medicine_type'' <> ''1''
      and oci.class_cd in (''15'', ''19'', ''25'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_dialyzer_cond as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE
      oci.class_cd = ''5''
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),
mst_equipment_cond as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oci.elem ->> ''value'')::int
    from ord_cond_info oci
    WHERE oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
      AND jsonb_exists(oci.elem, ''value'')
      AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
      AND oci.elem ->> ''value'' <> ''''
  )
),

ord_cond as (
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  oci.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN ROUND(oca.amount, mm.unit_decimal_point)::text ELSE ROUND(oca.amount, mmm.unit_decimal_point)::text END amount,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN mm.unit_second ELSE mmm.unit END as unit,
  CASE WHEN oci.elem ->> ''medicine_type'' = ''1'' THEN
    case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
    case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  oci.facility_cd
FROM
  ord_cond_info oci INNER JOIN ord_cond_amount oca on oci.ord_no = oca.ord_no and oci.class_cd = oca.class_cd
      LEFT JOIN mst_medicine_cond mm on mm.medicine_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = oci.facility_cd
      LEFT JOIN mst_medicine_mix_cond mmm on mmm.medicine_mix_cd::TEXT = oci.elem ->> ''value'' and oci.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''15'', ''19'', ''25'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  ''1'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_dialyzer_cond md on md.dialyzer_cd::TEXT = oci.elem ->> ''value'' and md.facility_cd = oci.facility_cd
WHERE
  oci.class_cd = ''5''
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
UNION ALL
SELECT
  oci.ord_no,
  oci.class_cd,
  oci.elem ->> ''value'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  ''1'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oci.facility_cd
FROM
  ord_cond_info oci
      LEFT JOIN mst_equipment_cond me on me.equipment_cd::TEXT = oci.elem ->> ''value'' and me.facility_cd = oci.facility_cd
WHERE
  oci.class_cd in (''6'', ''7'', ''8'', ''9'', ''10'', ''11'', ''13'')
	AND jsonb_exists(oci.elem, ''value'')
AND jsonb_typeof(oci.elem -> ''value'') IS DISTINCT FROM ''null''
AND oci.elem ->> ''value'' <> ''''
),
ord_equip_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_equip_info :: json) elem
),
mst_dialyzer_equip as (
  select *
  from mst_dialyzer
  where dialyzer_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''1''
  )
),
mst_equipment_equip as (
  select *
  from mst_equipment
  where equipment_cd in (
    SELECT DISTINCT (oei.elem ->> ''cd'')::int
    from ord_equip_info oei
    WHERE oei.elem ->> ''equip_type'' = ''0''
  )
),
ord_equip as (
SELECT
  oei.ord_no,
  ''0'' as class_cd,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''1'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  ''本'' as unit,
  case when md.is_del = ''0'' and md.is_disp = ''1'' then md.model_number else ''【削除済み】'' || md.model_number end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_dialyzer_equip md on md.dialyzer_cd::TEXT = oei.elem ->> ''cd'' and md.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''1''
UNION ALL
SELECT
  oei.ord_no,
  me.class_cd::TEXT,
  oei.elem ->> ''cd'' as code,
  null as medicine_type,
  ''0'' as equip_type,
  oei.elem ->> ''amount'' as amount,
  me.unit as unit,
  case when me.is_del = ''0'' and me.is_disp = ''1'' then me.equipment_name else ''【削除済み】'' || me.equipment_name end as name,
  oei.facility_cd
FROM
  ord_equip_info oei
      LEFT JOIN mst_equipment_equip me on me.equipment_cd::TEXT = oei.elem ->> ''cd'' and me.facility_cd = oei.facility_cd
WHERE
  oei.elem ->> ''equip_type'' = ''0''
),
ord_medi_info as (
SELECT
  om.ord_no,
  elem,
  om.facility_cd
FROM
  ord_main_info om cross join lateral
  json_array_elements (om.ind_medi_info :: json) elem
),
mst_medicine_medi as (
  select *
  from mst_medicine
  where medicine_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' = ''1''
  )
),
mst_medicine_mix_medi as (
  select *
  from mst_medicine_mix
  where medicine_mix_cd in (
    SELECT DISTINCT (omi.elem ->> ''cd'')::int
    from ord_medi_info omi
    where omi.elem ->> ''medicine_type'' <> ''1''
  )
),
ord_medi as (
SELECT
  omi.ord_no,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.class_cd::TEXT ELSE mmm.class_cd::TEXT END as class_cd,
  omi.elem ->> ''cd'' as code,
  omi.elem ->> ''no'' as medicine_no,
  omi.elem ->> ''medicine_type'' as medicine_type,
  NULL as equip_type,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN ROUND((omi.elem ->> ''amount'')::numeric, mm.unit_decimal_point)::text ELSE ROUND((omi.elem ->> ''amount'')::numeric, mmm.unit_decimal_point)::text END amount,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN mm.unit ELSE mmm.unit END as unit,
  CASE WHEN omi.elem ->> ''medicine_type'' = ''1'' THEN
  case when mm.is_del = ''0'' and mm.is_disp = ''1'' then mm.medicine_name else ''【削除済み】'' || mm.medicine_name end
  ELSE
  case when mmm.is_del = ''0'' and mmm.is_disp = ''1'' then mmm.medicine_mix_name else ''【削除済み】'' || mmm.medicine_mix_name end END as name,
  omi.facility_cd
FROM
  ord_medi_info omi
      LEFT JOIN mst_medicine_medi mm on mm.medicine_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' = ''1'' and mm.facility_cd = omi.facility_cd
      LEFT JOIN mst_medicine_mix_medi mmm on mmm.medicine_mix_cd::TEXT = omi.elem ->> ''cd'' and omi.elem ->> ''medicine_type'' <> ''1'' and mmm.facility_cd = omi.facility_cd
),
biz_detail AS (
  SELECT
    ord_no,
    class_cd,
    code,
    null as medicine_no,
    medicine_type,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''1'' AS src_func_class
  FROM ord_cond

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    NULL,
    NULL,
    equip_type,
    amount,
    unit,
    name,
    facility_cd,
    ''2''
  FROM ord_equip

  UNION ALL
  SELECT
    ord_no,
    class_cd,
    code,
    medicine_no,
    medicine_type,
    NULL,
    amount,
    unit,
    name,
    facility_cd,
    ''3''
  FROM ord_medi
),
base_cross AS (
  SELECT
    o.ord_no,
    o.facility_cd,
    mi.*
  FROM ord_main_info o
  CROSS JOIN mst_info mi
  where mi.func_class in (''0'',''1'',''2'',''3'')
),
ord_chklst as (
 SELECT
    COALESCE(oci.checklist_ctl_no, NULL) AS checklist_ctl_no,
    o.ord_no,
    COALESCE(oci.is_check, ''0'') AS is_check,
    CASE
      WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
        CASE o.dialysis_prog_cd
          WHEN ''0'' THEN 7
          WHEN ''1'' THEN 8
          WHEN ''2'' THEN 9
          ELSE o.dialysis_prog_cd::smallint
        END
      ELSE o.dialysis_prog_cd::smallint
    END AS rst_class,
    o.list_cd::smallint AS list_cd,
    o.func_class::smallint AS func_class,
    COALESCE(
      oci.rst_checklist_info,
      jsonb_build_object(
        ''code'', case when om.code != '''' then om.code::int else NULL end,
        ''name'', CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END,
        ''unit'', om.unit,
        ''amount'', om.amount,
        ''class_cd'', case when o.class_cd != '''' then o.class_cd::int else NULL end,
        ''equip_type'', case when om.equip_type != '''' then om.equip_type::smallint else NULL end,
        ''code_update'', NULL,
        ''item_number'', o.item_number::smallint,
        ''medicine_no'', case when om.medicine_no != '''' then om.medicine_no else NULL end,
        ''checklist_cd'', o.checklist_cd,
        ''medicine_type'', case when om.medicine_type != '''' then om.medicine_type::smallint else NULL end
      )
    ) AS rst_checklist_info,
    COALESCE(
      oci.reg_staff_info,
      ''{"reg_staff_cd": null, "reg_staff_name": null, "reg_staff_update": null}''::jsonb
    ) AS reg_staff_info,
    ''1'' AS is_disp,
    ''0'' AS is_del,
    oci.occur_date,
    oci.reg_date,
    oci.up_date,
    o.facility_cd
  FROM
    base_cross o
  LEFT JOIN biz_detail om ON 
    o.class_cd = om.class_cd 
    and o.ord_no = om.ord_no
    and o.func_class = om.src_func_class
  LEFT JOIN
    ord_checklist_info oci
  ON
    oci.func_class::text = o.func_class
    AND oci.ord_no = o.ord_no
    AND oci.rst_class =  CASE
            WHEN om.class_cd IS NULL and o.func_class <> ''0'' THEN
              CASE o.dialysis_prog_cd
                WHEN ''0'' THEN 7
                WHEN ''1'' THEN 8
                WHEN ''2'' THEN 9
                ELSE o.dialysis_prog_cd::smallint
              END
            ELSE o.dialysis_prog_cd::smallint
          END
    AND oci.list_cd = o.list_cd::smallint
    AND oci.code IS NOT DISTINCT FROM case when om.code <> '''' then om.code else NULL end
    AND oci.name IS NOT DISTINCT FROM CASE WHEN om.class_cd IS NULL THEN o.item_list_name ELSE om.name END
    AND oci.unit IS NOT DISTINCT FROM om.unit
    AND oci.amount::numeric IS NOT DISTINCT FROM NULLIF(om.amount, '''')::numeric
    AND oci.class_cd IS NOT DISTINCT FROM case when o.class_cd != '''' then o.class_cd else NULL end
    AND oci.equip_type IS NOT DISTINCT FROM case when om.equip_type != '''' then om.equip_type else NULL end
    AND oci.item_number = o.item_number
    AND oci.medicine_no IS NOT DISTINCT FROM case when om.medicine_no != '''' then om.medicine_no::smallint else NULL end
    AND oci.checklist_cd::int = o.checklist_cd
    AND oci.medicine_type IS NOT DISTINCT FROM case when om.medicine_type != '''' then om.medicine_type else NULL end
),
base_data AS (
  SELECT *,
         rst_checklist_info->>''item_number'' AS item_number,
         rst_checklist_info->>''class_cd'' AS class_cd
  FROM ord_chklst
),
need_check AS (
  SELECT *
  FROM base_data
  WHERE rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
),
grouped AS (
  SELECT
    ord_no,
    list_cd,
    item_number,
    ARRAY_AGG(DISTINCT class_cd ORDER BY class_cd) AS class_cd_list
  FROM need_check
  GROUP BY ord_no, list_cd, item_number
),
flagged AS (
  SELECT
    g.ord_no,
    g.list_cd,
    g.item_number,
    (ARRAY[''5'',''6'',''7'',''8''] <@ class_cd_list) AS has_5678,
    (ARRAY[''9'',''10'',''11''] <@ class_cd_list) AS has_91011
  FROM grouped g
),
filtered_need_check AS (
  SELECT b.*
  FROM need_check b
  JOIN flagged f
    ON b.ord_no = f.ord_no
   AND b.list_cd = f.list_cd
   AND b.item_number = f.item_number
  WHERE
    (b.class_cd = ''5'' AND f.has_5678 = TRUE)
    OR
    (b.class_cd = ''9'' AND f.has_91011 = TRUE)
),
final_result AS (
  SELECT * FROM base_data
  WHERE NOT (
    rst_class IN (''7'', ''8'', ''9'')
    AND class_cd IN (''5'',''6'',''7'',''8'',''9'',''10'',''11'')
    AND func_class = ''1''
  )
  UNION ALL
  SELECT * FROM filtered_need_check
)
, final_result_filter AS (
  SELECT * FROM final_result
  WHERE rst_class NOT IN (''7'', ''8'', ''9'')
)
, mst_check_last AS (
  SELECT
    checklist_cd,
     CAST(checklist_setting ->> ''list_cd'' AS INTEGER) as list_cd,
    checklist_setting
  FROM
    mst_checklist mc
    CROSS JOIN LATERAL jsonb_array_elements(checklist_settings)
    WITH ORDINALITY AS tmp(checklist_setting, json_idx)
  WHERE
    json_idx = 8
    AND facility_cd = @facilityCd

    AND is_disp = ''1''
    AND is_del = ''0''
  ORDER BY checklist_cd DESC
  LIMIT 1
)
, mst_check_last_exp AS (
  SELECT
    checklist_cd,
    list_cd,
    mcl.checklist_setting->>''dialysis_prog_name'' AS dialysis_prog_name,
    mcl.checklist_setting->>''list_name'' AS list_name,
    elem->>''func_class'' AS func_class,
    elem->>''class_cd'' AS class_cd,
    elem->>''list_name'' AS funclist_list_name,
    
    CAST(elem->>''item_number'' AS INTEGER) AS item_number,
    ord_idx
  FROM
    mst_check_last mcl,
    jsonb_array_elements(mcl.checklist_setting->''funclist'') WITH ORDINALITY AS elem(elem, ord_idx)
)
, checklist_cd_record AS (
  SELECT
    ord_no,
    is_check,
    oce.list_cd,
    oce.func_class,
    CAST(rst_checklist_info->>''code'' AS INTEGER) AS code,
    rst_checklist_info->>''name'' AS item_name,
    rst_checklist_info->>''unit'' AS unit,
    CAST(rst_checklist_info->>''amount'' AS NUMERIC) AS amount,
    CAST(rst_checklist_info->>''class_cd'' AS INTEGER) AS class_cd,
    CAST(oce.occur_date AS TIMESTAMP) AS occur_date,
    CAST(rst_checklist_info->>''item_number'' AS INTEGER) AS item_number,
    rst_checklist_info->>''medicine_no'' AS medicine_no,
    CAST(rst_checklist_info->>''checklist_cd'' AS INTEGER) AS checklist_cd,
    CAST(rst_checklist_info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(rst_checklist_info->>''equip_type'' AS INTEGER) AS equip_type,
    reg_staff_info->>''reg_staff_name'' AS reg_staff_name,
    facility_cd
  FROM final_result_filter oce
  INNER JOIN mst_check_last mcl ON oce.list_cd = mcl.list_cd
)
, medi_ord AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
)
, equi_ord AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
, medi_mix_ord AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
)
, dia_ord AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS dia_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
)
SELECT
  ccr.ord_no,
	omi.treat_date,
	mcle.checklist_cd,
	mcle.list_cd,
	mcle.dialysis_prog_name,
	mcle.list_name,
	CASE
    WHEN mcle.func_class IS NULL THEN ''未登録''
    ELSE mcle.func_class
  END AS func_class,
	mcle.class_cd,
	mcle.funclist_list_name,
	mcle.item_number,
	mcle.ord_idx,
	ccr.is_check,
	ccr.code,
	ccr.item_name,
	ccr.func_class as func_cls,
	concat(ccr.amount, ccr.unit) as amount_unit,
	ccr.medicine_type,
	ccr.equip_type,
	ccr.occur_date,
	ccr.reg_staff_name
FROM
  checklist_cd_record ccr
LEFT JOIN mst_check_last_exp mcle ON mcle.item_number = ccr.item_number
LEFT JOIN ord_main_info omi ON ccr.ord_no = omi.ord_no
LEFT JOIN medi_ord ON ccr.code = medi_ord.medi_code and ccr.medicine_type = 1 and ccr.func_class = 3
LEFT JOIN medi_mix_ord ON ccr.code = medi_mix_ord.medi_mix_code and ccr.medicine_type = 2 and ccr.func_class = 3
LEFT JOIN equi_ord ON ccr.code = equi_ord.equi_code and ccr.equip_type = 0 and ccr.func_class = 2
LEFT JOIN dia_ord ON ccr.code = dia_ord.dia_code and ccr.equip_type = 1 and ccr.func_class = 2
ORDER BY
  mcle.ord_idx NULLS LAST, ccr.class_cd, medicine_type, equip_type DESC, medi_order, medi_mix_order, equi_order, dia_order', 2, '[{"preview": "透析開始前", "can_calc": "0", "data_code": "dialysis_prog_name", "data_name": "工程", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "dialysis_prog_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "冶療開始前治療条件", "can_calc": "0", "data_code": "list_name", "data_name": "リスト名", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析条件", "can_calc": "0", "data_code": "func_class", "data_name": "データ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "フリーワード", "item": "フリーワード"}, {"code": "1", "disp": "治療条件", "item": "治療条件"}, {"code": "2", "disp": "医療材料", "item": "医療材料"}, {"code": "3", "disp": "投与薬剤", "item": "投与薬剤"}], "data_class": "チェックリスト8", "field_name": "func_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "抗凝固剤", "can_calc": "0", "data_code": "funclist_list_name", "data_name": "名称", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "funclist_list_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "is_check", "data_name": "実施", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未チェック"}, {"code": "1", "disp": "■", "item": "チェック済"}], "data_class": "チェックリスト8", "field_name": "is_check", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤A", "can_calc": "0", "data_code": "item_name", "data_name": "チェック項目", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "item_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "条件", "can_calc": "0", "data_code": "func_cls", "data_name": "種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": ""}, {"code": "1", "disp": "条件", "item": "条件"}, {"code": "2", "disp": "医材", "item": "医材"}, {"code": "3", "disp": "投薬", "item": "投薬"}], "data_class": "チェックリスト8", "field_name": "func_cls", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1個", "can_calc": "0", "data_code": "amount_unit", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/11/11 08:14", "can_calc": "0", "data_code": "occur_date", "data_name": "時刻", "data_type": "DateTime", "conv_table": [], "data_class": "チェックリスト8", "field_name": "occur_date", "disp_format": "yyyy/mm/dd hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "項目チェック者", "data_type": "string", "conv_table": [], "data_class": "チェックリスト8", "field_name": "reg_staff_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：チェックリスト8 @ordNo @facilityCd 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
