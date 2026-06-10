DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-307078
	);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307078, 'with input_code_class as (
	--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
	--1：患者連携情報．連携情報カラム２→依頼医名コード（利用者マスタ．表示用利用者ID）
	--2：固定医師コード1より取得
	--3：固定医師コード2より取得
	--4：固定担当看護師コード1より取得
	--5：固定担当看護師コード2より取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''INPUT_CODE_CLASS''
	limit 1
),
ord_staff_cd as (
  SELECT
    save_2 ->> ''staff_cd'' AS value
  FROM
    pat_coop_detail
  WHERE
    pat_id = @patId
    and  save_2 ->> ''ord_no'' = @ordNo
limit 1
),
pat_staff_cd as (
	select staff_info->>''staff_cd'' as value
	from pat_main,
		lateral json_array_elements(charge_staff_info::json) staff_info
	where pat_id = @patId
		and staff_info->>''is_main'' = ''1''
	order by (staff_info->>''disp_order'')::int
	limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', '2025-04-11 14:29:31.725', '2025-04-22 14:12:51.917', NULL);