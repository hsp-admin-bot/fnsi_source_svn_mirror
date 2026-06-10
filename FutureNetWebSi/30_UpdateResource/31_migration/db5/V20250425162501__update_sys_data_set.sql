delete from "sys_data_set" where sql_cd in (-307088,-307090);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307090, 'with doctor_code_class as (
-- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 3：固定医師コード1より取得
-- 4：固定医師コード2より取得
-- 5：固定担当看護師コード1より取得
-- 6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
	and info ->> ''key2'' = ''DOCTOR_CODE_CLASS''
limit 1
),
journal_staff_cd as (
select
	user_id as value
from
	sys_coop_journal
where
	ctl_no = @ctlNo
limit 1
),
ord_staff_cd as (
(
      SELECT
        ord.ord_no as ord_no,
        ord.rst_edition_date as up_date_switch,
        rst_charge_user_info ->> ''user_id_1'' as value
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.ord_no as ord_no,
        ord.del_date as up_date_switch,
        rst_charge_user_info ->> ''user_id_1'' as value
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select coalesce(
    case when doctor_code_class.value =''0'' then (select value::text from journal_staff_cd) end,
    case when doctor_code_class.value in (''0'', ''1'') then (select value::text from ord_staff_cd) end,
    case when doctor_code_class.value in (''0'', ''1'', ''2'')then  (select value::text from pat_staff_cd) end, 
    ''''
) as staff_cd
from
    doctor_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 スタッフコード取得用(削除オーダ)', '2025-04-09 17:49:49.600', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307088, 'with doctor_code_class as (
-- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 3：固定医師コード1より取得
-- 4：固定医師コード2より取得
-- 5：固定担当看護師コード1より取得
-- 6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
	and info ->> ''key2'' = ''DOCTOR_CODE_CLASS''
limit 1
)
,
fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)

select
	case doctor_code_class.value::numeric      
        when 0 then -- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then -- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then -- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1) -- 3：固定医師コード1より取得
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1) -- 4：固定医師コード2より取得
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1) -- 5：固定担当看護師コード1より取得
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1) -- 6：固定担当看護師コード2より取得
		else null
	end as doctor_code,
		case doctor_code_class.value::numeric
        when 0 then -- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then -- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then -- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1) -- 3：固定医師コード1より取得
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1) -- 4：固定医師コード2より取得
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1) -- 5：固定担当看護師コード1より取得
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1) -- 6：固定担当看護師コード2より取得
		else null
	end as doctor_name
from
doctor_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医取得用(削除オーダ)', '2025-04-09 17:49:49.600', CURRENT_TIMESTAMP, '[{"sql_cd": -307091, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307092, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);