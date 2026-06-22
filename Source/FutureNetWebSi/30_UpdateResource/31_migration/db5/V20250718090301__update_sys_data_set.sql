DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106000);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106000, 'with coop_ini_info AS (
--連携設定より取得
select
    coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
    info ->> ''key1'' AS key1,
    info ->> ''key2'' AS key2
from
    mst_coop_ini AS ini
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
user_list AS (
--利用者マスタ取得(pre_sqlにて取得)
select
    auth_info ->> ''user_id'' AS user_id,
    auth_info ->> ''disp_user_id'' AS disp_user_id
from
    json_array_elements(@userList::json) auth_info
)
,
staff_cd_list AS (
--患者基本情報
select
    user_list.disp_user_id AS disp_user_id,
    row_number() over(order by staff_info ->> ''disp_order'') AS row_no
from
    pat_main pm
cross join jsonb_array_elements(pm.charge_staff_info) AS staff_info
left join user_list on
    staff_info ->> ''staff_cd'' = user_list.user_id
where
    pm.facility_cd = @facilityCd
    and pm.pat_id = @patId
    and pm.is_del = ''0''
    and staff_info ->> ''is_main'' = ''1''
)
, rad_set_info AS (
-- 患者放射線検査DB
select
    info ->> ''rad_set_cd'' AS rad_set_cd,
    to_char(prm.reg_rad_date, ''YYYY-MM-DD'') AS reg_rad_date,
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
rad_item_info AS (
--放射線検査セットマスタ
select
    CASE item_info ->> ''item_class''
      WHEN ''部位'' THEN RIGHT(item_info ->> ''item_cd'', 4)
      ELSE RPAD(
             RIGHT(item_info ->> ''item_cd'', 3)
           , 3, '' '')
    END AS item_cd,
    item_info ->> ''item_class'' AS item_class,
    rad_set_info.reg_rad_date,
    rad_set_info.ind_user_id,
    ROW_NUMBER() OVER (PARTITION BY item_info ->> ''item_class'' ORDER BY (item_info ->> ''ctl_no'')::INT ASC) AS rn
from
    mst_rad_set mrs
cross join lateral json_array_elements(mrs.rad_item_info::json) item_info
join rad_set_info on
    (rad_set_info.rad_set_cd)::integer = mrs.rad_set_cd
where
    mrs.facility_cd = @facilityCd
    and mrs.is_del = ''0''
    AND COALESCE(item_info ->> ''item_cd'', '''') <> ''''
    AND item_info ->> ''item_class'' IN (''部位'', ''修飾'', ''方向'', ''手技'')
),
filtered5 AS (
  SELECT item_cd
       , item_class
  FROM rad_item_info
  WHERE rn <= 5
  AND item_class IN (''修飾'', ''方向'', ''手技'')
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
            right(coalesce(
                (select user_list.disp_user_id
                 from   user_list
                 where  user_list.user_id = rii.ind_user_id::text
                 limit  1),
                ''''), 6)
        )
    end AS user_id,
    (select value from coop_ini_info where key1 = ''SCM_XRAY_ORDER_SEND'' and key2 = ''XRAY_IDX_TITLE'') AS title,
    rii.reg_rad_date AS reg_rad_date,
    (select item_cd from rad_item_info where item_class = ''部位'' AND rn = 1) AS part_cd,
    (select STRING_AGG(item_cd, '''' ORDER BY item_cd) from filtered5 where item_class = ''修飾'') AS mod_cd,
    (select STRING_AGG(item_cd, '''' ORDER BY item_cd) from filtered5 where item_class = ''方向'') AS direction_cd,
    (select STRING_AGG(item_cd, '''' ORDER BY item_cd) from filtered5 where item_class = ''手技'') AS procedure_cd
from
rad_item_info rii
limit 1
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダー連携', '2025-06-19 10:57:08.819', CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);