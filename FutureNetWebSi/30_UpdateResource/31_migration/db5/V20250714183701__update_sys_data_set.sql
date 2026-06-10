DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106000, -1106001, -1106002, -1106003, -1106004, -1106005);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106000, 'with coop_ini_info as (
--連携設定より取得
select
    coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value,
    info ->> ''key1'' as key1,
    info ->> ''key2'' as key2
from
    mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
    facility_cd = @facilityCd
    and is_del = ''0''
    and coalesce(info ->> ''key0'', '''') = @key0
    and info ->> ''key1'' in (
        ''SCM_COMMON'',
        ''SCM_XRAY_ORDER_SEND''
    )
)
,
user_list as (
--利用者マスタ取得(pre_sqlにて取得)
select
    auth_info ->> ''user_id'' as user_id,
    auth_info ->> ''disp_user_id'' as disp_user_id
from
    json_array_elements(@userList::json) auth_info
)
,
staff_cd_list as (
--患者基本情報
select
    user_list.disp_user_id as disp_user_id,
    row_number() over(order by staff_info ->> ''disp_order'') as row_no
from
    pat_main pm
cross join jsonb_array_elements(pm.charge_staff_info) as staff_info
left join user_list on
    staff_info ->> ''staff_cd'' = user_list.user_id
where
    pm.facility_cd = @facilityCd
    and pm.pat_id = @patId
    and pm.is_del = ''0''
    and staff_info ->> ''is_main'' = ''1''
)
, rad_set_info as (
-- 患者放射線検査DB
select
    info ->> ''rad_set_cd'' as rad_set_cd,
    to_char(prm.reg_rad_date, ''YYYY-MM-DD'') as reg_rad_date,
    prm.ind_user_id
from 
    pat_rad_main prm
cross join lateral json_array_elements(prm.order_rad_set_info::json) info
where
    prm.pat_id = @patId
    and prm.facility_cd = @facilityCd
    and prm.is_del = ''0''
    and prm.rad_result_cd = @ordNo
)
,
rad_item_info as (
--放射線検査セットマスタ
select
    item_info ->> ''item_cd'' as item_cd,
    item_info ->> ''item_class'' as item_class,
    rad_set_info.reg_rad_date,
    rad_set_info.ind_user_id
from
    mst_rad_set mrs
cross join lateral json_array_elements(mrs.rad_item_info::json) item_info
join rad_set_info on
    (rad_set_info.rad_set_cd)::integer = mrs.rad_set_cd
where
    mrs.facility_cd = @facilityCd
    and mrs.is_del = ''0''
)
select
    case
        (select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''USER_ID_FLAG'')
        when ''1'' then (
        --担当医の出力条件
            right(coalesce(
                (select disp_user_id from staff_cd_list where row_no = 1),
                (select disp_user_id from staff_cd_list where row_no = 2),
                (select value from coop_ini_info where key1 = ''SCM_COMMON'' and key2 = ''DEFAULT_DOCTOR''),
                ''''), 6)
            )
        when ''0'' then (
        select
                user_list.disp_user_id
        from
                user_list
        where
                user_list.user_id = rii.ind_user_id::text
        limit 1
        )
    end as user_id,
    (select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''XRAY_IDX_TITLE'') as title,
    rii.reg_rad_date as reg_rad_date,
    (select COUNT(*) from rad_item_info where item_class IN (''部位'', ''修飾'', ''方向'', ''手技'')) as no,
    (select item_cd from rad_item_info where item_class = ''部位'') as part_cd,
    (select item_cd from rad_item_info where item_class = ''修飾'') as mod_cd,
    (select item_cd from rad_item_info where item_class = ''方向'') as direction_cd,
    (select item_cd from rad_item_info where item_class = ''手技'') as procedure_cd
from
rad_item_info rii
limit 1
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携', '2025-06-19 10:57:08.819', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106001, 'WITH get_hosp_pat_id AS (
    SELECT 
        hosp_pat_id as hospPatId
    FROM 
        sys_coop_journal
    WHERE ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
LPAD((SELECT hospPatId FROM get_hosp_pat_id)::text, 8, ''0'') || ''_'' || @fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_オーダーインデックスのdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1106005, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106002, 'WITH get_hosp_pat_id AS (
    SELECT 
        hosp_pat_id as hospPatId
    FROM 
        sys_coop_journal
    WHERE ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
LPAD((SELECT hospPatId FROM get_hosp_pat_id)::text, 8, ''0'') || ''_'' || @fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_処方ヘッダーのdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1106005, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106003, 'WITH get_hosp_pat_id AS (
    SELECT 
        hosp_pat_id as hospPatId
    FROM 
        sys_coop_journal
    WHERE ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
LPAD((SELECT hospPatId FROM get_hosp_pat_id)::text, 8, ''0'') || ''_'' || @fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_実施単位のdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1106005, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106004, 'WITH get_hosp_pat_id AS (
    SELECT 
        hosp_pat_id as hospPatId
    FROM 
        sys_coop_journal
    WHERE ctl_no = @ctlNo
        AND facility_cd = @facilityCd
)
select  
''01'' as detail_id,
LPAD((SELECT hospPatId FROM get_hosp_pat_id)::text, 8, ''0'') || ''_NULL_'' || SUBSTRING(@sharedSysdate FROM 1 FOR 8) || ''_'' || SUBSTRING(@sharedSysdate FROM 9) || ''.'' || @file_extension AS file_name,
'''' AS folder_name', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_ファイル作成終了のdetail特定', '2025-06-19 10:57:13.141', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106005, 'WITH get_coop_ini AS (
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') as value
FROM
  mst_coop_ini as ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info ->> ''is_effect'', '''') = ''1''
    AND COALESCE(info ->> ''key0'', '''') = @key0
    AND COALESCE(info ->> ''key1'', '''') = @key1
    AND COALESCE(info ->> ''key2'', '''') = @key2
)
select 
(select value from get_coop_ini)|| ''_'' || SUBSTRING(@sharedSysdate FROM 1 FOR 8) || ''_'' || SUBSTRING(@sharedSysdate FROM 9) || ''_1'' || ''.'' || @file_extension AS filename
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_RCyyyymmddhhmmss.xxx', '2025-06-19 10:57:13.141', CURRENT_TIMESTAMP, NULL);