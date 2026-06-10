DELETE FROM sys_data_set WHERE sql_cd IN (-1106003,-1106002,-1106001,-1106000,-1105009,-1105008,-1105001,-1105000,-1104000,-1103023,-1103018,-1103017,-1103015,-1103013,-1103011,-1103010,-1103008,-1103007,-1103006,-1103005,-1103003,-1103002,-1103001,-1103000,-1102033,-1102027,-1102024,-1102023,-1102022,-1102021,-1102019,-1102018,-1102017,-1102016,-1102015,-1102011,-1102006,-1102003,-1102002,-1100018,-1100016,-1100010);

INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106003, 'select
  case @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	else ''01''
  end AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_実施単位のdetail特定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106002, 'select
  case @crud
    when ''del'' then
      case @dumpResult
        when ''1'' then ''01''
        else ''02''
      end
    else ''01''
  end as detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_処方ヘッダーのdetail特定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106001, 'select  
  CASE @crud
    WHEN ''del'' THEN
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END
    ELSE ''01''
  END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの放射線オーダー_オーダーインデックスのdetail特定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1106000, '-- SQL:-1106000 begin
with coop_ini_info AS (
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
	(
		SELECT
    		info ->> ''rad_set_cd'' AS rad_set_cd,
    		to_char(prm.reg_rad_date, ''YYYY-MM-DD'') AS reg_rad_date,
    		prm.ind_user_id,
    		prm.up_date
		FROM 
    		pat_rad_main prm
			CROSS JOIN LATERAL json_array_elements(prm.order_rad_set_info::json) info
		WHERE
			prm.is_del = ''0''
			AND prm.facility_cd = @facilityCd
    		AND prm.rad_result_cd = @ordNo
    		AND prm.pat_id = @patId
    	ORDER BY 
    		up_date DESC 
    	LIMIT 1
	)
	UNION ALL
	(
		SELECT
	    	info ->> ''rad_set_cd'' AS rad_set_cd,
	    	to_char(prm.reg_rad_date, ''YYYY-MM-DD'') AS reg_rad_date,
	    	prm.ind_user_id,
	    	prm.up_date
		FROM 
	    	pat_rad_main_hst prm
			CROSS JOIN LATERAL json_array_elements(prm.order_rad_set_info::json) info
		WHERE
			prm.is_del = ''0''
			AND prm.facility_cd = @facilityCd
	    	AND prm.rad_result_cd = @ordNo
	    	AND prm.pat_id = @patId
	    ORDER BY 
	    	up_date DESC 
	    LIMIT 1
	)
	ORDER BY 
		up_date DESC NULLS LAST 
	LIMIT 1
)
, rad_item_info AS (
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
limit 1;
-- SQL:-1106000 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'Secom連携_放射線オーダー連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105009, 'select  
  CASE @crud
    WHEN ''del'' THEN
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END
    ELSE ''01''
  END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの検体検査_検体検査出力', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105008, 'select  
  CASE @crud
    WHEN ''del'' THEN
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END
    ELSE ''01''
  END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの検体検査_オーダーインデックス出力', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105001, '-- SQL:-1105001 begin
WITH in_hosp_code AS (
    --検体検査マスタの院内コード参照先
    SELECT
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND coalesce(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
        AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set AS (
    --検体検査マスタの院内コード参照先
    SELECT
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND coalesce(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
        AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, exam_data AS (
    (
        SELECT
            t.set_info ->> ''set_cd'' AS set_cd,
            t.idx AS set_idx,
            pem.up_date AS up_date 
        FROM (
            SELECT
                order_exam_set_info,
                up_date
            FROM
                pat_exam_main
            WHERE
                is_del = ''0''
                AND exam_main_cd = @ordNo
                AND facility_cd = @facilityCd
                AND pat_id = @patId
            ORDER BY 
                up_date DESC
            LIMIT
                1
        ) AS pem
        CROSS JOIN 
            jsonb_array_elements(pem.order_exam_set_info) WITH ordinality AS t(set_info, idx)
        WHERE
            @crud = ''cre''
    )
    UNION ALL
    (
        SELECT
            SPLIT_PART(t, ''|'', 3) AS set_cd,
            row_number() OVER() AS set_idx,
            pcd.up_date AS up_date
        FROM (
            SELECT
                up_date,
                save_2
            FROM 
                pat_coop_detail
            WHERE
                is_del = ''0''
                AND is_disp = ''1''
                AND (save_2->>''ord_no'')::int = @ordNo
                AND save_2->>''coop_cd'' = @coopCd
            ORDER BY
                up_date DESC
            LIMIT
                1
        ) AS pcd
        CROSS JOIN LATERAL
            unnest(string_to_array(pcd.save_2->>''memo'', ''#'')) AS t
        WHERE
            @crud = ''del''
    )
)
, item_count AS (
    --検査セットの院内コードがS始まりの場合取得
    SELECT
        1 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
    WHERE
        LEFT(CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END, 1) = ''S''
        AND is_del = ''0''
        AND is_disp = ''1''
        
        UNION ALL
    --検査項目数を取得
    SELECT
        2 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mei.in_hospital_cd1
            WHEN 2 THEN mei.in_hospital_cd2
            WHEN 3 THEN mei.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
    WHERE
        NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
            END), '''') IS NOT NULL
        AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END), '''') IS NOT NULL
        AND mei.is_del = ''0''
        AND mei.is_disp = ''1''
)
, limit_item AS (
    SELECT
        item_in_hospital_cd AS item_in_hospital_cd
    FROM
        item_count
    ORDER BY
        set_idx,
        item_sort_no,
        item_in_hospital_cd
    LIMIT 250
)
SELECT string_agg(RPAD(RIGHT(item_in_hospital_cd, 8), 8, '' ''), '''') AS item_in_hospital_cd
FROM limit_item
-- SQL:-1105001 end', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_検体検査オーダー連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1105000, '-- SQL:-1105000 begin
WITH conv_order_class AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, pat_exam_main_max AS(
    (
        SELECT
            pem.up_date,
            pem.reg_order_class,
            pem.reg_exam_date,
            pem.ind_user_id,
            pem.order_exam_set_info,
            ''1'' AS pem_boole
        FROM
            pat_exam_main AS pem
        WHERE
            pem.is_del = ''0''
            AND pem.exam_main_cd = @ordNo
            AND pem.facility_cd = @facilityCd
            AND pem.pat_id = @patId
        ORDER BY
            up_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            pemh.up_date,
            pemh.reg_order_class,
            pemh.reg_exam_date,
            pemh.ind_user_id,
            pemh.order_exam_set_info,
            ''2'' AS pem_boole
        FROM
            pat_exam_main_hst AS pemh
        WHERE
            pemh.is_del = ''0''
            AND pemh.exam_main_cd = @ordNo
            AND pemh.facility_cd = @facilityCd
            AND pemh.pat_id = @patId
        ORDER BY
            up_date DESC
        LIMIT 1
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, exam_data AS(
  --登録時検査日時と透析前後フラグの取得
    SELECT
    CASE reg_order_class
        WHEN ''1'' THEN COALESCE((SELECT value FROM conv_order_class WHERE key2 = ''1''), ''1'')
        WHEN ''2'' THEN COALESCE((SELECT value FROM conv_order_class WHERE key2 = ''2''), ''2'')
        ELSE COALESCE((SELECT value FROM conv_order_class WHERE key2 = ''0''), ''0'')
    END AS exam_timing_flag,
    to_char(reg_exam_date, ''YYYY-MM-DD'') as reg_exam_date
    FROM
        pat_exam_main_max
    limit 1
)
, coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_EXAM_ORDER_SEND'',
            ''SCM_COMMON''
        ) 
)
, staff_cd_list AS (
  --担当医の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id,
        ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
    FROM
        pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        staff_info ->> ''staff_cd'' = users ->> ''user_id''
    WHERE
        pm.facility_cd = @facilityCd
        AND pm.pat_id = @patId
        AND pm.is_del = ''0''
        AND staff_info ->> ''is_main'' = ''1''
)
, exam_staff_cd AS (
  --指示者の取得
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        pat_exam_main_max AS pem
    LEFT JOIN jsonb_array_elements(@userList) AS users ON
        pem.ind_user_id = (users ->> ''user_id'')::numeric
)
, in_hosp_code AS (
    --検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
,exam_memo AS (
    SELECT 
        pcd.save_2 ->> ''memo'' AS memo
    FROM 
        pat_coop_detail pcd
    WHERE 
        pcd.facility_cd = @facilityCd
        AND pcd.pat_id = @patId
        AND pcd.save_2 ->> ''coop_cd'' = ''exam_ord''
    ORDER BY 
        pcd.reg_date DESC
    LIMIT 1
)
,exam_set_codes AS (
    SELECT 
        split_part(memo_part, ''|'', 3) AS set_cd
    FROM 
        exam_memo, 
        LATERAL unnest(string_to_array(exam_memo.memo, ''#'')) AS memo_part
)
,exam_set_codes_json AS (
    SELECT
        jsonb_agg(
            jsonb_build_object(
                ''set_cd'',   t.set_cd,
                ''set_name'', NULL
            )
        ) AS order_exam_set_info
    FROM 
        exam_set_codes AS t
)
,exam_set_count AS (
  --項目数の取得（250まで）
    SELECT --検査項目 
        1
    FROM 
        pat_exam_main_max pem
        CROSS JOIN LATERAL (
            SELECT jsonb_array_elements(pem.order_exam_set_info) AS set_info
            WHERE pem.pem_boole = ''1'' AND @crud = ''cre''

            UNION ALL
    
            SELECT jsonb_array_elements(escj.order_exam_set_info) AS set_info
            FROM 
                exam_set_codes_json escj
            WHERE pem.pem_boole = ''1'' AND @crud = ''del''

            UNION ALL

            SELECT jsonb_array_elements(pem.order_exam_set_info) AS set_info
            WHERE pem.pem_boole = ''2''
        ) AS s(set_info)
        LEFT JOIN mst_exam_set mes ON s.set_info ->> ''set_cd'' = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
        WHERE 
            NULLIF((
                CASE (SELECT value FROM in_hosp_code_set)
                    WHEN ''1'' THEN mes.in_hospital_cd1
                    WHEN ''2'' THEN mes.in_hospital_cd2
                    WHEN ''3'' THEN mes.in_hospital_cd3
                    ELSE mes.in_hospital_cd1
                END
            ), '''') IS NOT NULL
            AND NULLIF((
                CASE (SELECT value FROM in_hosp_code)
                    WHEN ''1'' THEN mei.in_hospital_cd1
                    WHEN ''2'' THEN mei.in_hospital_cd2
                    WHEN ''3'' THEN mei.in_hospital_cd3
                    ELSE mei.in_hospital_cd1
                END
            ), '''') IS NOT NULL
            AND mei.is_del = ''0''
            AND mei.is_disp = ''1''

    UNION all
  
    SELECT --検査セット
        1
    FROM 
        pat_exam_main_max pem
        CROSS JOIN LATERAL (
            SELECT jsonb_array_elements(pem.order_exam_set_info) AS set_info
            WHERE pem.pem_boole = ''1'' AND @crud = ''cre''

            UNION ALL

            SELECT jsonb_array_elements(escj.order_exam_set_info) AS set_info
            FROM exam_set_codes_json escj
            WHERE pem.pem_boole = ''1'' AND @crud = ''del''

            UNION ALL

            SELECT jsonb_array_elements(pem.order_exam_set_info) AS set_info
            WHERE pem.pem_boole = ''2''
        ) AS s(set_info)
        LEFT JOIN mst_exam_set mes ON s.set_info ->> ''set_cd'' = mes.exam_set_cd::text
    WHERE 
        LEFT((
            CASE (SELECT value::numeric FROM in_hosp_code_set)
                WHEN 1 THEN mes.in_hospital_cd1
                WHEN 2 THEN mes.in_hospital_cd2
                WHEN 3 THEN mes.in_hospital_cd3
            END
        ), 1) = ''S''
        AND mes.is_del = ''0''
        AND mes.is_disp = ''1''
    LIMIT 250
)
, get_title AS (
    SELECT
        value
        , (
            SELECT MAX(i)
            FROM generate_series(1, char_length(value)) AS i
            WHERE octet_length(CONVERT(substring(value FROM 1 FOR i)::bytea, ''UTF8'', ''SJIS'')::bytea) <= 60
            )  AS cut_index
    FROM coop_ini_info
    WHERE
        key1 = ''SCM_EXAM_ORDER_SEND''
        AND key2 = ''EXAM_IDX_TITLE''
)
, title_limited AS (
    SELECT
        substring(value FROM 1 FOR cut_index) AS value
    FROM get_title
)
SELECT
    exam_timing_flag,
    reg_exam_date,
    (SELECT value FROM title_limited) AS title,
    (SELECT COUNT(*) FROM exam_set_count) AS exam_set_cnt,
    RIGHT(
        CASE (SELECT value::numeric FROM coop_ini_info WHERE key1 = ''SCM_EXAM_ORDER_SEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN 0 THEN 
            (SELECT disp_user_id FROM exam_staff_cd)
        WHEN 1 THEN 
            coalesce(
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1),
            (SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2),
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR''),
            ''''
            )
         END
    , 6) AS user_id
FROM 
    exam_data
-- SQL:-1105000 end', '2', '[]', '0', '{"applications": [4]}', NULL, 'Secom連携_検体検査オーダー連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1104000, '-- SQL: -1104000 begin
WITH ord_main_max AS(
    (
        SELECT
            ord.rst_edition_date AS up_date,
            ord.rst_bed_cd,
            ord.ind_kur_cd,
            ord.treat_date
        FROM
            ord_main AS ord
        WHERE 
            ord.ord_no=@ordNo
            AND ord.facility_cd = @facilityCd
    )
    UNION ALL
    (
        SELECT
            ord.del_date AS up_date,
            ord.rst_bed_cd,
            ord.ind_kur_cd,
            ord.treat_date
        FROM
            ord_main_restore AS ord
        WHERE 
            ord.ord_no=@ordNo
            AND ord.facility_cd = @facilityCd
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
),select_ord_main AS(
SELECT 
    CASE 
        WHEN mbe.bed_name IS NULL THEN RPAD('' '', 40, '' '')
        ELSE REPLACE(mbe.bed_name, '','', ''_'')
    END AS bed_name
    ,to_char(
         to_timestamp(ord.treat_date || mkr.kur_standard_start_time , ''YYYYMMDDHH24MISS''),
         ''YYYY/MM/DD HH24:MI:SS''
       ) AS appointment_date
FROM
ord_main_max AS ord
	LEFT OUTER JOIN mst_bed AS mbe 
		ON mbe.bed_cd = ord.rst_bed_cd 
	LEFT OUTER JOIN mst_kur AS mkr 
		ON mkr.kur_cd = ord.ind_kur_cd 
)
,select_sequence_no as(
SELECT 
  COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
FROM pat_coop_detail
WHERE
  save_2 ->> ''ord_no'' = @ordNo
  AND save_2 ->> ''coop_cd'' =''ind_dial''
  AND facility_cd = @facilityCd 
  ORDER BY pat_coop_detail.up_date 
  LIMIT 1
)
SELECT
(SELECT bed_name FROM select_ord_main) AS bed_name,
(SELECT appointment_date FROM select_ord_main) AS appointment_date,
(SELECT sequence_no FROM select_sequence_no) AS sequence_no
-- SQL: -1104000 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム　再来受付', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103023, '-- SQL: -1103023 begin
WITH memo AS (
    SELECT
        split_part(save_2 ->> ''memo'', ''#'', 3) AS memo
    FROM
        pat_coop_detail AS detail
    WHERE
        facility_cd = @facilityCd
        AND pat_id = @patId
        AND (save_2 ->> ''ord_no'')::integer = @ordNo
        AND (save_2 ->> ''coop_cd'') = @coopCd
    ORDER BY
        up_date DESC
    LIMIT 1
)
SELECT 
    TO_CHAR(
        TO_DATE(
            split_part(memo, ''|'', 2),
            ''YYYYMMDD''
        ), ''YYYY-MM-DD''
    ) AS send_day,
    TO_CHAR(
        TO_TIMESTAMP(
            split_part(memo, ''|'', 3),
            ''HH24MISS''
        ) + make_interval(secs => (@rpNo::integer - 1))
        , ''HH24:MI:SS''
    ) AS seq_no
FROM
    memo
-- SQL: -1103023 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携_注射実績 送信履歴メモから発生日/SEQ番号の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103018, '-- SQL: -1103018 begin
WITH RECURSIVE coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) AS info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
),
ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
),
ini_value AS(
    --連携設定取得値
    SELECT
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_MEDICINE''
        ) AS hosp_get_mst_medicine,
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_PROCEDURE''
        ) AS hosp_get_mst_procedure
),
mst_medi_mix AS (
    --調整薬剤マスタ
    SELECT
        t1.idx AS idx,
        medicine_mix_cd AS mix_cd,
        t1.info ->> ''solvent'' AS solvent,
        t1.info ->> ''cd'' AS medi_cd,
        t1.info ->> ''amount'' AS amount,
        mst.unit AS unit,
        mst.is_shot AS is_shot,
        mst.in_hospital_cd_1 AS in_hospital_cd_1,
        mst.in_hospital_cd_2 AS in_hospital_cd_2,
        mst.in_hospital_cd_3 AS in_hospital_cd_3,
        mst.in_hospital_cd_4 AS in_hospital_cd_4,
        mst.is_disp AS is_disp,
        mst.is_del AS is_del
    FROM
        mst_medicine_mix AS mix
        CROSS JOIN LATERAL json_array_elements(mix.mix_info :: json) WITH ORDINALITY AS t1(info, idx)
        INNER JOIN mst_medicine AS mst 
            ON
                mst.medicine_cd :: text = info ->> ''cd''
                AND mst.is_shot = ''1''
                AND mst.is_del = ''0''
                AND mst.is_disp = ''1''
    WHERE
        mix.is_del = ''0''
        AND mix.facility_cd = @facilityCd
        AND mst.facility_cd = @facilityCd
),
do_ord_main AS (
    (
        SELECT
            res.del_date AS up_date_switch,
            res.rst_medi_info AS rst_medi_info,
            res.treat_date :: TIMESTAMP AS treat_date
        FROM
            ord_main_restore AS res
            JOIN sys_coop_journal AS journal
                ON
                    res.ord_no = journal.ord_no
        WHERE
            res.ord_no = @ordNo
            AND res.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= res.del_date
        ORDER BY
            res.del_date DESC
        LIMIT
            1
    )
    UNION
    (
        SELECT
            main.rst_edition_date AS up_date_switch,
            main.rst_medi_info AS rst_medi_info,
            main.treat_date :: TIMESTAMP AS treat_date
        FROM
            ord_main AS main
        WHERE
            main.ord_no = @ordNo
            AND main.facility_cd = @facilityCd
    )
    ORDER BY
        up_date_switch DESC NULLS LAST
    LIMIT
        1
), medi_indo AS (
    -- 投与薬剤情報
    SELECT
        t1.idx AS idx,
        t1.medi_info ->> ''cd'' AS mst_cd,
        CASE
            WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate)
            AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN CASE
                WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
                END
                WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
                END
            END
            WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
            END
            WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
            END
            ELSE NULL
        END AS pro_hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_medi.in_hospital_cd_1
                    WHEN ''2'' THEN mst_medi.in_hospital_cd_2
                    WHEN ''3'' THEN mst_medi.in_hospital_cd_3
                    WHEN ''4'' THEN mst_medi.in_hospital_cd_4
                    ELSE NULL
                END
                WHEN ''2'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_mix.in_hospital_cd_1
                    WHEN ''2'' THEN mst_mix.in_hospital_cd_2
                    WHEN ''3'' THEN mst_mix.in_hospital_cd_3
                    WHEN ''4'' THEN mst_mix.in_hospital_cd_4
                    ELSE NULL
                END
            END
        END AS hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN (medi_info ->> ''amount'') :: numeric
                WHEN ''2'' THEN CASE
                    mst_mix.solvent
                    WHEN ''0'' THEN (medi_info ->> ''amount'') :: numeric * mst_mix.amount :: numeric
                    WHEN ''1'' THEN mst_mix.amount :: numeric
                END
                ELSE 0
            END
        END AS amount,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.unit
                WHEN ''2'' THEN mst_mix.unit
            END
        END AS unit,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.is_shot
                WHEN ''2'' THEN mst_mix.is_shot
            END
        END AS is_shot,
        CASE
            t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.is_disp
            WHEN ''2'' THEN mst_mix.is_disp
        END AS is_disp
    FROM
        do_ord_main om
        CROSS JOIN LATERAL json_array_elements(om.rst_medi_info :: json) WITH ORDINALITY AS t1(medi_info, idx)
        LEFT JOIN mst_medicine AS mst_medi
            ON mst_medi.medicine_cd :: text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type'' :: text = ''1''
                AND mst_medi.facility_cd = @facilityCd
        LEFT JOIN mst_medi_mix AS mst_mix
            ON
                mst_mix.mix_cd :: text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type'' :: text = ''2''
        LEFT JOIN mst_procedure AS mst_pro
            ON
                mst_pro.procedure_cd :: text = t1.medi_info ->> ''procedure_cd''
                AND mst_pro.facility_cd = @facilityCd
        CROSS JOIN ini_value
    WHERE
        medi_info ->> ''effect_flg'' = ''1''
        AND (
            (
                medi_info ->> ''medicine_type'' :: text = ''1''
                AND mst_medi.is_del = ''0''
            )
            OR (
                medi_info ->> ''medicine_type'' :: text = ''2''
                AND mst_mix.is_del = ''0''
            )
        )
) 
,
memo_text AS (
    -- 送信履歴メモ.memoから取得
    SELECT
        save_2 ->> ''memo'' AS memo
    FROM
        pat_coop_detail
    WHERE
        pat_id = @patId
        AND save_2 ->> ''coop_cd'' = ''ind_dial''
        AND pat_coop_detail.facility_cd = @facilityCd
        AND save_2 ->> ''ord_no'' = @ordNo :: text
    ORDER BY
        up_date DESC
    LIMIT
        1
), bounds AS (
    SELECT
        memo,
        POSITION(''#I|'' IN memo) AS i_pos,
        POSITION(''#K'' IN memo) AS k_pos
    FROM
        memo_text
),
extracted AS (
    SELECT
        substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
    FROM
        bounds
),
split_parts AS (
    SELECT
        string_to_array(i_segment, ''|'') AS parts
    FROM
        extracted
),
item_info AS (
    SELECT
        parts [i] AS item_value,
        i - 4 AS item_index
    FROM
        split_parts,
        generate_series(5, CARDINALITY(parts)) AS i
),
get_items AS (
    SELECT
        item_index,
        item_value,
        substring(item_value FROM 1 FOR 2) AS rp_no,
        substring(item_value FROM 3 FOR 2) AS technique,
        substring(item_value FROM 5 FOR 2) AS med_no,
        substring(item_value FROM 7 FOR 6) AS med_code
    FROM
        item_info
), 
get_items_total AS (
    -- 同手技同薬剤コードは一つだけ出力
    SELECT
        DISTINCT ON (technique, med_code) *
    FROM
        get_items
    ORDER BY
        technique,
        med_code,
        item_index
), 
medi_indo_mi_cut AS (
    -- コード桁数処理
    SELECT
        *,
        CASE
            WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
            ELSE (
                SELECT
                    substring(hosp_cd FROM MIN(i))
                FROM
                    generate_series(1, char_length(hosp_cd)) AS i
                WHERE
                    octet_length(substring(hosp_cd FROM i)) <= 6
            )
        END AS hosp_cd_trimmed,
        RIGHT(pro_hosp_cd, 2) AS pro_hosp_cd_trimmed
    FROM
        medi_indo
),
unit_choice AS (
    SELECT
    	DISTINCT
    		ON (hosp_cd_trimmed, pro_hosp_cd_trimmed) hosp_cd_trimmed,
        pro_hosp_cd,
        unit
    FROM
        medi_indo_mi_cut
    WHERE
        is_shot = ''1''
        AND is_disp = ''1''
    ORDER BY
        hosp_cd_trimmed,
        pro_hosp_cd_trimmed,
        idx
),
select_seq AS (
    SELECT
        gi.rp_no :: numeric AS rp_no,
        gi.med_no :: numeric AS medi_no,
        mi.hosp_cd_trimmed AS medi_cd,
        LEAST(SUM(TRUNC(mi.amount, 2) :: FLOAT8), 9999999.99) :: text AS amount,
        MIN(ini_unit.value) AS unit
    FROM
        get_items_total gi
        INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6, '' '')
        AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2, '' '')
        LEFT JOIN unit_choice uc ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
        AND mi.pro_hosp_cd = uc.pro_hosp_cd
        LEFT JOIN ini_unit ON uc.unit = ini_unit.key2
    WHERE
        mi.is_shot = ''1''
        AND mi.is_disp = ''1''
    GROUP BY
        gi.rp_no,
        gi.med_no,
        mi.hosp_cd_trimmed
    ORDER BY
        rp_no,
        medi_no
),
raw_data AS (
    SELECT
        @contentJson :: jsonb AS data
),
ROWS AS (
    SELECT
        JSONB_ARRAY_ELEMENTS(data) AS ROW
    FROM
        raw_data
),
rp_no_switch AS (
    (
        SELECT
            (ROW ->> 8) :: numeric AS rp_no
        FROM
            ROWS
        WHERE
            @crud = ''del''
            AND @dumpResult = ''1''
    )
    UNION ALL
    (
        SELECT
            rp_no
        FROM
            select_seq
        WHERE
            @crud = ''del''
            AND @dumpResult <> ''1''
    )
)

SELECT DISTINCT
	''01'' AS detail_id,
    rp_no
FROM
    rp_no_switch
WHERE
    EXISTS (SELECT 1 FROM rp_no_switch)
ORDER BY
    rp_no
-- SQL: -1103018 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績(削除電文用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103017, '-- SQL: -1103017 begin
WITH raw_data AS (
	SELECT @contentJson::jsonb AS data
)
,rows AS (
	SELECT JSONB_ARRAY_ELEMENTS(data) AS row
	FROM raw_data
)

-- このSQLでは処置実績ファイルのファイル出力有無を判断します。
-- ファイル出力を行う場合は1件のレコードを返却します。
-- ファイル出力を行わない場合はレコードを返却しません。
SELECT 
    ''01'' AS detail_id
WHERE (1 = 1
        AND @dumpResult::TEXT = ''1'' 
        AND EXISTS (SELECT 1 FROM rows)
    ) 
    OR @dumpResult::TEXT = ''''
-- SQL: -1103017 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績(削除電文用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103015, '-- 実績の送信履歴メモ
WITH
  get_ini AS (
    SELECT
      coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
      info ->> ''key2'' as key2
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE
      facility_cd = @facilityCd
      AND is_del = ''0''
      AND coalesce(info ->> ''key0'', '''') = @key0
      AND info ->> ''key1'' = ''SCM_DIALYSISSEND''
      AND info ->> ''key2'' IN (''INJECT_IDX_FILE_STR'',''TREAT_IDX_FILE_STR'',''KARTE_FILE_STR'')
  )
,  distribute_setting AS (
  SELECT COALESCE(
      mcd.distribute_setting->''protocolInfo''->>''fileNameDelimiter'',
      ''|''
    ) AS file_name_delimiter,
    COALESCE(
      REPLACE(
        mcd.distribute_setting->''protocolInfo''->>''fileSplitDelimiterFormat'',
        ''%s'',
        ''%''
      ),
      ''----- % -----''
    ) AS file_split_delimite_format
  FROM mst_coop_distribute mcd
  WHERE mcd.facility_cd = @facilityCd
    AND coop_cd = @coopCd
    AND is_del = ''0''
)
, get_sys_coop_journal AS (
    SELECT
      ctl_no,
      crud,
      string_to_array(dump_path, ds.file_name_delimiter) AS path_array,
      array_length(string_to_array(dump_path, ds.file_name_delimiter), 1) AS file_count
    FROM sys_coop_journal
    CROSS JOIN distribute_setting ds
    WHERE ctl_no = @ctlNo
  )
, inject_match_count AS (
    SELECT
      j.ctl_no,
      COUNT(*) AS rp_count
    FROM get_sys_coop_journal j,
         get_ini i,
         unnest(j.path_array) AS file
    WHERE file LIKE ''%'' || i.value || ''%''
      AND i.key2 = ''INJECT_IDX_FILE_STR''
    GROUP BY j.ctl_no
  )
, classified_files AS (
  SELECT
    j.ctl_no,
    j.crud,
    MAX(CASE WHEN j.path_array[i] LIKE ''%'' || ti.value || ''%'' THEN j.path_array[i] END) AS treat_file,
    MIN(CASE WHEN j.path_array[i] LIKE ''%'' || ii.value || ''%'' THEN j.path_array[i] END) AS inject_file,
    MAX(CASE WHEN j.path_array[i] LIKE ''%'' || ki.value || ''%'' THEN j.path_array[i] END) AS med_file
  FROM get_sys_coop_journal j
  JOIN get_ini ti ON ti.key2 = ''TREAT_IDX_FILE_STR''
  JOIN get_ini ki ON ki.key2 = ''KARTE_FILE_STR''
  JOIN get_ini ii ON ii.key2 = ''INJECT_IDX_FILE_STR''
  , generate_subscripts(j.path_array, 1) AS i
  GROUP BY j.ctl_no, j.crud
)
, decoded AS (
    SELECT ctl_no, convert_from(dump, ''SHIFT_JIS'') AS text_data
    FROM sys_coop_journal
    WHERE ctl_no = @ctlNo
  )
, lines AS (
    SELECT
      l.ctl_no,
      row_number() OVER (PARTITION BY l.ctl_no ORDER BY ordinality) AS rn,
      line
    FROM decoded l,
    LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
  )
, matched_treat AS (
  SELECT
    l1.ctl_no,
    l1.rn,
    ''treat'' AS file_type
  FROM lines l1
  JOIN classified_files cf ON l1.ctl_no = cf.ctl_no
  JOIN distribute_setting ds ON TRUE
  WHERE cf.treat_file IS NOT NULL
    AND l1.line = REPLACE(ds.file_split_delimite_format, ''%'', cf.treat_file)
)
, matched_inject AS (
  SELECT
    l1.ctl_no,
    l1.rn,
    ''inject'' AS file_type
  FROM lines l1
  JOIN classified_files cf ON l1.ctl_no = cf.ctl_no
  JOIN distribute_setting ds ON TRUE
  WHERE cf.inject_file IS NOT NULL
    AND l1.line = REPLACE(ds.file_split_delimite_format, ''%'', cf.inject_file)
)
, matched_med AS (
  SELECT
    l1.ctl_no,
    l1.rn,
    ''med'' AS file_type
  FROM lines l1
  JOIN classified_files cf ON l1.ctl_no = cf.ctl_no
  JOIN distribute_setting ds ON TRUE
  WHERE cf.med_file IS NOT NULL
    AND l1.line = REPLACE(ds.file_split_delimite_format, ''%'', cf.med_file)
)
, treat_data AS (
    SELECT
      l.ctl_no,
      array_agg(field ORDER BY ordinality) AS cols
    FROM lines l
    JOIN matched_treat mt ON l.ctl_no = mt.ctl_no AND l.rn = mt.rn + 1
    CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
    GROUP BY l.ctl_no, l.rn
  )
, med_data AS (
    SELECT
      l.ctl_no,
      array_agg(field ORDER BY ordinality) AS cols
    FROM lines l
    JOIN matched_med mm ON l.ctl_no = mm.ctl_no AND l.rn = mm.rn + 1
    CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
    GROUP BY l.ctl_no, l.rn
  )
, inj_data AS (
    SELECT
      l.ctl_no,
      array_agg(field ORDER BY ordinality) AS cols
    FROM lines l
    JOIN matched_inject mi ON l.ctl_no = mi.ctl_no AND l.rn = mi.rn + 1
    CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
    GROUP BY l.ctl_no, l.rn
  )
, create_memo AS (
    SELECT json_build_object(
      ''coop_cd'', ''rst_dial'',
      ''ord_no'', @ordNo::text,
      ''memo'',
        ''#T|'' ||  to_char(to_date(nullif(treat_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'') || ''|'' || to_char(to_timestamp(nullif(treat_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'') ||
        ''#I|'' ||  COALESCE(to_char(to_date(nullif(inj_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD''), '''') || ''|'' || COALESCE(to_char(to_timestamp(nullif(inj_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS''), '''') || ''|'' || COALESCE(imc.rp_count::text, ''0'') ||
        ''#K|'' || to_char(to_date(nullif(med_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'') || ''|'' || to_char(to_timestamp(nullif(med_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
    ) AS result_json
    FROM treat_data
    LEFT JOIN LATERAL (
      SELECT * FROM inj_data WHERE inj_data.ctl_no = treat_data.ctl_no LIMIT 1
    ) inj_data ON true
    LEFT JOIN LATERAL (
      SELECT * FROM med_data WHERE med_data.ctl_no = treat_data.ctl_no LIMIT 1
    ) med_data ON true
    LEFT JOIN inject_match_count imc ON treat_data.ctl_no = imc.ctl_no
  )
  INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::bigint,
    ''{"pkg": "Secom"}''::jsonb,
    (SELECT result_json FROM create_memo),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''', '2', '[]', '0', '{"applications": [4]}', NULL, '透析実績連携_送信履歴メモ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103013, '-- SQL: -1103013 begin
WITH RECURSIVE coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) AS info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
),
ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
),
ini_value AS(
    --連携設定取得値
    SELECT
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_MEDICINE''
        ) AS hosp_get_mst_medicine,
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_PROCEDURE''
        ) AS hosp_get_mst_procedure
),
mst_medi_mix AS (
    --調整薬剤マスタ
    SELECT
        t1.idx AS idx,
        medicine_mix_cd AS mix_cd,
        t1.info ->> ''solvent'' AS solvent,
        t1.info ->> ''cd'' AS medi_cd,
        t1.info ->> ''amount'' AS amount,
        mst.unit AS unit,
        mst.is_shot AS is_shot,
        mst.in_hospital_cd_1 AS in_hospital_cd_1,
        mst.in_hospital_cd_2 AS in_hospital_cd_2,
        mst.in_hospital_cd_3 AS in_hospital_cd_3,
        mst.in_hospital_cd_4 AS in_hospital_cd_4,
        mst.is_disp AS is_disp,
        mst.is_del AS is_del
    FROM
        mst_medicine_mix AS mix
        CROSS JOIN LATERAL json_array_elements(mix.mix_info::json) WITH ORDINALITY AS t1(info, idx)
        INNER JOIN mst_medicine AS mst
            ON
                mst.medicine_cd::text = info ->> ''cd''
                AND mst.is_shot = ''1''
                AND mst.is_del = ''0''
                AND mst.is_disp = ''1''
    WHERE
        mix.is_del = ''0''
        AND mix.facility_cd = @facilityCd
        AND mst.facility_cd = @facilityCd
),
do_ord_main AS (
    (
        SELECT
            res.del_date AS up_date_switch,
            res.rst_medi_info AS rst_medi_info,
            res.treat_date::TIMESTAMP AS treat_date
        FROM
            ord_main_restore AS res
            JOIN sys_coop_journal AS journal
                ON
                    res.ord_no = journal.ord_no
        WHERE
            res.ord_no = @ordNo
            AND res.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= res.del_date
        ORDER BY
            res.del_date DESC
        LIMIT
            1
    )
    UNION
    (
        SELECT
            main.rst_edition_date AS up_date_switch,
            main.rst_medi_info AS rst_medi_info,
            main.treat_date::TIMESTAMP AS treat_date
        FROM
            ord_main AS main
        WHERE
            main.ord_no = @ordNo
            AND main.facility_cd = @facilityCd
    )
    ORDER BY
        up_date_switch DESC NULLS LAST
    LIMIT
        1
), medi_indo AS (
    -- 投与薬剤情報
    SELECT
        t1.idx AS idx,
        t1.medi_info ->> ''cd'' AS mst_cd,
        CASE
            WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate)
            AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN CASE
                WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
                END
                WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
                END
            END
            WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
            END
            WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
            END
            ELSE NULL
        END AS pro_hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_medi.in_hospital_cd_1
                    WHEN ''2'' THEN mst_medi.in_hospital_cd_2
                    WHEN ''3'' THEN mst_medi.in_hospital_cd_3
                    WHEN ''4'' THEN mst_medi.in_hospital_cd_4
                    ELSE NULL
                END
                WHEN ''2'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_mix.in_hospital_cd_1
                    WHEN ''2'' THEN mst_mix.in_hospital_cd_2
                    WHEN ''3'' THEN mst_mix.in_hospital_cd_3
                    WHEN ''4'' THEN mst_mix.in_hospital_cd_4
                    ELSE NULL
                END
            END
        END AS hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
                WHEN ''2'' THEN CASE
                    mst_mix.solvent
                    WHEN ''0'' THEN (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
                    WHEN ''1'' THEN mst_mix.amount::numeric
                END
                ELSE 0
            END
        END AS amount,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.unit
                WHEN ''2'' THEN mst_mix.unit
            END
        END AS unit,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.is_shot
                WHEN ''2'' THEN mst_mix.is_shot
            END
        END AS is_shot,
        CASE
            t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.is_disp
            WHEN ''2'' THEN mst_mix.is_disp
        END AS is_disp
    FROM
        do_ord_main om
        CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
        LEFT JOIN mst_medicine AS mst_medi
            ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type''::text = ''1''
                AND mst_medi.facility_cd = @facilityCd
        LEFT JOIN mst_medi_mix AS mst_mix
            ON
                mst_mix.mix_cd::text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type''::text = ''2''
        LEFT JOIN mst_procedure AS mst_pro
            ON
                mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd''
                AND mst_pro.facility_cd = @facilityCd
        CROSS JOIN ini_value
    WHERE
        medi_info ->> ''effect_flg'' = ''1''
        AND (
            (
                medi_info ->> ''medicine_type''::text = ''1''
                AND mst_medi.is_del = ''0''
            )
            OR (
                medi_info ->> ''medicine_type''::text = ''2''
                AND mst_mix.is_del = ''0''
            )
        )
)
,
memo_text AS (
    -- 送信履歴メモ.memoから取得
    SELECT
        save_2 ->> ''memo'' AS memo
    FROM
        pat_coop_detail
    WHERE
        pat_id = @patId
        AND save_2 ->> ''coop_cd'' = ''ind_dial''
        AND pat_coop_detail.facility_cd = @facilityCd
        AND save_2 ->> ''ord_no'' = @ordNo::text
    ORDER BY
        up_date DESC
    LIMIT
        1
), bounds AS (
    SELECT
        memo,
        POSITION(''#I|'' IN memo) AS i_pos,
        POSITION(''#K'' IN memo) AS k_pos
    FROM
        memo_text
),
extracted AS (
    SELECT
        substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
    FROM
        bounds
),
split_parts AS (
    SELECT
        string_to_array(i_segment, ''|'') AS parts
    FROM
        extracted
),
item_info AS (
    SELECT
        parts [i] AS item_value,
        i - 4 AS item_index
    FROM
        split_parts,
        generate_series(5, CARDINALITY(parts)) AS i
),
get_items AS (
    SELECT
        item_index,
        item_value,
        substring(item_value FROM 1 FOR 2) AS rp_no,
        substring(item_value FROM 3 FOR 2) AS technique,
        substring(item_value FROM 5 FOR 2) AS med_no,
        substring(item_value FROM 7 FOR 6) AS med_code
    FROM
        item_info
),
get_items_total AS (
    -- 同手技同薬剤コードは一つだけ出力
    SELECT
        DISTINCT ON (technique, med_code) *
    FROM
        get_items
    ORDER BY
        technique,
        med_code,
        item_index
),
medi_indo_mi_cut AS (
    -- コード桁数処理
    SELECT
        *,
        CASE
            WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
            ELSE (
                SELECT
                    substring(hosp_cd FROM MIN(i))
                FROM
                    generate_series(1, char_length(hosp_cd)) AS i
                WHERE
                    octet_length(substring(hosp_cd FROM i)) <= 6
            )
        END AS hosp_cd_trimmed,
        RIGHT(pro_hosp_cd, 2) AS pro_hosp_cd_trimmed
    FROM
        medi_indo
),
unit_choice AS (
    SELECT
        DISTINCT
            ON (hosp_cd_trimmed, pro_hosp_cd_trimmed) hosp_cd_trimmed,
        pro_hosp_cd,
        unit
    FROM
        medi_indo_mi_cut
    WHERE
        is_shot = ''1''
        AND is_disp = ''1''
    ORDER BY
        hosp_cd_trimmed,
        pro_hosp_cd_trimmed,
        idx
),
select_seq AS (
    SELECT
        gi.rp_no::numeric AS rp_no,
        gi.med_no::numeric AS medi_no,
        mi.hosp_cd_trimmed AS medi_cd,
        LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
        MIN(ini_unit.value) AS unit
    FROM
        get_items_total gi
        INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6, '' '')
        AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2, '' '')
        LEFT JOIN unit_choice uc ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
        AND mi.pro_hosp_cd = uc.pro_hosp_cd
        LEFT JOIN ini_unit ON uc.unit = ini_unit.key2
    WHERE
        mi.is_shot = ''1''
        AND mi.is_disp = ''1''
    GROUP BY
        gi.rp_no,
        gi.med_no,
        mi.hosp_cd_trimmed
    ORDER BY
        rp_no,
        medi_no
),
ord_main_switch AS(
    -- ord_mainまたはord_main_restoreから、当連携処理のord_noに該当するの最新のレコードを取得する
    (
        SELECT
            TRUE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.rst_edition_date AS up_date_switch
        FROM
            ord_main ord
        WHERE
            ord.ord_no = @ordNo
            AND is_del = ''0''
    )
    UNION
    (
        SELECT
            FALSE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.del_date AS up_date_switch
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
        LIMIT
            1
    )
    ORDER BY
        up_date_switch DESC NULLS LAST
    LIMIT
        1
), inject_cancel_file_output_flg AS (
    -- 注射中止ファイル出力有無を判断するフラグを取得する
    SELECT
        CASE
            -- 処理対象ord_noに紐づく最新のオーダーがord_main_restoreから取得できた場合
            -- 注射中止ファイルを出力する
            WHEN oms.is_from_ord_main = FALSE THEN TRUE -- それ以外の場合
            -- rst_dialysis_stateが存在して、ord_main_restore.del_dateよりも最新の場合（実績が更新されている）
            -- 注射中止ファイルを出力しない
            ELSE FALSE
        END AS value
    FROM
        ord_main_switch AS oms
),
raw_data AS (
    SELECT
        @contentJson::jsonb AS data
),
ROWS AS (
    SELECT
        JSONB_ARRAY_ELEMENTS(data) AS ROW
    FROM
        raw_data
),
get_rp_no AS (
    SELECT
        ROW ->> 8 AS rp_no
    FROM
        ROWS
),
rp_no_switch AS(
    (
        SELECT
            (ROW ->> 8)::numeric AS rp_no
        FROM
            ROWS
        WHERE
            @crud = ''del''
            AND @dumpResult = ''1''
    )
    UNION ALL
    (
        SELECT
            rp_no
        FROM
            select_seq
        WHERE
            @crud = ''del''
            AND @dumpResult <> ''1''
    )
)
SELECT
    ''01'' AS detail_id,
    rp_no AS rp_no
FROM
    rp_no_switch
WHERE(
    SELECT value FROM inject_cancel_file_output_flg
)
ORDER BY
    rp_no::int
-- SQL: -1103013 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射中止ファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103011, '-- SQL: -1103011 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no
-- SQL: -1103011 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績ファイル_処置項目', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103010, '-- SQL: -1103010 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no
-- SQL: -1103010 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 注射実績ファイル_オーダーインデックス', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103008, '-- SQL: -1103008 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103008 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置項目', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103007, '-- SQL: -1103007 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103007 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置単位', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103006, '-- SQL: -1103006 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103006 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置ヘッダー', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103005, '-- SQL: -1103005 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103005 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103003, E'-- SQL: -1103003 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_CONV_UNIT_MEDI'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_DIALYSISSEND''
    )
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_ADDITION'') AS hosp_get_mst_addition,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_PROCEDURE_CODE'') AS oxgen_procedure_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_MEDI_CODE'') AS oxgen_medi_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_CONVERT'') AS treat_convert,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''ADDITION_CD'') AS addition_cd
)
, addition_cd_list as (
SELECT
  UNNEST(string_to_array(addition_cd, '','')) AS set_value
FROM ini_value
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot IS DISTINCT FROM ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_treatment_cd as rst_treatment_cd,
  res.rst_cond_info as rst_cond_info,
  res.rst_medi_info AS rst_medi_info,
  res.rst_treatment_info as rst_treatment_info,
  res.rst_equip_info as rst_equip_info,
  res.addition_info as addition_info,
  res.treat_date::TIMESTAMP AS treat_date,
  res.rst_start_date AS rst_start_date,
  res.rst_end_date AS rst_end_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND res.pat_id = @patId
  AND res.is_del = ''0''
  AND res.ord_no = journal.ord_no
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_treatment_cd as rst_treatment_cd,
  main.rst_cond_info as rst_cond_info,
  main.rst_medi_info AS rst_medi_info,
  main.rst_treatment_info as rst_treatment_info,
  main.rst_equip_info as rst_equip_info,
  main.addition_info as addition_info,
  main.treat_date::TIMESTAMP AS treat_date,
  main.rst_start_date AS rst_start_date,
  main.rst_end_date AS rst_end_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
  AND main.pat_id = @patId
  AND main.is_del = ''0''
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, treat_convert_part AS (
-- 連携設定.治療方法変換設定をテーブル化
SELECT
  key2 AS hosp_cd,
  split_part(t1.set_value, '','', 1) AS dialysis_time,
  split_part(t1.set_value, '','', 2) AS convert_cd,
  t1.no
FROM
  (SELECT
    key2
    , UNNEST(string_to_array(value, ''_'')) AS set_value
    ,generate_subscripts(string_to_array(value, ''_''), 1) as no
  FROM
    coop_ini_info ini
  WHERE key1 = ''SCM_DIALYSISSEND''
 ) t1
)
, parsed_ranges_check AS (
-- 治療方法変換設定チェック
SELECT distinct
  hosp_cd,
  ''NG'' AS check_result
FROM (
  SELECT
    CASE WHEN dialysis_time ~ ''^\\\\d+(\\\\.\\\\d+)?$''
    THEN NULLIF(dialysis_time, '''')
    ELSE NULL
    END AS lower_bound,
    NULLIF(convert_cd, '''') AS value,
    treat_convert_part.hosp_cd
  FROM treat_convert_part
) check_part
WHERE lower_bound IS NULL
  OR value IS NULL
)
, treat_convert AS (
    SELECT
        treat_convert_part.hosp_cd,
        convert_cd AS convert_cd,
        dialysis_time::numeric AS lower_bound,
        lead(dialysis_time::numeric, 1, 100000) OVER (PARTITION BY treat_convert_part.hosp_cd ORDER BY dialysis_time::numeric) -0.0001 AS upper_bound
    FROM treat_convert_part
    LEFT JOIN parsed_ranges_check on treat_convert_part.hosp_cd = parsed_ranges_check.hosp_cd
    WHERE parsed_ranges_check.check_result IS NULL
)
, ord_main_tre AS (
-- 治療方法コード
SELECT
  1000 AS temp_no,
  om.rst_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
        CASE
          WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_treatment
              WHEN ''1'' THEN mt.in_hospital_cd_a1
              WHEN ''2'' THEN mt.in_hospital_cd_a2
              WHEN ''3'' THEN mt.in_hospital_cd_a3
              WHEN ''4'' THEN mt.in_hospital_cd_a4
            END
          WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_treatment
              WHEN ''1'' THEN mt.in_hospital_cd_b1
              WHEN ''2'' THEN mt.in_hospital_cd_b2
              WHEN ''3'' THEN mt.in_hospital_cd_b3
              WHEN ''4'' THEN mt.in_hospital_cd_b4
            END
        END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    ELSE NULL
  END AS hosp_cd,
  FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date))) / 60) AS dialysis_time
FROM
  do_ord_main om
INNER JOIN mst_treatment AS mt ON mt.treatment_cd = om.rst_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_treatment AS (
SELECT
  CASE ini_value.treat_convert
    WHEN ''0'' THEN tre.hosp_cd
    WHEN ''1'' THEN tc.convert_cd
  END AS hosp_cd,
  NULL AS proc_cd
FROM
  ord_main_tre tre
LEFT JOIN treat_convert tc ON tc.hosp_cd = tre.hosp_cd
AND tre.dialysis_time BETWEEN tc.lower_bound AND tc.upper_bound
CROSS JOIN ini_value
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  2000 AS temp_no,
  om.rst_cond_info->''5''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.rst_cond_info ->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  2100 AS temp_no,
  om.rst_cond_info->''6''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  3000 AS temp_no,
  om.rst_cond_info->''25''->>''value'' AS mst_cd,
  (om.rst_cond_info->''25''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''25''->>''value''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_touseki AS (
-- 透析液
SELECT
  3100 AS temp_no,
  om.rst_cond_info->''15''->>''value'' AS mst_cd,
  (om.rst_cond_info->''15''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''15''->>''value''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_hoeki AS (
-- 補液
SELECT
  3200 AS temp_no,
  om.rst_cond_info->''19''->>''value'' AS mst_cd,
  (om.rst_cond_info->''19''->>''medicine_type'')::integer AS medicine_type,
  NULL::integer AS procedure_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''19''->>''value''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_one_film AS (
-- 1次膜
SELECT
  2200 AS temp_no,
  om.rst_cond_info->''7''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_two_film AS (
-- 2次膜
SELECT
  2300 AS temp_no,
  om.rst_cond_info->''8''->>''value'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  3300 + t1.idx AS temp_no,
  t1.medi_info ->> ''cd'' AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg''::text = ''1''
)
, treatment_info AS (
-- 愁訴処置情報
SELECT
  3400 + t1.idx AS temp_no,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''oxgen_medi_code''
    ELSE
      t1.tre_info ->> ''treat_medicine_cd''
  END AS mst_cd,
  (t1.tre_info ->> ''medicine_type'')::integer AS medicine_type,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    ELSE
      (t1.tre_info ->> ''procedure_cd'')::integer
  END AS procedure_cd,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ini_value.oxgen_medi_code
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ''0''
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_treatment_info::json) WITH ORDINALITY AS t1(tre_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''2''
CROSS JOIN ini_value
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  2400 + t1.idx AS temp_no,
  t1.equip_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_equip_info::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = t1.equip_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  1300 AS temp_no,
  CASE ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, addition_info AS (
-- 加算情報
SELECT
  1300 + t1.idx AS temp_no,
  t1.addi_info ->> ''cd'' AS mst_cd,
  CASE ini_value.hosp_get_mst_addition
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    ELSE NULL
  END AS hosp_cd,
  mst.addition_class AS add_class
FROM
  do_ord_main om
LEFT JOIN LATERAL (
  SELECT x.elem, x.ord FROM do_ord_main om
  CROSS JOIN LATERAL jsonb_array_elements(om.addition_info) WITH ORDINALITY AS x(elem, ord)
  WHERE
    jsonb_typeof(om.addition_info) = ''array''
) AS t1(addi_info, idx) ON TRUE
LEFT JOIN mst_addition AS mst ON mst.addition_cd ::text = t1.addi_info ->> ''cd''
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)、愁訴処置情報（手技なし））
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.procedure_cd AS procedure_cd,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    coa.hosp_cd AS hosp_cd
  FROM
    ind_coagulant coa
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.procedure_cd AS procedure_cd,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.hosp_cd AS hosp_cd
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.procedure_cd AS procedure_cd,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.hosp_cd AS hosp_cd
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(pro_medi_table.temp_no) AS temp_no,
    MIN(pro_medi_table.medicine_type) AS medicine_type,
    MIN(pro_medi_table.procedure_cd) AS procedure_cd,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(pro_medi_table.mst_cd) AS mst_cd,
    pro_medi_table.hosp_cd AS hosp_cd
  FROM
  (SELECT
    imi.temp_no,
    imi.medicine_type,
    imi.mst_cd AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.procedure_cd AS procedure_cd,
    imi.treat_date AS treat_date
  FROM
    medi_indo imi
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot IS DISTINCT FROM ''1''
  UNION ALL
  SELECT
    ti.temp_no,
    ti.medicine_type,
    ti.mst_cd AS mst_cd,
    ti.hosp_cd AS hosp_cd,
    ti.procedure_cd AS procedure_cd,
    ti.treat_date AS treat_date
  FROM
    treatment_info ti
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot IS DISTINCT FROM ''1''
  ) AS pro_medi_table
  LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd AND mst.facility_cd = @facilityCd
  CROSS JOIN ini_value
  WHERE
    pro_medi_table.procedure_cd IS NULL
    OR (
      pro_medi_table.procedure_cd <> -9999
      AND NULLIF(
        CASE
          -- ▼治療日が A/B の両開始日を満たしている場合（より新しい方を優先）
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate
            AND pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE
              -- Aの方が新しければA系の施設CDを参照
              WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_a1
                  WHEN ''2'' THEN mst.in_hospital_cd_a2
                END
              -- Bの方が新しければB系の施設CDを参照
              WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_b1
                  WHEN ''2'' THEN mst.in_hospital_cd_b2
                END
            END
          -- ▼治療日がAの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_a1
              WHEN ''2'' THEN mst.in_hospital_cd_a2
            END
          -- ▼治療日がBの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_b1
              WHEN ''2'' THEN mst.in_hospital_cd_b2
            END
          -- ▼どちらの開始日も満たしていない、またはNULL含む場合
          ELSE NULL
        END
        , '''') IS NULL
    )
  GROUP BY
    pro_medi_table.hosp_cd
) AS ind_medi_table
LEFT JOIN mst_procedure mp ON ind_medi_table.procedure_cd = mp.procedure_cd
CROSS JOIN do_ord_main om
CROSS JOIN ini_value
ORDER BY
  temp_no
)
, medi_union_2 AS (
-- 投与薬剤情報(手技あり)、愁訴処置情報（手技あり）
SELECT
  ''投与薬剤/愁訴処置情報(薬剤）'' AS title,
  mst_cd,
  hosp_cd,
  mst.pricedure_name AS pro_title,
  pro_medi_table.procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
      ini_value.oxgen_procedure_code
    WHEN ((pro_medi_table.treat_date >= mst.in_hosp_a_startdate)
      AND (pro_medi_table.treat_date >= mst.in_hosp_b_startdate)) THEN
      CASE
        WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst.in_hospital_cd_a1
            WHEN ''2'' THEN mst.in_hospital_cd_a2
          END
        WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst.in_hospital_cd_b1
            WHEN ''2'' THEN mst.in_hospital_cd_b2
          END
      END
    WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst.in_hospital_cd_a1
        WHEN ''2'' THEN mst.in_hospital_cd_a2
      END
    WHEN pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst.in_hospital_cd_b1
        WHEN ''2'' THEN mst.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot IS DISTINCT FROM ''1''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot IS DISTINCT FROM ''1''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
UNION ALL
SELECT
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(pro_medi_table.mst_cd) AS mst_cd,
  pro_medi_table.hosp_cd AS hosp_cd,
  MAX(mst.pricedure_name) AS pro_title,
  pro_medi_table.procedure_cd AS procedure_cd,
  CASE
    WHEN pro_medi_table.procedure_cd = -9999 THEN
        MAX(ini_value.oxgen_procedure_code)
    WHEN ((MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate)) AND (MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate))) THEN
      CASE
        WHEN MAX(mst.in_hosp_a_startdate) > MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
          END
        WHEN MAX(mst.in_hosp_a_startdate) < MAX(mst.in_hosp_b_startdate) THEN
          CASE MAX(ini_value.hosp_get_mst_procedure)
            WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
            WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
          END
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_a_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_a1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_a2)
      END
    WHEN MAX(pro_medi_table.treat_date) >= MAX(mst.in_hosp_b_startdate) THEN
      CASE MAX(ini_value.hosp_get_mst_procedure)
        WHEN ''1'' THEN MAX(mst.in_hospital_cd_b1)
        WHEN ''2'' THEN MAX(mst.in_hospital_cd_b2)
      END
    ELSE NULL
  END AS pro_hosp_cd
FROM
  (SELECT
    imi2.mst_cd AS mst_cd,
    imi2.hosp_cd AS hosp_cd,
    imi2.procedure_cd AS procedure_cd,
    imi2.treat_date AS treat_date
  FROM
    medi_indo imi2
  WHERE
    imi2.mst_cd IS NOT NULL
    AND imi2.is_shot IS DISTINCT FROM ''1''
    AND imi2.procedure_cd IS NOT NULL
UNION ALL
  SELECT
    ti2.mst_cd AS mst_cd,
    ti2.hosp_cd AS hosp_cd,
    ti2.procedure_cd AS procedure_cd,
    ti2.treat_date AS treat_date
  FROM
    treatment_info ti2
  WHERE
    ti2.mst_cd IS NOT NULL
    AND ti2.is_shot IS DISTINCT FROM ''1''
    AND ti2.procedure_cd IS NOT NULL
) AS pro_medi_table
LEFT JOIN mst_procedure mst
  ON mst.procedure_cd = pro_medi_table.procedure_cd
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pro_medi_table.procedure_cd,
  pro_medi_table.hosp_cd
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  ind_equip_table.temp_no
)
, equip_sort_num AS (
SELECT
  DISTINCT ON
  (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd
  FROM
    equip_union
  GROUP BY
    hosp_cd
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY
  un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  ind_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''加算情報(加算項目)'' AS title,
  ai.hosp_cd AS hosp_cd,
  NULL AS proc_cd,
  NULL AS add_class
FROM
  addition_info ai
WHERE
  CASE
      WHEN ai.add_class = ''13'' THEN false --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then false
      ELSE true
      END
  AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''ダイアライザ'' AS title,
    dia.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    ind_dialyzer dia
  WHERE
    dia.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    eu.title AS title,
    eu.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    equip_sort_union eu
  WHERE
    eu.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu1.title AS title,
    mu1.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_1 mu1
  WHERE
    mu1.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''加算情報(医学管理科)'' AS title,
    ai.hosp_cd AS hosp_cd,
    NULL AS proc_cd,
    ai.add_class AS add_class
  FROM
    addition_info ai
  WHERE
    CASE
      WHEN ai.add_class = ''13'' THEN true --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then true
      ELSE false
      END
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu2.title AS title,
    mu2.hosp_cd AS hosp_cd,
    mu2.pro_hosp_cd AS proc_cd,
    NULL AS add_class
  FROM
    medi_union_2 mu2
  WHERE
    mu2.hosp_cd IS NOT NULL
    AND NULLIF(mu2.pro_hosp_cd, '''') IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.proc_cd,
  n.add_class,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.proc_cd,
  n.add_class,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (r.RpItem >= 20
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL))) THEN 2
    WHEN r.RpItem >= 20
      OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN 1
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL)
      OR r.RpItem >= 20
      AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20
      AND n.proc_cd IS NULL THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
FROM
  recursive_rp r
JOIN numbered n ON n.rn = r.rn + 1
CROSS JOIN ini_value m
)
, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
CROSS JOIN ind_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
, max_rp AS (
SELECT
  MAX(RP) AS max_rp
FROM
  final_data
)
, rp_series AS (
SELECT
  generate_series(1, (SELECT max_rp FROM max_rp)) AS RP
)
SELECT
  RP AS rp_no,
  CASE @crud
    WHEN ''del'' THEN 
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END 
    ELSE ''01''
  END AS detail_id
FROM rp_series
WHERE
  rp_series.RP < 11;

-- SQL: -1103003 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103002, 'WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)

, ini_value AS(
--連携設定取得値
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure
  )
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4,
  mst.is_disp as is_disp,
  mst.is_del as is_del  
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
  AND mst.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_medi_info AS rst_medi_info,
  res.treat_date::TIMESTAMP AS treat_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND journal.facility_cd = @facilityCd
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_medi_info AS rst_medi_info,
  main.treat_date::TIMESTAMP AS treat_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  t1.idx as idx,
  t1.medi_info ->> ''cd'' AS mst_cd,
  CASE
    WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate) 
      AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN
      CASE
        WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
          END
        WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
          END
      END
    WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
      END
    WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
            WHEN ''1'' THEN
              mst_mix.amount::numeric
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
          CASE t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.unit
            WHEN ''2'' THEN mst_mix.unit
          END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_disp 
    WHEN ''2'' THEN mst_mix.is_disp 
  END AS is_disp
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1'' AND mst_medi.facility_cd = @facilityCd
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN mst_procedure AS mst_pro ON mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd'' AND mst_pro.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg'' = ''1''

  AND (
    (medi_info ->> ''medicine_type''::text = ''1'' AND  mst_medi.is_del = ''0'')
    OR
    (medi_info ->> ''medicine_type''::text = ''2'' AND  mst_mix.is_del = ''0'')
  )
  
)
-- 送信履歴メモ.memoから取得
, memo_text AS (
SELECT
  save_2->>''memo'' AS memo
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND save_2->>''coop_cd'' = ''ind_dial''
  AND pat_coop_detail.facility_cd = @facilityCd
  AND save_2->>''ord_no'' = @ordNo::text
ORDER BY
  up_date DESC
LIMIT 1
)
, bounds AS (
SELECT
  memo,
  POSITION(''#I|'' IN memo) AS i_pos,
  POSITION(''#K'' IN memo) AS k_pos
FROM
  memo_text
)
, extracted AS (
SELECT
  substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
FROM
  bounds
)
, split_parts AS (
SELECT
  string_to_array(i_segment, ''|'') AS parts
FROM
  extracted
)
, item_info AS (
SELECT
  parts[i] AS item_value,
  i - 4 AS item_index
FROM
  split_parts,
  generate_series(5, CARDINALITY(parts)) AS i
)
, get_items AS (
SELECT
  item_index,
  item_value,
  substring(item_value FROM 1 FOR 2) AS rp_no,
  substring(item_value FROM 3 FOR 2) AS technique,
  substring(item_value FROM 5 FOR 2) AS med_no,
  substring(item_value FROM 7 FOR 6) AS med_code
FROM
  item_info
)
-- 同手技同薬剤コードは一つだけ出力
, get_items_total AS (
  SELECT DISTINCT ON (technique, med_code) *
    FROM get_items
    ORDER BY technique, med_code, item_index
)
-- コード桁数処理
, medi_indo_mi_cut AS (
  SELECT
    *,
    CASE
      WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
      ELSE (
        SELECT substring(hosp_cd FROM MIN(i))
        FROM generate_series(1, char_length(hosp_cd)) AS i
        WHERE octet_length(substring(hosp_cd FROM i)) <= 6
      )
    END AS hosp_cd_trimmed,
    RIGHT(pro_hosp_cd, 2) as pro_hosp_cd_trimmed
  FROM medi_indo
),
 unit_choice AS (
  SELECT DISTINCT ON (hosp_cd_trimmed, pro_hosp_cd_trimmed)
    hosp_cd_trimmed,
    pro_hosp_cd,
    unit
  FROM medi_indo_mi_cut
  WHERE is_shot = ''1'' AND is_disp = ''1''
  ORDER BY hosp_cd_trimmed, pro_hosp_cd_trimmed, idx
)

select
  CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
  gi.rp_no::numeric AS rp_no,
  gi.med_no::numeric AS medi_no,
  mi.hosp_cd_trimmed AS medi_cd,
  LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
  MIN(ini_unit.value) AS unit
FROM
  get_items_total gi
INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6,'' '')
  AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2,'' '')
LEFT JOIN unit_choice uc
  ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
  AND mi.pro_hosp_cd = uc.pro_hosp_cd
LEFT JOIN ini_unit
  ON uc.unit = ini_unit.key2
WHERE
  mi.is_shot = ''1'' and 
  mi.is_disp = ''1'' and
  gi.rp_no::numeric = @rpNo
  
GROUP BY gi.rp_no, gi.med_no, mi.hosp_cd_trimmed

ORDER BY rp_no, medi_no', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103001, E'-- SQL: -1103001 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_CONV_UNIT_MEDI'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_DIALYSISSEND''
    )
)
, ini_unit_medi AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, ini_unit_equip AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_EQUIP''
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIAL_DIFF_COMMENT_UNIT'') AS dial_diff_comment_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_ADDITION'') AS hosp_get_mst_addition,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_PROCEDURE_CODE'') AS oxgen_procedure_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_UNIT_CODE'') AS oxgen_unit_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''OXGEN_MEDI_CODE'') AS oxgen_medi_code,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_CONVERT'') AS treat_convert,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''ADDITION_CD'') AS addition_cd
)
, addition_cd_list as (
SELECT
  UNNEST(string_to_array(addition_cd, '','')) AS set_value
FROM ini_value
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  (t1.info ->> ''cd'')::integer AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot IS DISTINCT FROM ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
-- 施設設定マスタから投与薬剤表示順を取得
    SELECT
        ROW_NUMBER() OVER () AS no2,
        datt.a1
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
            )
        ) AS val
    ) AS datt
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
-- 薬剤分類マスタ表示順
SELECT
  index_no ::int AS medi_class_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
-- 投与タイミングマスタ表示順
SELECT
  index_no ::int AS timing_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
-- 手技マスタ表示順
SELECT
  index_no ::int AS procedure_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
-- 薬剤マスタから薬剤コード、薬剤分類コード表示順をまとめ
SELECT
  medicine_cd,
  class_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
    SELECT
        ROW_NUMBER() OVER () AS no2,
        TO_NUMBER(val, ''999999999999'') AS ora
    FROM UNNEST(
        COALESCE(
            string_to_array(
            (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3006''
                AND mst_f.facility_cd = @facilityCd
            ),
            '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
        )
    ) AS val
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment''
)
, equip_class_order AS (
-- 医療材料分類マスタ表示順
SELECT
  index_no ::int AS meq_class_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
-- 医療材料マスタと表示順
SELECT
  equipment_cd,
  equipment_name,
  class_cd,
  unit,
  in_hospital_cd_1,
  equip_order.meq_code_order,
  equip_class_order.meq_class_code_order
FROM
  mst_equipment meq
LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
WHERE
  facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_treatment_cd as rst_treatment_cd,
  res.rst_cond_info as rst_cond_info,
  res.rst_medi_info AS rst_medi_info,
  res.rst_treatment_info as rst_treatment_info,
  res.rst_equip_info as rst_equip_info,
  res.addition_info as addition_info,
  res.treat_date::TIMESTAMP AS treat_date,
  res.rst_start_date AS rst_start_date,
  res.rst_end_date AS rst_end_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND res.pat_id = @patId
  AND res.is_del = ''0''
  AND res.ord_no = journal.ord_no
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_treatment_cd as rst_treatment_cd,
  main.rst_cond_info as rst_cond_info,
  main.rst_medi_info AS rst_medi_info,
  main.rst_treatment_info as rst_treatment_info,
  main.rst_equip_info as rst_equip_info,
  main.addition_info as addition_info,
  main.treat_date::TIMESTAMP AS treat_date,
  main.rst_start_date AS rst_start_date,
  main.rst_end_date AS rst_end_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
  AND main.pat_id = @patId
  AND main.is_del = ''0''
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, treat_convert_part AS (
-- 連携設定.治療方法変換設定をテーブル化
SELECT
  key2 AS hosp_cd,
  split_part(t1.set_value, '','', 1) AS dialysis_time,
  split_part(t1.set_value, '','', 2) AS convert_cd,
  t1.no
FROM
  (SELECT
    key2
    , UNNEST(string_to_array(value, ''_'')) AS set_value
    ,generate_subscripts(string_to_array(value, ''_''), 1) as no
  FROM
    coop_ini_info ini
  WHERE key1 = ''SCM_DIALYSISSEND''
 ) t1
)
, parsed_ranges_check AS (
-- 治療方法変換設定チェック
SELECT distinct
  hosp_cd,
  ''NG'' AS check_result
FROM (
  SELECT
    CASE WHEN dialysis_time ~ ''^\\d+(\\.\\d+)?$''
    THEN NULLIF(dialysis_time, '''')
    ELSE NULL
    END AS lower_bound,
    NULLIF(convert_cd, '''') AS value,
    treat_convert_part.hosp_cd
  FROM treat_convert_part
) check_part
WHERE lower_bound IS NULL
  OR value IS NULL
)
, treat_convert AS (
    SELECT
        treat_convert_part.hosp_cd,
        convert_cd AS convert_cd,
        dialysis_time::numeric AS lower_bound,
        lead(dialysis_time::numeric, 1, 100000) OVER (PARTITION BY treat_convert_part.hosp_cd ORDER BY dialysis_time::numeric) -0.0001 AS upper_bound
    FROM treat_convert_part
    LEFT JOIN parsed_ranges_check on treat_convert_part.hosp_cd = parsed_ranges_check.hosp_cd
    WHERE parsed_ranges_check.check_result IS NULL
)
, ord_main_tre AS (
-- 治療方法コード
SELECT
  10000000 AS temp_no,
  om.rst_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
        WHEN mt.in_hosp_a_startdate > mt.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
            WHEN ''2'' THEN mt.in_hospital_cd_a2
            WHEN ''3'' THEN mt.in_hospital_cd_a3
            WHEN ''4'' THEN mt.in_hospital_cd_a4
          END
        WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
            WHEN ''2'' THEN mt.in_hospital_cd_b2
            WHEN ''3'' THEN mt.in_hospital_cd_b3
            WHEN ''4'' THEN mt.in_hospital_cd_b4
          END
      END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit,
  FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', om.rst_end_date) - date_trunc(''minute'', om.rst_start_date))) / 60) AS dialysis_time
FROM
  do_ord_main om
INNER JOIN mst_treatment AS mt ON mt.treatment_cd = om.rst_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_treatment AS (
SELECT
  CASE ini_value.treat_convert
    WHEN ''0'' THEN tre.hosp_cd
    WHEN ''1'' THEN tc.convert_cd
  END AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd
FROM
  ord_main_tre tre
LEFT JOIN treat_convert tc ON tc.hosp_cd = tre.hosp_cd
AND tre.dialysis_time BETWEEN tc.lower_bound AND tc.upper_bound
CROSS JOIN ini_value
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  20000000 AS temp_no,
  (om.rst_cond_info->''5''->>''value'')::integer AS mst_cd,
  CASE
    ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.dialyzer_unit, '''') AS unit
FROM
  do_ord_main om
INNER JOIN mst_dialyzer AS mst ON mst.dialyzer_cd::text = om.rst_cond_info ->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  21000000 AS temp_no,
  (om.rst_cond_info->''6''->>''value'')::integer AS mst_cd,
  21000000 AS meq_class_code_order,
  21000000 AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON meq.equipment_cd = TO_NUMBER(om.rst_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->> ''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->> ''medicine_type''
        WHEN ''1'' THEN 30000000
        WHEN ''2'' THEN 30000000 + mst_mix.idx
      END
  END AS temp_no,
  CASE om.rst_cond_info -> ''25'' ->>''medicine_type''
    WHEN ''1'' THEN (om.rst_cond_info->''25''->>''value'')::integer
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  30000000 AS medicine_type,
  30000000 AS timing_code_order,
  30000000 AS procedure_code_order,
  30000000 AS interval_no,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.rst_cond_info->''26''->>''value'')::NUMERIC + (om.rst_cond_info->''28''->>''value'')::NUMERIC
        WHEN ''2'' THEN 
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              ((om.rst_cond_info->''26''->>''value'')::NUMERIC 
              + (om.rst_cond_info->''28''->>''value'')::NUMERIC) * mst_mix.amount::NUMERIC
            WHEN ''1'' THEN mst_mix.amount::NUMERIC
          END
      END
  END AS amount,
  CASE
    WHEN COALESCE(om.rst_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''25''->>''value''
  AND om.rst_cond_info->''25''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_touseki AS (
-- 透析液
SELECT
  31000000 AS temp_no,
  (om.rst_cond_info->''15''->>''value'')::integer AS mst_cd,
  31000000 AS medi_code_order,
  31000000 AS medi_class_code_order,
  31000000 AS medicine_type,
  31000000 AS timing_code_order,
  31000000 AS procedure_code_order,
  31000000 AS interval_no,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
                  WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
        (om.rst_cond_info->''17''->>''value'')::NUMERIC
  END AS amount,
  CASE
    WHEN COALESCE(om.rst_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''15''->>''value''
  AND om.rst_cond_info->''15''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_hoeki AS (
-- 補液
SELECT
  32000000 AS temp_no,
  (om.rst_cond_info->''19''->>''value'')::integer AS mst_cd,
  32000000 AS medi_code_order,
  32000000 AS medi_class_code_order,
  32000000 AS medicine_type,
  32000000 AS timing_code_order,
  32000000 AS procedure_code_order,
  32000000 AS interval_no,  
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.rst_cond_info->''22''->>''value'')::NUMERIC
  END AS amount,
  CASE
    WHEN COALESCE(om.rst_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.rst_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit
FROM
  do_ord_main om
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = om.rst_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = om.rst_cond_info->''19''->>''value''
  AND om.rst_cond_info->''19''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_one_film AS (
-- 1次膜
SELECT
  22000000 AS temp_no,
  (om.rst_cond_info->''7''->>''value'')::integer AS mst_cd,
  22000000 AS meq_class_code_order,
  22000000 AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.rst_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_two_film AS (
-- 2次膜
SELECT
  23000000 AS temp_no,
  (om.rst_cond_info->''8''->>''value'')::integer AS mst_cd,
  23000000 AS meq_class_code_order,
  23000000 AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = om.rst_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON meq.equipment_cd = TO_NUMBER(om.rst_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  33000000 + t1.idx AS temp_no,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN (t1.medi_info ->> ''cd'')::integer 
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN TRUNC((medi_info ->> ''amount'')::NUMERIC, 4)
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((medi_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
            WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          iumedi.value
        WHEN ''2'' THEN 
          iumix.value
      END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg''::text = ''1''
)
, treatment_info AS (
-- 愁訴処置情報
SELECT
  50000000 + t1.idx AS temp_no,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    else
    	CASE (t1.tre_info ->> ''medicine_type'')
		    WHEN ''1'' THEN (t1.tre_info ->> ''treat_medicine_cd'')::integer
		    WHEN ''2'' THEN mst_mix.medi_cd
      	END
  END AS mst_cd,
  (t1.tre_info ->> ''medicine_type'')::integer AS medicine_type,
  NULL::integer AS timing_cd,
  CASE
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      -9999
    ELSE
      (t1.tre_info ->> ''procedure_cd'')::integer
  END AS procedure_cd,
  NULL::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      ini_value.oxgen_medi_code
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
        (t1.tre_info ->> ''oxygen_amount'')::NUMERIC
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN TRUNC((t1.tre_info ->> ''amount'')::NUMERIC, 4)
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((t1.tre_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
            WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
      COALESCE((SELECT value FROM ini_unit_equip WHERE key2 = ''L''), (SELECT value FROM ini_unit_medi WHERE key2 = ''L''), '''')
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN
          iumedi.value
        WHEN ''2'' THEN
          iumix.value
      END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_treatment_info::json) = 0 THEN NULL
    WHEN t1.tre_info ->> ''treat_class'' = ''3''
      AND t1.tre_info ->> ''oxygen_amount'' IS NOT NULL
      AND ini_value.oxgen_medi_code <> ''''
      AND ini_value.oxgen_procedure_code <> '''' THEN
        ''0''
    ELSE
      CASE t1.tre_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_treatment_info::json) WITH ORDINALITY AS t1(tre_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND t1.tre_info ->> ''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = t1.tre_info ->> ''treat_medicine_cd''
  AND t1.tre_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  24000000 + t1.idx AS temp_no,
  (t1.equip_info ->> ''cd'')::integer AS mst_cd,
  24000000 + meq.meq_class_code_order AS meq_class_code_order,
  24000000 + meq.meq_code_order AS meq_code_order,
  CASE ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  ini_unit_equip.value AS unit
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_equip_info::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON mst.equipment_cd::text = t1.equip_info ->> ''cd''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  13000000 AS temp_no,
  CASE ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, addition_info AS (
-- 加算情報
SELECT
  13000000 + t1.idx AS temp_no,
  (t1.addi_info ->> ''cd'')::integer AS mst_cd,
  CASE ini_value.hosp_get_mst_addition
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  CASE 
      WHEN mst.addition_class = ''2'' THEN (select dial_diff_comment_unit from ini_value)
      ELSE ''''
  END AS unit,
  mst.addition_class AS add_class
FROM
  do_ord_main om
LEFT JOIN LATERAL (
  SELECT x.elem, x.ord FROM do_ord_main om
  CROSS JOIN LATERAL jsonb_array_elements(om.addition_info) WITH ORDINALITY AS x(elem, ord)
  WHERE
    jsonb_typeof(om.addition_info) = ''array''
) AS t1(addi_info, idx) ON TRUE
LEFT JOIN mst_addition AS mst ON mst.addition_cd ::text = t1.addi_info ->> ''cd''
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)、愁訴処置情報（手技なし））
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
      CASE 
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
      END,
      medi_code_order
      ) AS sort_num
FROM
  (
  SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_code_order AS timing_code_order,
    coa.procedure_code_order AS procedure_code_order,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    30000000 + mst_medi.medi_code_order AS medi_code_order,
    30000000 + mst_medi.medi_class_code_order AS medi_class_code_order,
    coa.hosp_cd AS hosp_cd,
    COALESCE(coa.amount,0) AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
    LEFT JOIN mst_medi ON coa.mst_cd = mst_medi.medicine_cd
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_code_order AS timing_code_order,
    tou.procedure_code_order AS procedure_code_order,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.medi_code_order AS medi_code_order,
    tou.medi_class_code_order AS medi_class_code_order,
    tou.hosp_cd AS hosp_cd,
    COALESCE(tou.amount,0) AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_code_order AS timing_code_order,
    hoe.procedure_code_order AS procedure_code_order,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.medi_code_order AS medi_code_order,
    hoe.medi_class_code_order AS medi_class_code_order,
    hoe.hosp_cd AS hosp_cd,
    COALESCE(hoe.amount,0) AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(pro_medi_table.temp_no) AS temp_no,
    MIN(pro_medi_table.medicine_type) AS medicine_type,
    MIN(pro_medi_table.timing_code_order) AS timing_code_order,
    MIN(pro_medi_table.procedure_code_order) AS procedure_code_order,
    MIN(pro_medi_table.interval_no) AS interval_no,
    MIN(pro_medi_table.title) AS title,
    MIN(pro_medi_table.mst_cd) AS mst_cd,
    MIN(pro_medi_table.medi_code_order) AS medi_code_order,
    MIN(pro_medi_table.medi_class_code_order) AS medi_class_code_order,
    pro_medi_table.hosp_cd AS hosp_cd,
    SUM(pro_medi_table.amount) AS amount,
    MIN(pro_medi_table.unit) AS unit
  FROM
  (
  SELECT
    imi.temp_no,
    33000000 + imi.medicine_type as medicine_type,
    33000000 + COALESCE(t.timing_code_order, 0) AS timing_code_order,
    33000000 + COALESCE(p.procedure_code_order, 0) AS procedure_code_order,
    33000000 + COALESCE(imi.interval_no, 0) AS interval_no,
    33000000 + COALESCE(mst_medi.medi_code_order, 0) AS medi_code_order,
    33000000 + COALESCE(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
    imi.mst_cd::integer AS mst_cd,
    imi.hosp_cd AS hosp_cd,
    imi.amount AS amount,
    imi.unit AS unit,
    imi.procedure_cd AS procedure_cd,
    imi.treat_date AS treat_date,
    ''投与薬剤情報(手技無し)'' AS title
  FROM
    medi_indo imi
  LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
  LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
  LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
  LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot IS DISTINCT FROM ''1''
  UNION ALL
  SELECT
    ti.temp_no,
    50000000 + ti.medicine_type as medicine_type,
    50000000 + COALESCE(t.timing_code_order, 0) AS timing_code_order,
    50000000 + COALESCE(p.procedure_code_order,0) AS procedure_code_order,
    50000000 + COALESCE(ti.interval_no, 0) AS interval_no,
    50000000 + COALESCE(mst_medi.medi_code_order, 0) AS medi_code_order,
    50000000 + COALESCE(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
    ti.mst_cd::integer AS mst_cd,
    ti.hosp_cd AS hosp_cd,
    ti.amount AS amount,
    ti.unit AS unit,
    ti.procedure_cd AS procedure_cd,
    ti.treat_date AS treat_date,
    ''愁訴処置情報(手技無し)'' AS title
  FROM
    treatment_info ti
  LEFT JOIN mst_medicine mm ON ti.mst_cd = mm.medicine_cd
  LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
  LEFT JOIN timing_order t ON t.timing_code = ti.timing_cd
  LEFT JOIN procedure_order p ON p.procedure_code = ti.procedure_cd
  WHERE
    ti.mst_cd IS NOT NULL
    AND ti.is_shot IS DISTINCT FROM ''1''
  ) AS pro_medi_table
  LEFT JOIN mst_procedure mst ON mst.procedure_cd = pro_medi_table.procedure_cd AND mst.facility_cd = @facilityCd
  CROSS JOIN ini_value
  WHERE
    pro_medi_table.procedure_cd IS NULL
    OR (
      pro_medi_table.procedure_cd <> -9999
      AND NULLIF(
        CASE
          -- ▼治療日が A/B の両開始日を満たしている場合（より新しい方を優先）
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate
            AND pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE
              -- Aの方が新しければA系の施設CDを参照
              WHEN mst.in_hosp_a_startdate > mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_a1
                  WHEN ''2'' THEN mst.in_hospital_cd_a2
                END
              -- Bの方が新しければB系の施設CDを参照
              WHEN mst.in_hosp_a_startdate < mst.in_hosp_b_startdate THEN
                CASE ini_value.hosp_get_mst_procedure
                  WHEN ''1'' THEN mst.in_hospital_cd_b1
                  WHEN ''2'' THEN mst.in_hospital_cd_b2
                END
            END
          -- ▼治療日がAの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_a_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_a1
              WHEN ''2'' THEN mst.in_hospital_cd_a2
            END
          -- ▼治療日がBの開始日だけを満たしている場合
          WHEN pro_medi_table.treat_date >= mst.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN mst.in_hospital_cd_b1
              WHEN ''2'' THEN mst.in_hospital_cd_b2
            END
          -- ▼どちらの開始日も満たしていない、またはNULL含む場合
          ELSE NULL
        END
        , '''') IS NULL
    )
  GROUP BY
    pro_medi_table.hosp_cd
) AS ind_medi_table
CROSS JOIN do_ord_main om
CROSS JOIN ini_value
ORDER BY
  sort_num
)
, pro_medi_table AS (
  SELECT 
    t.*,
    m.pricedure_name AS pro_title,
    CASE
      WHEN t.procedure_cd = -9999 THEN
        ini_value.oxgen_procedure_code
      WHEN ((t.treat_date >= m.in_hosp_a_startdate)
        AND (t.treat_date >= m.in_hosp_b_startdate)) THEN
        CASE
          WHEN m.in_hosp_a_startdate > m.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN m.in_hospital_cd_a1
              WHEN ''2'' THEN m.in_hospital_cd_a2
            END
          WHEN m.in_hosp_a_startdate < m.in_hosp_b_startdate THEN
            CASE ini_value.hosp_get_mst_procedure
              WHEN ''1'' THEN m.in_hospital_cd_b1
              WHEN ''2'' THEN m.in_hospital_cd_b2
            END
        END
      WHEN t.treat_date >= m.in_hosp_a_startdate THEN
        CASE ini_value.hosp_get_mst_procedure
          WHEN ''1'' THEN m.in_hospital_cd_a1
          WHEN ''2'' THEN m.in_hospital_cd_a2
        END
      WHEN t.treat_date >= m.in_hosp_b_startdate THEN
        CASE ini_value.hosp_get_mst_procedure
          WHEN ''1'' THEN m.in_hospital_cd_b1
          WHEN ''2'' THEN m.in_hospital_cd_b2
        END
      ELSE NULL
    END AS pro_hosp_cd
  FROM (
    SELECT
        imi.temp_no,
        33000000 + imi.medicine_type as medicine_type,
        33000000 + coalesce(t.timing_code_order, 0) AS timing_code_order,
        33000000 + coalesce(p.procedure_code_order, 0) AS procedure_code_order,
        33000000 + coalesce(imi.interval_no, 0) AS interval_no,
        33000000 + coalesce(mst_medi.medi_code_order, 0) AS medi_code_order,
        33000000 + coalesce(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
        imi.mst_cd::integer AS mst_cd,
        imi.hosp_cd AS hosp_cd,
        imi.amount AS amount,
        imi.unit AS unit,
        imi.procedure_cd AS procedure_cd,
        imi.treat_date AS treat_date,
        ''投与薬剤情報(手技有り)'' AS title
    FROM
      medi_indo imi
    LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
    WHERE
      imi.mst_cd IS NOT NULL
      AND imi.is_shot IS DISTINCT FROM ''1''
  UNION ALL
    SELECT
        ti.temp_no,
        50000000 + ti.medicine_type as medicine_type,
        50000000 + coalesce(t.timing_code_order, 0) AS timing_code_order,
        50000000 + coalesce(p.procedure_code_order, 0) AS procedure_code_order,
        50000000 + coalesce(ti.interval_no, 0) AS interval_no,
        50000000 + coalesce(mst_medi.medi_code_order, 0) AS medi_code_order,
        50000000 + coalesce(mst_medi.medi_class_code_order, 0) AS medi_class_code_order,
        ti.mst_cd::integer AS mst_cd,
        ti.hosp_cd AS hosp_cd,
        ti.amount AS amount,
        ti.unit AS unit,
        ti.procedure_cd AS procedure_cd,
        ti.treat_date AS treat_date,
        ''愁訴処置情報(手技有り)'' AS title
    FROM
      treatment_info ti
    LEFT JOIN mst_medicine mm ON ti.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = ti.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = ti.procedure_cd
    WHERE
      ti.mst_cd IS NOT NULL
      AND ti.is_shot IS DISTINCT FROM ''1''
      ) t
  CROSS JOIN ini_value
  LEFT JOIN mst_procedure m ON m.procedure_cd = t.procedure_cd AND m.facility_cd = @facilityCd
)
, medi_union_2 AS (
-- 投与薬剤情報(手技あり)、愁訴処置情報（手技あり）
SELECT
    p.temp_no AS temp_no,
    p.medicine_type AS medicine_type,
    p.timing_code_order AS timing_code_order,
    p.procedure_code_order AS procedure_code_order,
    p.interval_no AS interval_no,
    p.medi_code_order AS medi_code_order,
    p.medi_class_code_order AS medi_class_code_order,
    p.mst_cd AS mst_cd,
    p.hosp_cd AS hosp_cd,
    p.amount AS amount,
    p.unit AS unit,
    p.title AS title,
    p.procedure_cd AS procedure_cd,
    p.pro_hosp_cd AS pro_hosp_cd,
  CASE
    WHEN p.procedure_cd = -9999 THEN true
    ELSE false
  END AS oxgen_flg
FROM
  pro_medi_table p
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0
  AND procedure_cd IS NOT NULL
UNION ALL
SELECT
    MIN(p.temp_no) AS temp_no,
    MIN(p.medicine_type) AS medicine_type,
    MIN(p.timing_code_order) AS timing_code_order,
    MIN(p.procedure_code_order) AS procedure_code_order,
    MIN(p.interval_no) AS interval_no,
    MIN(p.medi_code_order) AS medi_code_order,
    MIN(p.medi_class_code_order) AS medi_class_code_order,
    MIN(p.mst_cd) AS mst_cd,
    p.hosp_cd,
    SUM(p.amount) AS amount,
    MIN(p.unit) AS unit,    
    MIN(p.title) AS title,
    MIN(p.procedure_cd) AS procedure_cd,
    p.pro_hosp_cd,
  CASE
    WHEN MIN(p.procedure_cd) = -9999 THEN true
    ELSE false
  END AS oxgen_flg
FROM
  pro_medi_table p
WHERE
  (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
  AND procedure_cd IS NOT NULL
GROUP BY
  pro_hosp_cd,
  hosp_cd
order by pro_hosp_cd
)
, medi_union_2_with_sorted AS (
    select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    oxgen_flg,
    ROW_NUMBER() OVER(
        ORDER BY
        CASE 
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
        END,
        medi_code_order
        ) AS in_grp_rank
    from medi_union_2
    order by in_grp_rank
)
, group_scored AS (
  SELECT
    r.*,
    -- 各グループ（pro_hosp_cd）に属する行の中で最小の in_grp_rank をグループの「強さ」として採用
    -- → グループ内で一番上位に来る要素の順位をグループ全体の強さの代表値とする
    MIN(in_grp_rank) OVER (PARTITION BY pro_hosp_cd) AS grp_strength
  FROM medi_union_2_with_sorted r
)
, with_grp_order AS (
  SELECT
    g.*,
    -- grp_strength が若い（= グループの代表+順位が高い）ほど強いとみなし、グループに順位を付与
    -- → 強いグループから順に DENSE_RANK() を振る
    DENSE_RANK() OVER (ORDER BY grp_strength) AS grp_rank_by_strength
  FROM group_scored g
)
, procedure_medi_sorted AS (
-- 薬剤ごとに出力する場合は施設設定マスタの並び順をそのまま出力
  select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    oxgen_flg,
    in_grp_rank as sort_num
  from medi_union_2_with_sorted
  cross join ini_value
  where ini_value.medicine_send_type = ''0''
  union all
-- 手技でまとめる場合はgroup_scored、with_grp_orderの処理結果を出力
  SELECT
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    oxgen_flg,
    -- グループ順位 × 大きな係数 + グループ内順位 で全体のソートキーを生成
    (grp_rank_by_strength * 1000000) + in_grp_rank AS sort_num
  FROM with_grp_order
  cross join ini_value
  where ini_value.medicine_send_type = ''1''
  ORDER BY sort_num
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
    ORDER BY
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN ind_equip_table.meq_code_order END, 
    ind_equip_table.meq_code_order
      ) AS sort_num
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  sort_num
)
, equip_sort_num AS (
SELECT
  DISTINCT ON
  (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  ams.amount AS amount,
  ams.unit AS unit,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd,
    SUM(amount) AS amount,
    unit
  FROM
    equip_union
  GROUP BY
    hosp_cd,
    unit
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY
  un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd,
  NULL AS add_class,
  false AS oxgen_flg
FROM
  ind_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  ddi.amount AS amount,
  ddi.unit AS unit,
  NULL AS proc_cd,
  NULL AS add_class,
  false AS oxgen_flg
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''加算情報(加算項目)'' AS title,
  ai.hosp_cd AS hosp_cd,
  ai.amount AS amount,
  ai.unit AS unit,
  NULL AS proc_cd,
  NULL AS add_class,
  false AS oxgen_flg
FROM
  addition_info ai
WHERE
  CASE
      WHEN ai.add_class = ''13'' THEN false --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then false
      ELSE true
      END
  AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''ダイアライザ'' AS title,
    dia.hosp_cd AS hosp_cd,
    dia.amount AS amount,
    dia.unit AS unit,
    NULL AS proc_cd,
    NULL AS add_class,
    false AS oxgen_flg
  FROM
    ind_dialyzer dia
  WHERE
    dia.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    eu.title AS title,
    eu.hosp_cd AS hosp_cd,
    eu.amount AS amount,
    eu.unit AS unit,
    NULL AS proc_cd,
    NULL AS add_class,
    false AS oxgen_flg
  FROM
    equip_sort_union eu
  WHERE
    eu.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    mu1.title AS title,
    mu1.hosp_cd AS hosp_cd,
    mu1.amount AS amount,
    mu1.unit AS unit,
    NULL AS proc_cd,
    NULL AS add_class,
    false AS oxgen_flg
  FROM
    medi_union_1 mu1
  WHERE
    mu1.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    ''加算情報(医学管理科)'' AS title,
    ai.hosp_cd AS hosp_cd,
    ai.amount AS amount,
    ai.unit AS unit,
    NULL AS proc_cd,
    ai.add_class AS add_class,
    false AS oxgen_flg
  FROM
    addition_info ai
  WHERE
    CASE
      WHEN ai.add_class = ''13'' THEN true --慢性維持透析患者外来医学管理料
      WHEN ai.add_class = ''12'' --汎用
        AND ai.hosp_cd = ANY (select set_value from addition_cd_list)
        then true
      ELSE false
      END
    AND ai.hosp_cd IS NOT NULL
UNION ALL
  SELECT
    pms.title AS title,
    pms.hosp_cd AS hosp_cd,
    pms.amount AS amount,
    pms.unit AS unit,
    pms.pro_hosp_cd AS proc_cd,
    NULL AS add_class,
    pms.oxgen_flg AS oxgen_flg
  FROM
    procedure_medi_sorted pms
  WHERE
    pms.hosp_cd IS NOT NULL
    AND NULLIF(pms.pro_hosp_cd, '''') IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  n.add_class,
  n.oxgen_flg,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  n.add_class,
  n.oxgen_flg,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (r.RpItem >= 20
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL))) THEN 2
    WHEN r.RpItem >= 20
      OR n.proc_cd IS NULL
      AND n.add_class IS NOT NULL THEN 1
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL
      AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
      OR (m.medicine_send_type::NUMERIC = 0
      AND n.proc_cd IS NOT NULL)
      OR r.RpItem >= 20
      AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20
      AND n.proc_cd IS NULL THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
FROM
  recursive_rp r
JOIN numbered n ON n.rn = r.rn + 1
CROSS JOIN ini_value m
)
, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  1 AS amount,
  CASE WHEN oxgen_flg
    THEN COALESCE((SELECT oxgen_unit_code FROM ini_value), '''')
    ELSE ''''
  END AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
CROSS JOIN ind_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
SELECT
  CASE @crud
    WHEN ''del'' THEN 
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END 
    ELSE ''01''
  END AS detail_id,
  RP AS rp_no,
  RpItem AS item_no,
  title AS title,
  CASE 
  WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
  ELSE substring(
      hosp_cd FROM (
      SELECT MIN(i)
      FROM generate_series(1, char_length(hosp_cd)) AS i
      WHERE octet_length(substring(hosp_cd FROM i)) <= 8
      )
  )
  END AS hosp_cd,
  LEAST(TRUNC(COALESCE(amount,0), 4)::FLOAT8, 99999.9999)::text AS amount,
  unit
FROM
  final_data
WHERE
  RP < 11
ORDER BY
  RP,
  sort_key;

-- SQL: -1103001 end
', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1103000, E'-- SQL: -1103000 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_DIALYSISSEND'',
            ''SCM_COMMON'',
            ''SCM_DIALYSISSEND_KARTE_NOTE'',
            ''PAT_EVENT_TEMPLATE_SETTING''
        )
)
, ini_value AS(
--連携設定取得値
SELECT
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''TREAT_IDX_TITLE'') AS treat_title,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''FREE_WORD'') AS free_word,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''WEIGHT_BEFORE'') AS weight_before,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''WEIGHT_AFTER'') AS weight_after,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VITAL_BEFORE'') AS vital_before,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VITAL_AFTER'') AS vital_after,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''START_DATE'') AS start_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''END_DATE'') AS end_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''ADD_TOTAL'') AS add_total,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''DIALYSIS_TIME'') AS dialysis_time,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''VA'') AS va,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''TARGET_WEIGHT'') AS target_weight,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''BLOOD_FLOW'') AS blood_flow,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''SOLUTION_RESOLVE_FLUX'') AS solution_resolve_flux,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''REPLACE_RESOLVE_MEASURE'') AS replace_resolve_measure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_ONE_SHOT'') AS kou_one_shot,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_SPEED'') AS kou_speed,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KOU_COAG_RESOLVE_TOTAL'') AS kou_total,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''ADDITION'') AS addition,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''PAT_LIFE'') AS pat_life,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND_KARTE_NOTE'' AND key2 = ''KARTE_SUB_CATEGORIES'') AS karte_sub_categories,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''TEXTBOX'') AS textbox,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''TEXTAREA'') AS textarea,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''IMAGE'') AS pat_event_image,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''LISTBOX'') AS listbox,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''RADIOBUTTON'') AS radiobutton,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''DATE'') AS pat_event_date,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''CHECKBOX'') AS checkbox,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''FILE_ATTACHMENT'') AS file_attachment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''SCORE_CALCULATION'') AS score_calculation,
    (SELECT value FROM coop_ini_info WHERE key1 = ''PAT_EVENT_TEMPLATE_SETTING'' AND key2 = ''BULLETIN_LINK'') AS bulletin_link
)
, staff_cd_list AS (
--担当医の取得
SELECT
  users ->> ''disp_user_id'' AS disp_user_id,
  ROW_NUMBER() OVER(ORDER BY staff_info ->> ''disp_order'') AS row_no
FROM
  pat_main pm
CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS staff_info
LEFT JOIN jsonb_array_elements(@userList) AS users ON
  staff_info ->> ''staff_cd'' = users ->> ''user_id''
WHERE
  pm.facility_cd = @facilityCd
  AND pm.pat_id = @patId
  AND pm.is_del = ''0''
  AND staff_info ->> ''is_main'' = ''1''
)
, journal_staff_cd AS (
--版確定者の取得
SELECT
  users ->> ''disp_user_id'' AS disp_user_id
FROM
  sys_coop_journal AS journal
LEFT JOIN jsonb_array_elements(@userList) AS users ON
  journal.user_id = (users ->> ''user_id'')::NUMERIC
WHERE
  journal.ctl_no = @ctlNo
  AND journal.facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.del_date AS up_date,
            ord.rst_cond_info,
            ord.ind_kur_cd,
            ord.rst_treatment_cd,
            ord.rst_start_date,
            ord.rst_end_date,
            ord.treat_date,
            ord.rst_weight_info,
            ord.rst_running_time,
            ord.rst_ind_comment_info,
            ord.ord_no,
            ord.facility_cd,
            ord.is_del,
            ord.pat_id
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
            AND journal.ord_no = @ordNo            
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            ord.rst_edition_date AS up_date,
            ord.rst_cond_info,
            ord.ind_kur_cd,
            ord.rst_treatment_cd,
            ord.rst_start_date,
            ord.rst_end_date,
            ord.treat_date,
            ord.rst_weight_info,
            ord.rst_running_time,
            ord.rst_ind_comment_info,
            ord.ord_no,
            ord.facility_cd,
            ord.is_del,
            ord.pat_id
        FROM
            ord_main AS ord
        WHERE
        	ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_main_info AS (
-- 治療情報
SELECT
  to_char(om.rst_start_date, ''YYYY-MM-DD'') AS rst_start_date,
  to_char(om.rst_start_date, ''HH24:MI:SS'') AS rst_start_time,
  to_char(om.rst_end_date, ''HH24:MI:SS'') AS rst_end_time,
  to_char(
    TRUNC(EXTRACT(EPOCH FROM (rst_end_date - rst_start_date)) / 60),
    ''FM9990''
) AS treat_time,
  to_char(om.treat_date::timestamp, ''YYYY-MM-DD'') AS treat_date,
  to_char(mk.kur_standard_start_time::time, ''HH24:MI:SS'') AS kur_standard_start_time,
  ROUND((om.rst_weight_info ->> ''weight_before'')::NUMERIC, 2) AS weight_before,
  ROUND((om.rst_weight_info ->> ''weight_after'')::NUMERIC, 2) AS weight_after,
  ROUND((om.rst_weight_info ->> ''water_removal_rst'')::NUMERIC, 2) AS add_total,
  mv.va_name AS va_name,
  ROUND((om.rst_cond_info ->''3''->>''value'')::NUMERIC, 2) AS target_weight,
  ROUND((om.rst_cond_info ->''14''->>''value'')::NUMERIC) AS blood_flow,
  ROUND((om.rst_cond_info ->''16''->>''value'')::NUMERIC) AS alqd_flood_vol,
  CASE WHEN mt.device_mode not in (10) THEN ROUND((om.rst_cond_info ->''20''->>''value'')::NUMERIC, 1) ELSE NULL END AS repl_amount,
  ROUND((om.rst_cond_info ->''26''->>''value'')::NUMERIC, 2) AS anti_oneshot,
  ROUND((om.rst_cond_info ->''27''->>''value'')::NUMERIC, 2) AS anti_speed,
  ROUND((om.rst_cond_info ->''28''->>''value'')::NUMERIC, 2) AS anti_amount,
  om.rst_running_time AS rst_running_time,
  (SELECT
    string_agg(elem ->> ''content'', E''\\r\\n'')
  FROM
    jsonb_array_elements(om.rst_ind_comment_info) AS elem
    ) AS addition,
  COALESCE(mm.unit, mmx.unit) AS kou_unit,
  -- 透析液に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''15'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_dialysate_present,
  -- 補液に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''19'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_infusion_present,
  -- 抗凝固剤に値が存在する場合TRUEを返却する       
  CASE 
    WHEN (om.rst_cond_info -> ''25'' ->> ''value'') IS NOT NULL THEN TRUE 
    ELSE FALSE 
  END as is_anticoagulant_present
FROM
  ord_main_max om
LEFT JOIN mst_va mv ON om.rst_cond_info ->''2''->>''value'' = mv.va_cd::text
LEFT JOIN mst_kur mk ON om.ind_kur_cd = mk.kur_cd AND mk.facility_cd = @facilityCd
LEFT JOIN mst_treatment mt on om.rst_treatment_cd = mt.treatment_cd AND mt.facility_cd = @facilityCd
LEFT JOIN mst_medicine mm ON om.rst_cond_info ->''25''->>''medicine_type'' = ''1''
  AND om.rst_cond_info ->''25''->>''value'' = mm.medicine_cd::text
  AND mm.facility_cd = @facilityCd
LEFT JOIN mst_medicine_mix mmx ON om.rst_cond_info ->''25''->>''medicine_type'' = ''2''
  AND om.rst_cond_info ->''25''->>''value'' = mmx.medicine_mix_cd::text
  AND mmx.facility_cd = @facilityCd
WHERE
  om.ord_no = @ordNo
  AND om.facility_cd = @facilityCd
  AND om.is_del = ''0''
  AND om.pat_id = @patId
)
, mni_monitor_info AS (
--装置モニタデータから取得
SELECT
  mm.data_type,
  mm.monitor_data ->> ''90'' AS b_max,
  mm.monitor_data ->> ''91'' AS b_min,
  mm.monitor_data ->> ''92'' AS b_ave,
  mm.monitor_data ->> ''93'' AS pulse
FROM
  mni_monitor mm
WHERE
  data_type IN (''5'', ''6'')
    AND mm.ord_no = @ordNo
    AND mm.pat_id = @patId
    AND mm.is_del = ''0''
)
, send_his_memo AS (
-- 送信履歴メモ
SELECT
  save_2 ->> ''injection_send_day'' AS req_date,
  save_2 ->> ''injection_seq_no'' AS req_seq_no,
  save_2 ->> ''injection_user_id'' AS req_user_id,
  save_2 ->> ''treatment_send_day'' AS tre_send_day,
  save_2 ->> ''treatment_seq_no'' AS tre_seq_no,
  save_2 ->> ''treatment_user_id'' AS tre_user_id
FROM
  pat_coop_detail
WHERE
  facility_cd = @facilityCd
  AND pat_id = @patId
  AND save_2 ->> ''ord_no'' = @ordNo::TEXT
  AND save_2 ->> ''coop_cd'' = ''ind_dial''
ORDER BY
  up_date DESC
LIMIT 1
)
, coop_detail AS (
SELECT
  sh.req_date AS req_date,
  sh.req_seq_no AS req_seq_no,
  sh.req_user_id AS req_user_id,
  sh.tre_send_day AS tre_send_day,
  sh.tre_seq_no AS tre_seq_no,
  sh.tre_user_id AS tre_user_id
FROM
  send_his_memo sh
UNION ALL
SELECT
  '''',
  '''',
  '''',
  '''',
  '''',
  ''''
WHERE
  NOT EXISTS (SELECT 1 FROM send_his_memo)
)
, pat_event_category_order AS (
-- 患者イベントカテゴリマスタ表示順
SELECT
  index_no ::int AS category_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS category_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_pat_event_category''
)
, pat_event_sub_category_order AS (
-- 患者イベントサブカテゴリマスタ表示順
SELECT
  index_no ::int AS sub_category_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS sub_category_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_pat_event_sub_category''
)
, pat_event_info AS (
--観察記録情報
SELECT
  pe.event_start_date::date AS rec_date,
  pe.category_cd AS category_cd,
  pe.sub_category_cd AS sub_category_cd,
  coalesce(pe.event_start_time, ''0000'') AS event_start_time,
  pe.sub_category_name::text AS label_name,
  STRING_AGG(
    CASE
      WHEN ini.textbox = ''1'' AND (input.params ->> ''format_class'') = ''0'' AND COALESCE((result.params ->> ''result_value''), '''') <> '''' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params ->> ''result_value'')
      WHEN ini.textarea = ''1'' AND (input.params ->> ''format_class'') = ''1'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || unescape_html(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(substring(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\\r\\n'', ''g'') from 1 for length(REGEXP_REPLACE(COALESCE((result.params ->> ''result_value''), '''') , ''</[p^>]*>'', E''\\r\\n'', ''g''))), ''<[^>]*>'', '''', ''g''), E''^\\r\\n'', '''', ''''), E''\\r\\n$'', '''', ''''), E''(\\\\r?\\\\n)+'', E''\\r\\n   '', ''g''),E''\\uFEFF'' ,''''))
      WHEN ini.pat_event_image = ''1'' AND (input.params ->> ''format_class'') = ''2'' 
      AND EXISTS(SELECT 1 FROM json_array_elements(result.params -> ''result_value'') AS elem WHERE COALESCE(elem ->> ''file_name'', '''') <> '''')
      THEN
        (
        SELECT
        string_agg( COALESCE((input.params ->> ''field_name''), '''') || '':'' || (elem ->> ''file_name''), E''\\r\\n'' ) 
        FROM json_array_elements(result.params -> ''result_value'') AS elem 
        WHERE COALESCE(elem ->> ''file_name'', '''') <> ''''
        )
      WHEN ini.listbox = ''1'' AND (input.params ->> ''format_class'') = ''3'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params -> ''result_value'' ->> ''name'')
      WHEN ini.radiobutton = ''1'' AND (input.params ->> ''format_class'') = ''4'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params -> ''result_value'' ->> ''name'')
      WHEN ini.pat_event_date = ''1'' AND (input.params ->> ''format_class'') = ''5'' 
      AND COALESCE((result.params ->> ''result_value''), '''') <> ''''
      THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || to_char((result.params ->> ''result_value'')::date, ''YYYY/MM/DD'')
      WHEN ini.checkbox = ''1'' AND (input.params ->> ''format_class'') = ''6'' THEN
        ( 
        SELECT 
        COALESCE((input.params ->> ''field_name''), '''') || '':'' || string_agg((elem ->> ''name''), '','' ) 
        FROM json_array_elements(result.params -> ''result_value'') AS elem 
        )
      WHEN ini.file_attachment = ''1'' AND (input.params ->> ''format_class'') = ''7'' THEN
        ( 
        SELECT 
        string_agg( COALESCE((input.params ->> ''field_name''), '''') || '':'' || (elem ->> ''file_name''), E''\\r\\n'' ) 
        FROM json_array_elements(result.params -> ''result_value'') AS elem 
        )
      WHEN ini.score_calculation = ''1'' AND (input.params ->> ''format_class'') = ''8'' THEN
        COALESCE((input.params ->> ''field_name''), '''') || '':''
        || (result.params -> ''result_value'' ->> ''score'') || (result.params -> ''result_value'' ->> ''unit'')
      WHEN ini.bulletin_link = ''1'' AND (input.params ->> ''format_class'') = ''10'' THEN 
        CASE WHEN COALESCE(result.params -> ''result_value'' ->> ''notice_start_date'', '''') <> ''''
          THEN ''掲示板リンク:掲載有り'' || E''\\r\\n'' || ''期間:''|| to_char((result.params -> ''result_value'' ->> ''notice_start_date'')::timestamptz, ''YYYY/MM/DD'') || '' - '' || to_char((result.params -> ''result_value'' ->> ''notice_end_date'')::timestamptz, ''YYYY/MM/DD'')
          ELSE ''掲示板リンク:掲載無し''
        END
    END,
    E''\\r\\n''
    ORDER BY result.idx
  ) AS content
FROM
  pat_event pe
CROSS JOIN LATERAL json_array_elements(pe.input_params ::json) WITH ORDINALITY AS input(params, idx)
CROSS JOIN LATERAL json_array_elements(pe.result_params ::json) WITH ORDINALITY AS result(params, idx)
CROSS JOIN ini_value ini
WHERE
  pe.facility_cd = @facilityCd
  AND pe.pat_id = @patId
  AND pe.ord_no = @ordNo
  AND pe.is_del = ''0''
  AND pe.use_type = 2
  AND pe.event_start_date IS NOT NULL
  AND input.idx = result.idx
  AND pe.sub_category_name = ANY (string_to_array((SELECT karte_sub_categories FROM ini_value), '',''))
GROUP BY
  pe.pat_event_cd
)
, merged_pat_event_category as (
-- サブカテゴリ毎にマージした観察記録情報
  SELECT
    rec_date,
    label_name || '':'' || E''\\r\\n'' ||
      STRING_AGG(
      content,
      E''\\r\\n''
      ORDER BY label_name, event_start_time
    ) AS merged_content,
    category_code_order,
    sub_category_code_order
  FROM pat_event_info pei
  left join pat_event_category_order peco on pei.category_cd = peco.category_code
  left join pat_event_sub_category_order pesco on pei.sub_category_cd = pesco.sub_category_code
  GROUP BY rec_date, label_name,category_code_order,sub_category_code_order
  ORDER BY rec_date
)
, merged_pat_event_contents as (
-- 日付毎にマージした観察記録情報
  SELECT
    rec_date,
    STRING_AGG(
      merged_content,
      E''\\r\\n''
      ORDER BY category_code_order, sub_category_code_order
    ) AS merged_content
  FROM merged_pat_event_category
  GROUP BY rec_date
  ORDER BY rec_date
)
, karute_txt AS (
-- カルテ記録テキスト
SELECT
  COALESCE(ini.free_word) AS free_word,
  CASE
    WHEN ini.weight_before <> '''' AND om.weight_before IS NOT NULL THEN
        ini.weight_before || '':'' || om.weight_before || '' Kg''
      ELSE NULL
  END AS weight_before,
  CASE
    WHEN ini.weight_after <> '''' AND om.weight_after IS NOT NULL THEN
    ini.weight_after || '':'' || om.weight_after || '' Kg''
    ELSE NULL
  END AS weight_after,
  CASE
    WHEN ini.vital_before <> '''' THEN
    ini.vital_before || '':'' ||
     array_to_string(ARRAY[
     COALESCE(vbefore.b_max, ''-''), COALESCE(vbefore.b_min, ''-''), 
     COALESCE(vbefore.b_ave, ''-''), ''('' || COALESCE(vbefore.pulse, ''-'') || '')''], ''/'')
    ELSE NULL
  END AS vital_before,
  CASE
    WHEN ini.vital_after <> '''' THEN
    ini.vital_after || '':'' ||
    array_to_string(ARRAY[
    COALESCE(vafter.b_max, ''-''), COALESCE(vafter.b_min, ''-''), 
    COALESCE(vafter.b_ave, ''-''), ''('' || COALESCE(vafter.pulse, ''-'') || '')''], ''/'')
      ELSE NULL
  END AS vital_after,
  CASE
    WHEN ini.start_date <> '''' AND om.rst_start_time IS NOT NULL THEN
      ini.start_date || '':'' || om.rst_start_time::text
    ELSE NULL
  END AS start_date,
  CASE
    WHEN ini.end_date <> '''' AND om.rst_end_time IS NOT NULL THEN
      ini.end_date || '':'' || om.rst_end_time
    ELSE NULL
  END AS end_date,
  CASE
    WHEN ini.add_total <> '''' AND om.add_total IS NOT NULL THEN
      ini.add_total || '':'' || om.add_total || '' L''
    ELSE NULL
  END AS add_total,
  CASE
    WHEN ini.dialysis_time <> '''' AND om.treat_time IS NOT NULL THEN
      ini.dialysis_time || '':'' || om.treat_time || '' 分''
    ELSE NULL
  END AS dialysis_time,
  CASE
    WHEN ini.va <> '''' AND om.va_name IS NOT NULL THEN
      ini.va || '':'' || om.va_name
    ELSE NULL
  END AS va,
  CASE
    WHEN ini.target_weight <> '''' AND om.target_weight IS NOT NULL THEN
      ini.target_weight || '':'' || om.target_weight || '' Kg''
    ELSE NULL
  END AS target_weight,
  CASE
    WHEN ini.blood_flow <> '''' AND om.blood_flow IS NOT NULL THEN
      ini.blood_flow || '':'' || om.blood_flow || '' mL/min''
    ELSE NULL
  END AS blood_flow,
  -- 透析液が設定されている時のみ出力
  CASE
    WHEN ini.solution_resolve_flux <> '''' AND om.alqd_flood_vol IS NOT NULL AND om.is_dialysate_present THEN
      ini.solution_resolve_flux || '':'' || om.alqd_flood_vol || '' mL/min''
    ELSE NULL
  END AS solution_resolve_flux,
  -- 補液が設定されている時のみ出力
  CASE
    WHEN ini.replace_resolve_measure <> '''' AND om.repl_amount IS NOT NULL AND om.is_infusion_present THEN
      ini.replace_resolve_measure || '':'' || om.repl_amount || '' L''
    ELSE NULL
  END AS replace_resolve_measure,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_one_shot <> '''' AND om.anti_oneshot IS NOT NULL AND om.is_anticoagulant_present THEN
      ini.kou_one_shot || '':'' || om.anti_oneshot || COALESCE('' '' || om.kou_unit, '''')
    ELSE NULL
  END AS kou_one_shot,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_speed <> '''' AND om.anti_speed IS NOT NULL  AND om.is_anticoagulant_present THEN
      ini.kou_speed || '':'' || om.anti_speed || COALESCE('' '' || om.kou_unit || ''/h'', '''')
    ELSE NULL
  END AS kou_speed,
  -- 抗凝固剤が設定されている時のみ出力
  CASE
    WHEN ini.kou_total <> '''' AND om.anti_amount IS NOT NULL AND om.is_anticoagulant_present THEN
      ini.kou_total || '':'' || om.anti_amount || COALESCE('' '' || om.kou_unit, '''')
    ELSE NULL
  END AS kou_total,
  CASE
    WHEN ini.addition <> '''' AND om.addition IS NOT NULL THEN
      ini.addition || '':'' || E''\\r\\n'' || om.addition
    ELSE NULL
  END AS ind_comment,
  CASE
    WHEN ini.pat_life = ''1'' THEN
     merged_content
    ELSE NULL
  END AS obs_record
FROM
  ord_main_info om
CROSS JOIN ini_value ini
LEFT JOIN merged_pat_event_contents pe ON pe.rec_date::date = om.treat_date::date
FULL OUTER JOIN (SELECT b_max, b_min, b_ave, pulse FROM mni_monitor_info WHERE data_type = ''5'' ) AS vbefore ON TRUE
FULL OUTER JOIN (SELECT b_max, b_min, b_ave, pulse FROM mni_monitor_info WHERE data_type = ''6'') AS vafter ON TRUE
)
, cut_positions AS (
SELECT
  ini.treat_title AS value,
  octet_length(ini.treat_title) AS byte_len,
  char_length(ini.treat_title) AS char_len,
  CASE
    WHEN octet_length(ini.treat_title) <= 56 THEN char_length(ini.treat_title)
    ELSE 
    (SELECT
      MAX(i)
    FROM
      generate_series(1, char_length(ini.treat_title)) AS i
    WHERE
      octet_length(substring(ini.treat_title FROM 1 FOR i)) <= 60
    )
  END AS cut_index
FROM
  ini_value ini
)
, title_limited AS (
SELECT
  substring(value FROM 1 FOR cut_index) AS limited_title
FROM
  cut_positions
)
, user_list AS (
    --mst_user_authenticationのuser_idとdisp_user_idを取得(pre_sqlにて取得)
    SELECT
        users ->> ''user_id'' AS user_id,
        users ->> ''disp_user_id'' AS disp_user_id
    FROM
        jsonb_array_elements(@userList) AS users
)
, personal_list AS (
    --mst_personal_userのuser_idとin_hospital_cd_1とin_hospital_cd_2を取得(pre_sqlにて取得)
    SELECT
        personal ->> ''user_id'' AS user_id,
        personal ->> ''in_hospital_cd_1'' AS in_hospital_cd_1,
        personal ->> ''in_hospital_cd_2'' AS in_hospital_cd_2
    FROM
        jsonb_array_elements(@personalList) AS personal
)
, default_doctor AS (
    --デフォルト医師の院内コードと表示用利用者IDを取得
    SELECT
        --DEFAULT_DOCTORの設定値がusers.disp_user_idに存在しない場合も考慮して設定値をそのまま取得する
        (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DEFAULT_DOCTOR'') AS defalut_disp_user_id,
        CASE
      (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''IN_HOSP_CD'')
      WHEN ''1'' THEN personal.in_hospital_cd_1
      WHEN ''2'' THEN personal.in_hospital_cd_2
    END as defalut_in_hospital_cd
    FROM
        coop_ini_info cii
        LEFT JOIN user_list AS users ON 
            cii.value = users.disp_user_id
        LEFT JOIN personal_list AS personal ON
            users.user_id = personal.user_id
    WHERE
        cii.key1 = ''SCM_COMMON''
        AND cii.key2 = ''DEFAULT_DOCTOR''
)
SELECT
  RIGHT(
        CASE (SELECT value::NUMERIC FROM coop_ini_info WHERE key1 = ''SCM_DIALYSISSEND'' AND key2 = ''USER_ID_FLAG'')
        WHEN ''0'' THEN 
            (SELECT disp_user_id FROM journal_staff_cd)
        WHEN ''1'' THEN 
            COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''),
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''),
            NULLIF((SELECT defalut_disp_user_id FROM default_doctor), ''''),
            ''''
            )
        END
    , 6) AS user_id,
  (SELECT
    limited_title
  FROM
    title_limited) AS treat_title,
  omi.treat_date AS treat_date,
  omi.rst_start_date AS rst_start_date,
  omi.rst_start_time AS rst_start_time,
  TO_CHAR(TO_DATE(cd.tre_send_day, ''YYYYMMDD''), ''YYYY-MM-DD'') AS treatment_req_date,
  TO_CHAR(TO_TIMESTAMP(cd.tre_seq_no, ''HH24MISS''), ''HH24:MI:SS'') AS treatment_req_seq_no,
  cd.tre_user_id AS treatment_req_user_id,
  TO_CHAR(TO_DATE(cd.req_date, ''YYYYMMDD''), ''YYYY-MM-DD'') AS injection_req_date,
  TO_CHAR(TO_TIMESTAMP(cd.req_seq_no::TEXT, ''HH24MISS''), ''HH24:MI:SS'') AS injection_req_seq_no,
  cd.req_user_id AS injection_req_user_id,
  omi.kur_standard_start_time AS kur_standard_start_time,
  array_to_string(array_remove(ARRAY[
      kt.free_word,
      kt.weight_before,
      kt.weight_after,
      kt.vital_before,
      kt.vital_after,
      kt.start_date,
      kt.end_date,
      kt.add_total,
      kt.dialysis_time,
      kt.va,
      kt.target_weight,
      kt.blood_flow,
      kt.solution_resolve_flux,
      kt.replace_resolve_measure,
      kt.kou_one_shot,
      kt.kou_speed,
      kt.kou_total,
      kt.ind_comment,
      kt.obs_record
    ], NULL),
    E''\\r\\n''
  ) AS medical_record_text
FROM
  ord_main_info omi,
  karute_txt kt,
  coop_detail cd
-- SQL: -1103000 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}, {"sql_cd": -1102001, "field_name": "personal_list", "replace_var": "@personalList"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102033, 'WITH raw_data AS (
    SELECT @contentJson::jsonb AS data
),
rows AS (
    SELECT JSONB_ARRAY_ELEMENTS(data) AS row
    FROM raw_data
)
SELECT
    ''01'' AS detail_id,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @key0 AS key0,
    @patId AS pat_id,
    @ordNo AS ord_no   
WHERE (1 = 1
        AND @dumpResult::TEXT = ''1'' 
        AND EXISTS (SELECT 1 FROM rows)
    ) 
    OR @dumpResult::TEXT = ''''', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼(削除電文用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102029, "field_name": "content_json", "replace_var": "@contentJson"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102027, '-- sys_coop_journalの取得＆ファイル名list作成
WITH distribute_setting AS (
  SELECT COALESCE(
           mcd.distribute_setting->''protocolInfo''->>''fileNameDelimiter'',''|''
         ) AS file_name_delimiter,
         COALESCE(
           REPLACE(
             mcd.distribute_setting->''protocolInfo''->>''fileSplitDelimiterFormat'',
             ''%s'',''%''
           ),
           ''----- % -----''
         ) AS file_split_delimite_format
  FROM mst_coop_distribute mcd
  WHERE mcd.facility_cd = @facilityCd
    AND coop_cd = @coopCd
    AND is_del = ''0''
)
, get_sys_coop_journal AS (
  SELECT
    ctl_no,
    crud,
    -- dump_pathからデミリッタ（パイプ）を使用してファイル名をlistに埋める
   string_to_array(dump_path, ds.file_name_delimiter) AS path_array
  FROM sys_coop_journal
  CROSS JOIN distribute_setting ds
  WHERE ctl_no = @ctlNo
)
-- dumpをSHIFT_JIS変換
, decoded AS (
  SELECT
    ctl_no,
    convert_from(dump, ''SHIFT_JIS'') AS text_data
  FROM sys_coop_journal
  WHERE ctl_no = @ctlNo
)
-- dumpを行ごとにレコードに変換
, lines AS (
  SELECT
    l.ctl_no,
    row_number() OVER (PARTITION BY l.ctl_no ORDER BY ordinality) AS rn,
    line
  FROM decoded l,
  LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
)
-- get_sys_coop_journalで作成したファイル名listからファイル名を取り出す
, datas AS (
  SELECT
    get_sys_coop_journal.ctl_no,
    crud,
    array_length(path_array, 1) AS file_count,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[1]
      WHEN array_length(path_array, 1) = 7  THEN path_array[1]
      ELSE NULL
    END AS res_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[2]
      WHEN array_length(path_array, 1) = 11 THEN path_array[1]
      WHEN array_length(path_array, 1) = 7  THEN path_array[2]
      WHEN array_length(path_array, 1) = 6  THEN path_array[1]
      ELSE NULL
    END AS treat_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[9]
      WHEN array_length(path_array, 1) = 11 THEN path_array[8]
      ELSE NULL
    END AS inj_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[10]
      WHEN array_length(path_array, 1) = 11 THEN path_array[9]
      ELSE NULL
    END AS inj_detail_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[12]
      WHEN array_length(path_array, 1) = 11 THEN path_array[11]
      WHEN array_length(path_array, 1) = 7  THEN path_array[7]
      WHEN array_length(path_array, 1) = 6  THEN path_array[6]
      ELSE NULL
    END AS med_file

FROM get_sys_coop_journal
)
--ファイル間の区切り位置を生成
, target_datas AS (
  SELECT
    datas.ctl_no,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(res_file,''NO_FILE_res_''  || ctl_no)) AS res_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(treat_file,''NO_FILE_treat_'' || ctl_no)) AS treat_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(inj_file,''NO_FILE_inj_'' || ctl_no)) AS inj_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(inj_detail_file,''NO_FILE_inj_detail_'' || ctl_no)) AS inj_detail_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(med_file,''NO_FILE_med_'' || ctl_no)) AS med_header
  FROM datas
  CROSS JOIN distribute_setting ds
)
-- data行の特定
, matched_res AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.res_header AND l1.ctl_no = t.ctl_no
)
, matched_treat AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.treat_header AND l1.ctl_no = t.ctl_no
)
, matched_inj AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.inj_header AND l1.ctl_no = t.ctl_no
)
, matched_inj_detail AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.inj_detail_header AND l1.ctl_no = t.ctl_no
)
, matched_med AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.med_header AND l1.ctl_no = t.ctl_no
)
, all_datas AS (
  SELECT l.ctl_no, l.rn FROM lines l WHERE l.line LIKE ''-----%''
)
-- 注射の実施単位の次の行を取得
, next_inj_item AS (
  SELECT mi.ctl_no, MIN(h.rn) AS next_rn
  FROM matched_inj mi
  JOIN all_datas h ON h.ctl_no = mi.ctl_no AND h.rn > mi.rn
  GROUP BY mi.ctl_no
)
-- 注射の実施単位の次の行を取得
, next_inj_unit AS (
  SELECT mid.ctl_no, MIN(h.rn) AS next_rn
  FROM matched_inj_detail mid
  JOIN all_datas h ON h.ctl_no = mid.ctl_no AND h.rn > mid.rn
  GROUP BY mid.ctl_no
)
-- 注射単位を抽出し行のCSVをlistに変換
, inj_item_lines AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_inj mi ON l.ctl_no = mi.ctl_no
  JOIN next_inj_item nh ON l.ctl_no = nh.ctl_no
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  WHERE l.rn > mi.rn AND l.rn < nh.next_rn
    AND l.line NOT LIKE ''-----%''
    AND l.line <> ''''
  GROUP BY l.ctl_no, l.rn
)
-- 注射単位を抽出し行のCSVをlistに変換
, inj_detail_lines AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_inj_detail mid ON l.ctl_no = mid.ctl_no
  JOIN next_inj_unit nh ON l.ctl_no = nh.ctl_no
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  WHERE l.rn > mid.rn AND l.rn < nh.next_rn
    AND l.line NOT LIKE ''-----%''
    AND l.line <> ''''
  GROUP BY l.ctl_no, l.rn
)
-- RP番号を紐づけて項目取得
, joined_injection AS (
  SELECT
    iu.ctl_no,
    iu.cols[6]AS rp_no,
    coalesce(iu.cols[12], '''') AS tech,
    coalesce(id.cols[7], '''') AS medicine_no,
    coalesce(id.cols[8], '''') AS medicine_code
  FROM inj_item_lines iu
  JOIN inj_detail_lines id
    ON iu.ctl_no = id.ctl_no AND iu.cols[6] = id.cols[6]
    WHERE coalesce(iu.cols[6], '''') <> '''' OR coalesce(id.cols[7], '''') <> ''''
)
-- RPのメモ作成
, injection_summary AS (
  SELECT
    joined_injection.ctl_no,
    string_agg(
      ''|'' || lpad(rp_no, 2, ''0'') || rpad(tech, 2, '' '') || lpad(medicine_no, 2, ''0'') || rpad(medicine_code, 6, '' ''),
      ''''
    ) AS inj_memo
  FROM joined_injection
  GROUP BY joined_injection.ctl_no
)
-- RPのjson作成
, item_list_json AS (
  SELECT
    ctl_no,
    json_agg(json_build_object(''rp_no'', rp_no,''medicine_no'', medicine_no)) AS item_list
  FROM joined_injection
  GROUP BY ctl_no
)
-- 各種データをlistに変換
, res_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_res mr ON l.ctl_no = mr.ctl_no AND l.rn = mr.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, treat_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_treat mt ON l.ctl_no = mt.ctl_no AND l.rn = mt.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, inj_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_inj mi ON l.ctl_no = mi.ctl_no AND l.rn = mi.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, med_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_med mm ON l.ctl_no = mm.ctl_no AND l.rn = mm.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, get_new_sys_coop_journal AS (
  SELECT
    substring((string_to_array(dump_path, ''|''))[1] from ''([0-9]{8})[0-9]{6}'') AS res_day,
    substring((string_to_array(dump_path, ''|''))[1] from ''[0-9]{8}([0-9]{6})'') AS res_time
  FROM sys_coop_journal
  WHERE coop_cd = ''ind_dial''
    AND facility_cd = @facilityCd
    AND ord_no = @ordNo
    AND pat_id = @patId
    AND crud = ''C''
    AND dump_path IS NOT NULL
  ORDER BY up_date DESC
  LIMIT 1
)
, get_new_pat_coop_detail AS (
  SELECT
    split_part(split_part(save_2->>''memo'', ''#'', 1), ''|'', 4) AS res_day,
    split_part(split_part(save_2->>''memo'', ''#'', 1), ''|'', 5) AS res_time
  FROM pat_coop_detail
  WHERE
    facility_cd = @facilityCd
    AND pat_id = @patId
    AND save_2->>''ord_no'' = @ordNo
    AND save_2->>''coop_cd'' = ''ind_dial''
  ORDER BY up_date DESC
  LIMIT 1
)
, dump_text AS (
  SELECT
  CASE COUNT(*)
    WHEN 0 THEN NULL
    ELSE 1
    END AS dump_result
    FROM
  (SELECT
    convert_from(scj.dump, ''shift-jis'') AS dump_text
  FROM
    sys_coop_journal AS scj
  WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud = ''C''
    AND ord_no = @ordNo
    AND coop_cd = @coopCd
    AND key0 = @key0
    AND ana_result = ''9''
  ORDER BY
    scj.up_date DESC
  LIMIT 1) AS dump
)
-- ファイル名から発生日、SEQ番号を取得
, file_info AS (
  SELECT
    datas.ctl_no,
    datas.crud,
    res_file,
    treat_file,
    inj_file,
    inj_detail_file,
    med_file,

    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_date(NULLIF(treat_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'')
      ELSE substring(treat_file from ''_([0-9]{8})_'')
    END AS treat_day,
    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_timestamp(NULLIF(treat_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
      ELSE substring(treat_file from ''_[0-9]{8}_([0-9]{6})_[0-9]'')
    END AS treat_time,

    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_date(NULLIF(inj_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'')
      ELSE substring(inj_file from ''_([0-9]{8})_'')
    END AS inj_day,
    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_timestamp(NULLIF(inj_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
      ELSE substring(inj_file from ''_[0-9]{8}_([0-9]{6})_[0-9]'')
    END AS inj_time,

    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_date(NULLIF(med_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'')
      ELSE substring(med_file from ''_([0-9]{8})_'')
    END AS med_day,
    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_timestamp(NULLIF(med_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
      ELSE substring(med_file from ''_[0-9]{8}_([0-9]{6})'')
    END AS med_time,

    CASE (SELECT dump_result FROM dump_text)
  	WHEN ''1'' THEN
      CASE
        WHEN datas.crud = ''D'' THEN (SELECT res_day FROM get_new_sys_coop_journal)
        ELSE substring(res_file from ''([0-9]{8})[0-9]{6}'')
      END
  	ELSE (SELECT res_day FROM get_new_pat_coop_detail)
    END AS res_day,
    
    CASE (SELECT dump_result FROM dump_text)
  	WHEN ''1'' THEN
      CASE
        WHEN datas.crud = ''D'' THEN (SELECT res_time FROM get_new_sys_coop_journal)
        ELSE substring(res_file from ''[0-9]{8}([0-9]{6})'')
      END 
  	ELSE (SELECT res_time FROM get_new_pat_coop_detail)
    END AS res_time

  FROM datas
 LEFT JOIN res_data    ON res_data.ctl_no = datas.ctl_no
 LEFT JOIN treat_data  ON treat_data.ctl_no = datas.ctl_no
 LEFT  JOIN inj_data    ON inj_data.ctl_no = datas.ctl_no
 LEFT JOIN med_data    ON med_data.ctl_no = datas.ctl_no
)
, create_memo AS (
SELECT json_build_object(
  ''coop_cd'', ''ind_dial'',
  ''ord_no'',@ordNo::text,
  ''memo'',
    ''R|'' ||  @sendStatus || ''|'' || coalesce(res_data.cols[2], '''') || ''|'' || coalesce(file_info.res_day, '''') || ''|'' || coalesce(file_info.res_time, '''') || ''|'' || coalesce(res_data.cols [10], '''') ||
    ''#T|'' || @sendStatus || ''|'' || coalesce(treat_data.cols[5], '''') || ''|'' || coalesce(file_info.treat_day, '''') || ''|'' || coalesce(file_info.treat_time, '''') ||
    ''#I|'' || @sendStatus || ''|'' || coalesce(inj_data.cols[5], '''') || ''|'' || coalesce(file_info.inj_day, '''') || ''|'' || coalesce(file_info.inj_time, '''') || coalesce(injection_summary.inj_memo, '''') ||
    ''#K|'' || @sendStatus || ''|'' || coalesce(med_data.cols[5], '''') || ''|'' || coalesce(file_info.med_day, '''') || ''|'' || coalesce(file_info.med_time, ''''),
  ''sequence_no'', res_data.cols [10],
  ''treatment_user_id'', treat_data.cols[5],
  ''treatment_send_day'', file_info.treat_day,
  ''treatment_seq_no'', file_info.treat_time,
  ''injection_user_id'', inj_data.cols[5],
  ''injection_send_day'', file_info.inj_day,
  ''injection_seq_no'', file_info.inj_time,
  ''medical_send_day'', file_info.med_day,
  ''medical_seq_no'', file_info.med_time,
  ''item_list'', item_list_json.item_list
) AS result_json
FROM file_info
LEFT JOIN res_data    ON res_data.ctl_no = file_info.ctl_no
LEFT JOIN treat_data  ON treat_data.ctl_no = file_info.ctl_no
LEFT JOIN inj_data    ON inj_data.ctl_no = file_info.ctl_no
LEFT JOIN med_data    ON med_data.ctl_no = file_info.ctl_no
LEFT JOIN get_sys_coop_journal ON get_sys_coop_journal.ctl_no = file_info.ctl_no
LEFT JOIN injection_summary ON injection_summary.ctl_no = file_info.ctl_no
LEFT JOIN item_list_json ON item_list_json.ctl_no = file_info.ctl_no
)
INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::bigint,
    ''{"pkg": "Secom"}''::jsonb,
    (SELECT result_json FROM create_memo),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''', '2', '[]', '0', '{"applications": [4]}', NULL, '透析指示連携_送信履歴メモ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102024, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_処置項目', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102023, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_実施単位', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102022, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_注射ヘッダー', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102021, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 注射依頼ファイル_オーダーインデックス', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102019, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置項目', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102018, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置単位', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102017, 'select
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置ヘッダー', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102016, 'select
  CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 透析指示連携 処置依頼ファイル_オーダーインデックス', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102015, '-- SQL: -1102015 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_CONV_UNIT_MEDI''
    )
)
, ini_unit_medi AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, ini_unit_equip AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_EQUIP''
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  (t1.info ->> ''cd'')::integer AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot IS DISTINCT FROM ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
--施設設定107?置?取
    SELECT
        ROW_NUMBER() OVER () AS no2,
        datt.a1
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
            )
        ) AS val
    ) AS datt
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
-- 薬剤分類マスタ表示順
SELECT
  index_no ::int AS medi_class_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
-- 投与タイミングマスタ表示順
SELECT
  index_no ::int AS timing_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
-- 手技マスタ表示順
SELECT
  index_no ::int AS procedure_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
-- 薬剤マスタから薬剤コード、薬剤分類コード表示順をまとめ
SELECT
  medicine_cd,
  class_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON
  mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON
  mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
    SELECT
        ROW_NUMBER() OVER () AS no2,
        TO_NUMBER(val, ''999999999999'') AS ora
    FROM UNNEST(
        COALESCE(
            string_to_array(
            (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3006''
                AND mst_f.facility_cd = @facilityCd
            ),
            '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
        )
    ) AS val
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment''
)
, equip_class_order AS (
-- 医療材料分類マスタ表示順
SELECT
  index_no ::int AS meq_class_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
-- 医療材料マスタと表示順
SELECT
  equipment_cd,
  equipment_name,
  class_cd,
  unit,
  in_hospital_cd_1,
  equip_order.meq_code_order,
  equip_class_order.meq_class_code_order
FROM
  mst_equipment meq
LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
WHERE
  facility_cd = @facilityCd
),
ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info,
            ord.ind_treatment_cd,
            ord.ind_cond_info,
            ind_equip_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
            AND journal.is_del = ''0''
            AND journal.ord_no = @ordNo
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info,
            ord.ind_treatment_cd,
            ord.ind_cond_info,
            ind_equip_info
        FROM
            ord_main AS ord
        WHERE
            ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ind_treatment AS (
-- 治療方法コード
SELECT
  10000000 AS temp_no,
  om.ind_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
      WHEN mt.in_hosp_a_startdate >= mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
      WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
      WHEN ''2'' THEN mt.in_hospital_cd_a2
      WHEN ''3'' THEN mt.in_hospital_cd_a3
      WHEN ''4'' THEN mt.in_hospital_cd_a4
    END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
      WHEN ''2'' THEN mt.in_hospital_cd_b2
      WHEN ''3'' THEN mt.in_hospital_cd_b3
      WHEN ''4'' THEN mt.in_hospital_cd_b4
    END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit
FROM
  ord_main_max AS om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  20000000 AS temp_no,
  (om.ind_cond_info->''5''->>''value'')::integer AS mst_cd,
  CASE
    ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.dialyzer_unit, '''') AS unit
FROM
  ord_main_max AS om
INNER JOIN mst_dialyzer AS mst ON
  mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  21000000 AS temp_no,
  (om.ind_cond_info->''6''->>''value'')::integer AS mst_cd,
  21000000 AS meq_class_code_order,
  21000000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max AS om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 30000000
        WHEN ''2'' THEN 30000000 + mst_mix.idx
      END
  END AS temp_no,
  CASE om.ind_cond_info -> ''25'' ->>''medicine_type''
    WHEN ''1'' THEN (om.ind_cond_info->''25''->>''value'')::integer
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  30000000 AS medicine_type,
  30000000 AS timing_code_order,
  30000000 AS procedure_code_order,
  30000000 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric
      WHEN ''2'' THEN 
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              ((om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric) * mst_mix.amount::numeric
        WHEN ''1'' THEN mst_mix.amount::numeric
      END
    END
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main_max AS om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_touseki AS (
-- 透析液
SELECT
  31000000 AS temp_no,
  (om.ind_cond_info->''15''->>''value'')::integer AS mst_cd,
  31000000 AS medi_code_order,
  31000000 AS medi_class_code_order,
  31000000 AS medicine_type,
  31000000 AS timing_code_order,
  31000000 AS procedure_code_order,
  31000000 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
      WHEN ''1'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''17''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main_max AS om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_hoeki AS (
-- 補液
SELECT
  32000000 AS temp_no,
  (om.ind_cond_info->''19''->>''value'')::integer AS mst_cd,
  32000000 AS medi_code_order,
  32000000 AS medi_class_code_order,
  32000000 AS medicine_type,
  32000000 AS timing_code_order,
  32000000 AS procedure_code_order,
  32000000 AS interval_no,  
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.ind_cond_info->''22''->>''value'')::numeric
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main_max AS om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_one_film AS (
-- 1次膜
SELECT
  22000000 AS temp_no,
  (om.ind_cond_info->''7''->>''value'')::integer AS mst_cd,
  22000000 AS meq_class_code_order,
  22000000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max AS om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_two_film AS (
-- 2次膜
SELECT
  23000000 AS temp_no,
  (om.ind_cond_info->''8''->>''value'')::integer AS mst_cd,
  23000000 AS meq_class_code_order,
  23000000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max AS om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  33000000 + t1.idx AS temp_no,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN (t1.medi_info ->> ''cd'')::integer 
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
         END
      WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
    END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN TRUNC((medi_info ->> ''amount'')::NUMERIC, 4)
      WHEN ''2'' THEN
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((medi_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
        WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
      END
      ELSE 0
    END
  END AS amount,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
        CASE t1.medi_info ->> ''medicine_type''
             WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  ord_main_max AS om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''1''
    AND mst_medi.facility_cd = @facilityCd
    AND mst_medi.is_del = ''0''
    AND mst_medi.is_disp = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
  LEFT JOIN mst_medi_mix AS mst_mix ON
    mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
  CROSS JOIN ini_value
)
, pro_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_get_mst_procedure
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_get_mst_procedure
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS pro_hosp_cd,
        MIN(mp.pricedure_name) AS pricedure_name,
        omi.procedure_cd
    FROM
        medi_indo omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN ini_value
    GROUP BY
        omi.procedure_cd
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  24000000 + t1.idx AS temp_no,
  (t1.equip_info ->> ''cd'')::integer AS mst_cd,
  24000000 + meq.meq_class_code_order AS meq_class_code_order,
  24000000 + meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max AS om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  13000000 AS temp_no,
  CASE
    ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON
  mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
      CASE 
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
      END,
      medi_code_order
      ) AS sort_num
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_code_order AS timing_code_order,
    coa.procedure_code_order AS procedure_code_order,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    30000000 + mst_medi.medi_code_order AS medi_code_order,
    30000000 + mst_medi.medi_class_code_order AS medi_class_code_order,
    coa.hosp_cd AS hosp_cd,
    COALESCE(coa.amount,0) AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
    LEFT JOIN mst_medi ON coa.mst_cd = mst_medi.medicine_cd
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_code_order AS timing_code_order,
    tou.procedure_code_order AS procedure_code_order,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.medi_code_order AS medi_code_order,
    tou.medi_class_code_order AS medi_class_code_order,
    tou.hosp_cd AS hosp_cd,
    COALESCE(tou.amount,0) AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_code_order AS timing_code_order,
    hoe.procedure_code_order AS procedure_code_order,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.medi_code_order AS medi_code_order,
    hoe.medi_class_code_order AS medi_class_code_order,
    hoe.hosp_cd AS hosp_cd,
    COALESCE(hoe.amount,0) AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(imi.temp_no) AS temp_no,
    33000000 + MIN(imi.medicine_type) AS medicine_type,
    33000000 + MIN(t.timing_code_order) AS timing_code_order,
    33000000 + MIN(p.procedure_code_order) AS procedure_code_order,
    33000000 + MIN(imi.interval_no) AS interval_no,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(imi.mst_cd) AS mst_cd,
    33000000 + MIN(mst_medi.medi_code_order) AS medi_code_order,
    33000000 + MIN(mst_medi.medi_class_code_order) AS medi_class_code_order,
    imi.hosp_cd AS hosp_cd,
    SUM(imi.amount) AS amount,
    MIN(imi.unit) AS unit
  FROM
    medi_indo imi
    LEFT JOIN pro_code pc ON pc.procedure_cd = imi.procedure_cd
    LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot IS DISTINCT FROM ''1''
    AND (imi.procedure_cd IS NULL
    OR pc.pro_hosp_cd IS NULL
    )
  GROUP BY
  imi.hosp_cd
) AS ind_medi_table
ORDER BY
  sort_num
)
, medi_union_2 AS (
SELECT
  imi2.temp_no,
  imi2.medicine_type,
  imi2.timing_cd,
  imi2.interval_no,
  ''投与薬剤情報(薬剤）'' AS title,
  imi2.mst_cd AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  imi2.amount AS amount,
  imi2.unit AS unit,
  pc.pricedure_name AS pro_title,
  imi2.procedure_cd AS procedure_cd,
  pc.pro_hosp_cd
FROM
  medi_indo imi2
  LEFT JOIN pro_code pc ON imi2.procedure_cd = pc.procedure_cd
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot IS DISTINCT FROM ''1''
  AND imi2.procedure_cd IS NOT NULL
  AND pc.pro_hosp_cd IS NOT NULL
  AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0

UNION ALL
SELECT
  MIN(imi2.temp_no) AS temp_no,
  MIN(imi2.medicine_type) AS medicine_type,
  MIN(imi2.timing_cd) AS timing_cd,
  MIN(imi2.interval_no) AS interval_no,
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(imi2.mst_cd) AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  SUM(imi2.amount) AS amount,
  MAX(imi2.unit) AS unit,
  MAX(pc.pricedure_name) AS pro_title,
  MIN(imi2.procedure_cd) AS procedure_cd,
  pc.pro_hosp_cd
FROM
  medi_indo imi2
  LEFT JOIN pro_code pc ON imi2.procedure_cd = pc.procedure_cd
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot IS DISTINCT FROM ''1''
  AND imi2.procedure_cd IS NOT NULL
  AND pro_hosp_cd IS NOT NULL
  AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pc.pro_hosp_cd,
  imi2.hosp_cd
)
, medi_union_2_with_sorted as (
    select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    pro_title,
    procedure_cd,
    pro_hosp_cd,
    ROW_NUMBER() OVER(
        ORDER BY
        CASE 
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
        END,
        medi_code_order
        ) AS in_grp_rank
    from medi_union_2
    LEFT JOIN mst_medi mmd ON mst_cd = mmd.medicine_cd
    LEFT JOIN timing_order ON timing_cd = timing_order.timing_code
    LEFT JOIN procedure_order ON procedure_cd = procedure_order.procedure_code
    order by in_grp_rank
)
, group_scored AS (
  SELECT
    r.*,
    -- 各グループ（pro_hosp_cd）に属する行の中で最小の in_grp_rank をグループの「強さ」として採用
    -- → グループ内で一番上位に来る要素の順位をグループ全体の強さの代表値とする
    MIN(in_grp_rank) OVER (PARTITION BY pro_hosp_cd) AS grp_strength
  FROM medi_union_2_with_sorted r
)
, with_grp_order AS (
  SELECT
    g.*,
    -- grp_strength が若い（= グループの代表+順位が高い）ほど強いとみなし、グループに順位を付与
    -- → 強いグループから順に DENSE_RANK() を振る
    DENSE_RANK() OVER (ORDER BY grp_strength) AS grp_rank_by_strength
  FROM group_scored g
)
, procedure_medi_sorted AS (
-- 薬剤ごとに出力する場合は施設設定マスタの並び順をそのまま出力
  select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    in_grp_rank as sort_num
  from medi_union_2_with_sorted
  cross join ini_value
  where ini_value.medicine_send_type = ''0''
  union all
-- 手技でまとめる場合はgroup_scored、with_grp_orderの処理結果を出力
  SELECT
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    -- グループ順位 × 大きな係数 + グループ内順位 で全体のソートキーを生成
    (grp_rank_by_strength * 1000000) + in_grp_rank AS sort_num
  FROM with_grp_order
  cross join ini_value
  where ini_value.medicine_send_type = ''1''
  ORDER BY sort_num
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN ind_equip_table.meq_code_order END, 
    ind_equip_table.meq_code_order
      ) AS sort_num
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  sort_num
)
, equip_sort_num AS (
  SELECT DISTINCT ON (un.hosp_cd) un.hosp_cd AS hosp_cd, un.r_num
  FROM (
    SELECT ROW_NUMBER() OVER () AS r_num, ut.hosp_cd FROM equip_union ut
  ) AS un
  ORDER BY un.hosp_cd, un.r_num
),
equip_sort_union AS (
  SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd,
    SUM(amount) AS amount,
    unit
  FROM equip_union
  GROUP BY hosp_cd, unit
),
union_table AS (
  SELECT ''治療方法'' AS title, hosp_cd, NULL AS proc_cd FROM ind_treatment
  UNION ALL
  SELECT ''透析困難コード'', hosp_cd, NULL FROM dial_diff_info WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT ''ダイアライザ'', hosp_cd, NULL FROM ind_dialyzer WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT title, hosp_cd, NULL FROM equip_sort_union WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT title, hosp_cd, NULL FROM medi_union_1 WHERE hosp_cd IS NOT NULL
  UNION ALL
  SELECT title, hosp_cd, pro_hosp_cd FROM procedure_medi_sorted WHERE hosp_cd IS NOT NULL
),
numbered AS (
  SELECT *, ROW_NUMBER() OVER () AS rn FROM union_table
),
recursive_rp AS (
  SELECT
    n.rn,
    n.hosp_cd,
    n.proc_cd,
    1 AS RP,
    1 AS RpItem,
    NULL::text AS last_proc_cd,
    ARRAY[]::text[] AS proc_cd_list,
    FALSE AS need_procedure_insert,
    FALSE AS need_treatment_insert
  FROM numbered n, ini_value m
  WHERE n.rn = 1

  UNION ALL

  SELECT
    n.rn,
    n.hosp_cd,
    n.proc_cd,
    CASE
      WHEN r.RP >= 11 THEN r.RP
      WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
      WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL) THEN r.RP + 1
      ELSE r.RP
    END,
    CASE
      WHEN r.RP >= 11 THEN r.RpItem
      WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
         OR (r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL))) THEN 2
      ELSE r.RpItem + 1
    END,
    CASE WHEN n.proc_cd IS NOT NULL THEN n.proc_cd ELSE r.last_proc_cd END,
    CASE
      WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
      ELSE r.proc_cd_list
    END,
    CASE
      WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
         OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
         OR r.RpItem >= 20 AND n.proc_cd IS NOT NULL) THEN TRUE
      ELSE FALSE
    END,
    CASE
      WHEN r.RpItem >= 20 AND n.proc_cd IS NULL THEN TRUE
      ELSE FALSE
    END
  FROM recursive_rp r
  JOIN numbered n ON n.rn = r.rn + 1
  CROSS JOIN ini_value m
  WHERE r.RP < 10
),
procedure_inserts AS (
  SELECT
    RP, 1 AS RpItem, (rn - 0.5)::NUMERIC AS sort_key
  FROM recursive_rp
  WHERE need_procedure_insert
),
treatment_inserts AS (
  SELECT
    RP, 1 AS RpItem, (rn - 0.5)::NUMERIC AS sort_key
  FROM recursive_rp
  CROSS JOIN ind_treatment
  WHERE need_treatment_insert
),
recursive_rp_with_sort AS (
  SELECT RP, RpItem, rn::NUMERIC AS sort_key FROM recursive_rp
),
final_data AS (
  SELECT RP, RpItem, sort_key FROM recursive_rp_with_sort
  UNION ALL
  SELECT RP, RpItem, sort_key FROM procedure_inserts
  UNION ALL
  SELECT RP, RpItem, sort_key FROM treatment_inserts
)
,max_rp AS (
  SELECT MAX(RP) AS max_rp FROM final_data
),
rp_series AS (
  SELECT generate_series(1, (SELECT max_rp FROM max_rp)) AS RP
)
SELECT
  RP as rp_no,
  CASE @crud
    WHEN ''del'' THEN 
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END 
    ELSE ''01''
  END AS detail_id
FROM rp_series;
-- SQL: -1102015 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携_処置依頼ファイル_処置単位のRP番号取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102011, '-- SQL:-1102011 begin
WITH coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_COMMON'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    SELECT
        ROW_NUMBER() OVER () AS setting_order, -- 適用順 
        datt.a1 AS setting_value -- 設定値
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルト値を配列で補う
            )
        ) AS val
    ) AS datt
)
, medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
)
, medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
)
, timing_order as (
    -- 投与タイミングマスタの並び順
    select
        index_no ::int as timing_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
)
, procedure_order as (
    -- 手技マスタの並び順
    select
        index_no ::int as procedure_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
)
, mst_medi as (
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        TRUNC((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        CASE
            medi_mix_info ->> ''solvent''
            WHEN ''0'' THEN TRUNC(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN TRUNC((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
        END AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        SUM(medi_amount) AS medi_amount,
        MIN(unit_convert) AS unit_convert
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
        ROW_NUMBER() OVER(
            order by 
            case  
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd,
        f.medi_amount,
        f.unit_convert
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
SELECT
    CASE @crud
        WHEN ''del'' then
            CASE @dumpResult
                WHEN ''1'' THEN ''01''
                ELSE ''02''
            END 
        ELSE ''01''
    END AS detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    sort_key,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
    1 AS medi_num,
    LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
    TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
    unit_convert
FROM
    sort_order
WHERE
    sort_key <= 10
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
UNION ALL
SELECT
    CASE @crud
        WHEN ''del'' then
            CASE @dumpResult
                WHEN ''1'' THEN ''01''
                ELSE ''02''
            END 
        ELSE ''01''
    END AS detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    new_sort_key AS sort_key,
    rp_num,
    medi_num,
    LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
    TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
    unit_convert
FROM
    medi_numbering
WHERE
    rp_num <= 10
    AND new_sort_key <= 20
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
-- SQL:-1102011 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102006, '-- SQL:-1102006 begin
WITH ord_main_switch AS(
    (
        SELECT ord.rst_dialysis_state as rst_dialysis_state,
            ord.rst_edition_date as up_date_switch
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
    )
    UNION
    (
        SELECT ord.rst_dialysis_state as rst_dialysis_state,
            ord.del_date as up_date_switch
        FROM ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY del_date DESC
        LIMIT 1
    )
    ORDER BY up_date_switch DESC NULLS LAST
    LIMIT 1
)

SELECT
	CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
    END AS detail_id,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @key0 AS key0,
    @patId AS pat_id,
    @ordNo AS ord_no,
    @fileName AS file_name,
    @folderName AS folder_name
FROM ord_main_switch
WHERE rst_dialysis_state = ''0'';
-- SQL:-1102006 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携_予約受付のdetail特定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100009, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102003, '-- SQL:-1102003 begin
WITH coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' in(
            ''SCM_COMMON'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
        )
)
, facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    SELECT
        ROW_NUMBER() OVER () AS setting_order, -- 適用順 
        datt.a1 AS setting_value -- 設定値
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルト値を配列で補う
            )
        ) AS val
    ) AS datt
)
, medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
)
, medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
)
, timing_order as (
    -- 投与タイミングマスタの並び順
    select
        index_no ::int as timing_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
)
, procedure_order as (
    -- 手技マスタの並び順
    select
        index_no ::int as procedure_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
)
, mst_medi as (
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
        ROW_NUMBER() OVER(
            order by 
            case  
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
SELECT
    CASE @crud
        WHEN ''del'' then
            CASE @dumpResult
                WHEN ''1'' THEN ''01''
                ELSE ''02''
            END 
        ELSE ''01''
    END AS detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    sort_key,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
    1 AS medi_count,
    LPAD(RIGHT(procedure_hosp_cd,2),2,'' '') AS procedure_hosp_cd
FROM
    sort_order
WHERE
    sort_key <= 10
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
UNION ALL
SELECT
    CASE @crud
        WHEN ''del'' then
            CASE @dumpResult
                WHEN ''1'' THEN ''01''
                ELSE ''02''
            END 
        ELSE ''01''
    END AS detail_id,
    @key0 AS key0,
    @facilityCd AS facility_cd,
    @ctlNo AS ctl_no,
    @ordNo AS ord_no,
    @patId AS pat_id,
    ROW_NUMBER() OVER (ORDER BY rp_num) AS sort_key,
    rp_num,
    COUNT(*) AS medi_count,
    MIN(LPAD(RIGHT(procedure_hosp_cd,2),2,'' '')) AS procedure_hosp_cd
FROM
    medi_numbering
WHERE
    rp_num <= 10
    AND new_sort_key <= 20
    AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
GROUP BY
    rp_num
-- SQL:-1102003 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1102002, '-- SQL: -1102002 begin
WITH RECURSIVE coop_ini_info AS (
--連携設定より取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
        ''SCM_COMMON'',
        ''SCM_IN_HOSPITAL_CD'',
        ''SCM_CONV_UNIT_EQUIP'',
        ''SCM_CONV_UNIT_MEDI''
    )
)
, ini_unit_medi AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)
, ini_unit_equip AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_EQUIP''
)
, ini_value AS (
--連携設定からvalue値取得
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''TREAT_ITEM_UNIT'') AS treat_item_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''DIALYZER_UNIT'') AS dialyzer_unit,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') AS medicine_send_type,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_TREATMENT'') AS hosp_get_mst_treatment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_EQUIPMENT'') AS hosp_get_mst_equipment,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYZER'') AS hosp_get_mst_dialyzer,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure,
    (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_DIALYSIS_DIFFICULTY'') AS hosp_get_mst_dia_diff
)
, auth_info AS (
--患者個人情報取得(pre_sqlにて取得)
SELECT
  auth_info ->> ''dial_diff_cd'' AS dial_diff_cd,
  auth_info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  json_array_elements(@patPersonalInfo::json) auth_info
)
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  (t1.info ->> ''cd'')::integer AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.facility_cd = @facilityCd
  AND mst.is_shot IS DISTINCT FROM ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
)
, medi_order_data AS (
--施設設定107设置获取
    SELECT
        ROW_NUMBER() OVER () AS no2,
        datt.a1
    FROM (
        SELECT
            TO_NUMBER(val, ''999999999999'') AS a1
        FROM unnest(
            COALESCE(
            string_to_array(
                (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3007''
                    AND mst_f.facility_cd = @facilityCd
                ),
                '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
            )
        ) AS val
    ) AS datt
)
, medi_order AS (
-- 薬剤マスタ表示順
SELECT
  index_no ::int AS medi_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
-- 薬剤分類マスタ表示順
SELECT
  index_no ::int AS medi_class_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
-- 投与タイミングマスタ表示順
SELECT
  index_no ::int AS timing_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
-- 手技マスタ表示順
SELECT
  index_no ::int AS procedure_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
-- 薬剤マスタから薬剤コード、薬剤分類コード表示順をまとめ
SELECT
  medicine_cd,
  class_cd,
  medi_order.medi_code_order,
  medi_class_order.medi_class_code_order
FROM
  mst_medicine mmd
LEFT JOIN medi_order ON
  mmd.medicine_cd = medi_order.medi_code
LEFT JOIN medi_class_order ON
  mmd.class_cd = medi_class_order.medi_class_code
WHERE
  facility_cd = @facilityCd
)
, equip_order_data AS (
-- 施設設定マスタから、医療材料表示順を取得
    SELECT
        ROW_NUMBER() OVER () AS no2,
        TO_NUMBER(val, ''999999999999'') AS ora
    FROM UNNEST(
        COALESCE(
            string_to_array(
            (
                SELECT mst_f.value
                FROM mst_facility_setting AS mst_f
                WHERE mst_f.facility_setting_no = ''3006''
                AND mst_f.facility_cd = @facilityCd
            ),
            '',''
            ),
            ARRAY[''0'']  -- デフォルトで0:登録順を返却
        )
    ) AS val
)
, equip_order AS (
-- 医療材料マスタ表示順
SELECT
  index_no ::int AS meq_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment''
)
, equip_class_order AS (
-- 医療材料分類マスタ表示順
SELECT
  index_no ::int AS meq_class_code_order,
  TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
FROM
  mst_selector
CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ORDINALITY AS tmp(order_cd, index_no)
WHERE
  facility_cd = @facilityCd
  AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
-- 医療材料マスタと表示順
SELECT
  equipment_cd,
  equipment_name,
  class_cd,
  unit,
  in_hospital_cd_1,
  equip_order.meq_code_order,
  equip_class_order.meq_class_code_order
FROM
  mst_equipment meq
LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
WHERE
  facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info,
            ord.ind_treatment_cd,
            ord.ind_cond_info,
            ord.ind_equip_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
            AND journal.ord_no = @ordNo            
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info,
            ord.ind_treatment_cd,
            ord.ind_cond_info,
            ord.ind_equip_info
        FROM
            ord_main AS ord
        WHERE
        	ord.is_del = ''0''
            AND ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND ord.pat_id = @patId
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ind_treatment AS (
-- 治療方法コード
SELECT
  10000000 AS temp_no,
  om.ind_treatment_cd AS mst_cd,
  CASE
    -- 両方とも利用開始日以降の場合
    WHEN ((om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate)
      AND (om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate)) THEN
      CASE
      WHEN mt.in_hosp_a_startdate >= mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_a1
        WHEN ''2'' THEN mt.in_hospital_cd_a2
        WHEN ''3'' THEN mt.in_hospital_cd_a3
        WHEN ''4'' THEN mt.in_hospital_cd_a4
      END
      WHEN mt.in_hosp_a_startdate < mt.in_hosp_b_startdate THEN
          CASE
        ini_value.hosp_get_mst_treatment
            WHEN ''1'' THEN mt.in_hospital_cd_b1
        WHEN ''2'' THEN mt.in_hospital_cd_b2
        WHEN ''3'' THEN mt.in_hospital_cd_b3
        WHEN ''4'' THEN mt.in_hospital_cd_b4
      END
    END
    -- 治療日よりAの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_a_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_a1
      WHEN ''2'' THEN mt.in_hospital_cd_a2
      WHEN ''3'' THEN mt.in_hospital_cd_a3
      WHEN ''4'' THEN mt.in_hospital_cd_a4
    END
    -- 治療日よりBの利用日開始日以降の場合
    WHEN om.treat_date::TIMESTAMP >= mt.in_hosp_b_startdate THEN
      CASE
      ini_value.hosp_get_mst_treatment
        WHEN ''1'' THEN mt.in_hospital_cd_b1
      WHEN ''2'' THEN mt.in_hospital_cd_b2
      WHEN ''3'' THEN mt.in_hospital_cd_b3
      WHEN ''4'' THEN mt.in_hospital_cd_b4
    END
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.treat_item_unit, '''') AS unit
FROM
  ord_main_max om
INNER JOIN mst_treatment AS mt ON
  mt.treatment_cd = om.ind_treatment_cd
  AND mt.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_dialyzer AS (
-- ダイアライザ
SELECT
  20000000 AS temp_no,
  (om.ind_cond_info->''5''->>''value'')::integer AS mst_cd,
  CASE
    ini_value.hosp_get_mst_dialyzer
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  COALESCE(ini_value.dialyzer_unit, '''') AS unit
FROM
  ord_main_max om
INNER JOIN mst_dialyzer AS mst ON
  mst.dialyzer_cd::text = om.ind_cond_info->''5''->>''value''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
)
, ind_adsorption AS (
-- 吸着カラム
SELECT
  21000000 AS temp_no,
  (om.ind_cond_info->''6''->>''value'')::integer AS mst_cd,
  21000000 AS meq_class_code_order,
  21000000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''6''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''6''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_coagulant AS (
-- 抗凝固剤
SELECT
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 30000000
        WHEN ''2'' THEN 30000000 + mst_mix.idx
      END
  END AS temp_no,
  CASE om.ind_cond_info -> ''25'' ->>''medicine_type''
    WHEN ''1'' THEN (om.ind_cond_info->''25''->>''value'')::integer
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  30000000 AS medicine_type,
  30000000 AS timing_code_order,
  30000000 AS procedure_code_order,
  30000000 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN (om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric
      WHEN ''2'' THEN 
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              ((om.ind_cond_info->''26''->>''value'')::numeric + (om.ind_cond_info->''28''->>''value'')::numeric) * mst_mix.amount::numeric
        WHEN ''1'' THEN mst_mix.amount::numeric
      END
    END
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''25''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''25''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main_max om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''25''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''25''->>''value''
  AND om.ind_cond_info->''25''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_touseki AS (
-- 透析液
SELECT
  31000000 AS temp_no,
  (om.ind_cond_info->''15''->>''value'')::integer AS mst_cd,
  31000000 AS medi_code_order,
  31000000 AS medi_class_code_order,
  31000000 AS medicine_type,
  31000000 AS timing_code_order,
  31000000 AS procedure_code_order,
  31000000 AS interval_no,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
      WHEN ''1'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
        CASE
        ini_value.hosp_get_mst_medicine
          WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CAST(om.ind_cond_info->''17''->>''value'' AS NUMERIC)
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''15''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''15''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main_max om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''15''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''15''->>''value''
  AND om.ind_cond_info->''15''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_hoeki AS (
-- 補液
SELECT
  32000000 AS temp_no,
  (om.ind_cond_info->''19''->>''value'')::integer AS mst_cd,
  32000000 AS medi_code_order,
  32000000 AS medi_class_code_order,
  32000000 AS medicine_type,
  32000000 AS timing_code_order,
  32000000 AS procedure_code_order,
  32000000 AS interval_no,  
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
        WHEN ''2'' THEN mst_medi.in_hospital_cd_2
        WHEN ''3'' THEN mst_medi.in_hospital_cd_3
        WHEN ''4'' THEN mst_medi.in_hospital_cd_4
        ELSE NULL
      END
      WHEN ''2'' THEN 
          CASE
        ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
        WHEN ''2'' THEN mst_mix.in_hospital_cd_2
        WHEN ''3'' THEN mst_mix.in_hospital_cd_3
        WHEN ''4'' THEN mst_mix.in_hospital_cd_4
        ELSE NULL
      END
    END
  END AS hosp_cd,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      (om.ind_cond_info->''22''->>''value'')::numeric
  END AS amount,
  CASE
    WHEN COALESCE(om.ind_cond_info->''19''->>''value'', '''') = '''' THEN NULL
    ELSE
      CASE
      om.ind_cond_info->''19''->>''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit
FROM
  ord_main_max om
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = om.ind_cond_info->''19''->>''value''
  AND mst_medi.facility_cd = @facilityCd
  AND mst_medi.is_shot IS DISTINCT FROM ''1''
  AND mst_medi.is_del = ''0''
  AND mst_medi.is_disp = ''1''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
LEFT JOIN mst_medi_mix AS mst_mix ON
  mst_mix.mix_cd::text = om.ind_cond_info->''19''->>''value''
  AND om.ind_cond_info->''19''->>''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
CROSS JOIN ini_value
)
, ind_one_film AS (
-- 1次膜
SELECT
  22000000 AS temp_no,
  (om.ind_cond_info->''7''->>''value'')::integer AS mst_cd,
  22000000 AS meq_class_code_order,
  22000000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''7''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''7''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, ind_two_film AS (
-- 2次膜
SELECT
  23000000 AS temp_no,
  (om.ind_cond_info->''8''->>''value'')::integer AS mst_cd,
  23000000 AS meq_class_code_order,
  23000000 AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max om
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = om.ind_cond_info->''8''->>''value''
  AND mst.facility_cd = @facilityCd
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(om.ind_cond_info->''8''->>''value'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  33000000 + t1.idx AS temp_no,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN (t1.medi_info ->> ''cd'')::integer 
    WHEN ''2'' THEN mst_mix.medi_cd
  END AS mst_cd,
  (t1.medi_info ->> ''medicine_type'')::integer AS medicine_type,
  (t1.medi_info ->> ''timing_cd'')::integer AS timing_cd,
  (t1.medi_info ->> ''procedure_cd'')::integer AS procedure_cd,
  (t1.medi_info ->> ''date_interval'')::integer AS interval_no,
  om.treat_date::TIMESTAMP AS treat_date,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
         END
      WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
    END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN TRUNC((medi_info ->> ''amount'')::NUMERIC, 4)
      WHEN ''2'' THEN
          CASE
        mst_mix.solvent
            WHEN ''0'' THEN
              TRUNC((medi_info ->> ''amount'')::NUMERIC * mst_mix.amount::NUMERIC, 4)
        WHEN ''1'' THEN
              TRUNC(mst_mix.amount::NUMERIC, 4)
      END
      ELSE 0
    END
  END AS amount,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
      CASE
      t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN 
      iumedi.value
      WHEN ''2'' THEN 
      iumix.value
    END
  END AS unit,
  CASE
    WHEN json_array_length(om.ind_medi_info::json) = 0 THEN NULL
    ELSE
        CASE t1.medi_info ->> ''medicine_type''
             WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot
FROM
  ord_main_max om
CROSS JOIN LATERAL json_array_elements(om.ind_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON
  mst_medi.medicine_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''1''
    AND mst_medi.facility_cd = @facilityCd
    AND mst_medi.is_del = ''0''
    AND mst_medi.is_disp = ''1''
LEFT JOIN ini_unit_medi AS iumedi ON mst_medi.unit = iumedi.key2
  LEFT JOIN mst_medi_mix AS mst_mix ON
    mst_mix.mix_cd::text = medi_info ->> ''cd''
    AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN ini_unit_medi AS iumix ON mst_mix.unit = iumix.key2
  CROSS JOIN ini_value
)
, pro_code AS (
    --手技の院内コード
    SELECT
        MIN(NULLIF(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_get_mst_procedure
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_get_mst_procedure
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END,'''')) AS pro_hosp_cd,
        MIN(mp.pricedure_name) AS pricedure_name,
        omi.procedure_cd
    FROM
        medi_indo omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN ini_value
    GROUP BY
        omi.procedure_cd
)
, ind_equip_info AS (
-- 医療材料コード
SELECT
  24000000 + t1.idx AS temp_no,
  (t1.equip_info ->> ''cd'')::integer AS mst_cd,
  24000000 + meq.meq_class_code_order AS meq_class_code_order,
  24000000 + meq.meq_code_order AS meq_code_order,
  CASE
    ini_value.hosp_get_mst_equipment
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    WHEN ''3'' THEN mst.in_hospital_cd_3
    WHEN ''4'' THEN mst.in_hospital_cd_4
    ELSE NULL
  END AS hosp_cd,
  CAST(t1.equip_info->>''amount'' AS NUMERIC) AS amount,
  ini_unit_equip.value AS unit
FROM
  ord_main_max om
CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) WITH ORDINALITY AS t1(equip_info, idx)
INNER JOIN mst_equipment AS mst ON
  mst.equipment_cd::text = t1.equip_info ->> ''cd''
LEFT OUTER JOIN mst_equip AS meq ON
  meq.equipment_cd = TO_NUMBER(t1.equip_info ->> ''cd'', ''FM999999999999'')
LEFT OUTER JOIN mst_equipment_class AS meqc ON
  meqc.class_cd = meq.class_cd
  AND meqc.facility_cd = @facilityCd
LEFT JOIN ini_unit_equip ON mst.unit = ini_unit_equip.key2
CROSS JOIN ini_value
)
, dial_diff_info AS (
-- 透析困難コード
SELECT
  13000000 AS temp_no,
  CASE
    ini_value.hosp_get_mst_dia_diff
    WHEN ''1'' THEN mst.in_hospital_cd_1
    WHEN ''2'' THEN mst.in_hospital_cd_2
    ELSE NULL
  END AS hosp_cd,
  1 AS amount,
  '''' AS unit
FROM
  auth_info ai
LEFT JOIN mst_dialysis_difficulty AS mst ON
  mst.dialysis_difficulty_cd::text = ai.dial_diff_cd
  AND mst.is_del = ''0''
  AND mst.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  ai.is_dial_diff = ''1''
)
, medi_union_1 AS (
-- 薬剤情報（抗凝固剤、透析液、補液、投与薬剤情報(手技なし)）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
      CASE 
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
      END,
      CASE
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
        WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
      END,
      medi_code_order
      ) AS sort_num
FROM
  (SELECT
    coa.temp_no AS temp_no,
    coa.medicine_type AS medicine_type,
    coa.timing_code_order AS timing_code_order,
    coa.procedure_code_order AS procedure_code_order,
    coa.interval_no AS interval_no,
    ''抗凝固剤'' AS title,
    coa.mst_cd AS mst_cd,
    30000000 + mst_medi.medi_code_order AS medi_code_order,
    30000000 + mst_medi.medi_class_code_order AS medi_class_code_order,
    coa.hosp_cd AS hosp_cd,
    COALESCE(coa.amount,0) AS amount,
    coa.unit AS unit
  FROM
    ind_coagulant coa
    LEFT JOIN mst_medi ON coa.mst_cd = mst_medi.medicine_cd
  WHERE
    coa.mst_cd IS NOT NULL
UNION ALL
  SELECT
    tou.temp_no AS temp_no,
    tou.medicine_type AS medicine_type,
    tou.timing_code_order AS timing_code_order,
    tou.procedure_code_order AS procedure_code_order,
    tou.interval_no AS interval_no,
    ''透析液'' AS title,
    tou.mst_cd AS mst_cd,
    tou.medi_code_order AS medi_code_order,
    tou.medi_class_code_order AS medi_class_code_order,
    tou.hosp_cd AS hosp_cd,
    COALESCE(tou.amount,0) AS amount,
    tou.unit AS unit
  FROM
    ind_touseki tou
  WHERE
    tou.mst_cd IS NOT NULL
UNION ALL
  SELECT
    hoe.temp_no AS temp_no,
    hoe.medicine_type AS medicine_type,
    hoe.timing_code_order AS timing_code_order,
    hoe.procedure_code_order AS procedure_code_order,
    hoe.interval_no AS interval_no,
    ''補液'' AS title,
    hoe.mst_cd AS mst_cd,
    hoe.medi_code_order AS medi_code_order,
    hoe.medi_class_code_order AS medi_class_code_order,
    hoe.hosp_cd AS hosp_cd,
    COALESCE(hoe.amount,0) AS amount,
    hoe.unit AS unit
  FROM
    ind_hoeki hoe
  WHERE
    hoe.mst_cd IS NOT NULL
UNION ALL
  SELECT
    MIN(imi.temp_no) AS temp_no,
    33000000 + MIN(imi.medicine_type) AS medicine_type,
    33000000 + MIN(t.timing_code_order) AS timing_code_order,
    33000000 + MIN(p.procedure_code_order) AS procedure_code_order,
    33000000 + MIN(imi.interval_no) AS interval_no,
    ''投与薬剤情報(手技なし）'' AS title,
    MIN(imi.mst_cd) AS mst_cd,
    33000000 + MIN(mst_medi.medi_code_order) AS medi_code_order,
    33000000 + MIN(mst_medi.medi_class_code_order) AS medi_class_code_order,
    imi.hosp_cd AS hosp_cd,
    SUM(imi.amount) AS amount,
    MIN(imi.unit) AS unit
  FROM
    medi_indo imi
    LEFT JOIN pro_code pc ON pc.procedure_cd = imi.procedure_cd
    LEFT JOIN mst_medicine mm ON imi.mst_cd = mm.medicine_cd
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = imi.timing_cd
    LEFT JOIN procedure_order p ON p.procedure_code = imi.procedure_cd
  WHERE
    imi.mst_cd IS NOT NULL
    AND imi.is_shot IS DISTINCT FROM ''1''
    AND (imi.procedure_cd IS NULL
    OR pc.pro_hosp_cd IS NULL
    )
  GROUP BY
  imi.hosp_cd
) AS ind_medi_table
ORDER BY
  sort_num
)
, medi_union_2 AS (
SELECT
  imi2.temp_no,
  imi2.medicine_type,
  imi2.timing_cd,
  imi2.interval_no,
  ''投与薬剤情報(薬剤）'' AS title,
  imi2.mst_cd AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  imi2.amount AS amount,
  imi2.unit AS unit,
  pc.pricedure_name AS pro_title,
  imi2.procedure_cd AS procedure_cd,
  pc.pro_hosp_cd
FROM
  medi_indo imi2
  LEFT JOIN pro_code pc ON imi2.procedure_cd = pc.procedure_cd
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot IS DISTINCT FROM ''1''
  AND imi2.procedure_cd IS NOT NULL
  AND pc.pro_hosp_cd IS NOT NULL
  AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 0

UNION ALL
SELECT
  MIN(imi2.temp_no) AS temp_no,
  MIN(imi2.medicine_type) AS medicine_type,
  MIN(imi2.timing_cd) AS timing_cd,
  MIN(imi2.interval_no) AS interval_no,
  ''投与薬剤情報(薬剤）'' AS title,
  MIN(imi2.mst_cd) AS mst_cd,
  imi2.hosp_cd AS hosp_cd,
  SUM(imi2.amount) AS amount,
  MAX(imi2.unit) AS unit,
  MAX(pc.pricedure_name) AS pro_title,
  MIN(imi2.procedure_cd) AS procedure_cd,
  pc.pro_hosp_cd
FROM
  medi_indo imi2
  LEFT JOIN pro_code pc ON imi2.procedure_cd = pc.procedure_cd
WHERE
  imi2.mst_cd IS NOT NULL
  AND imi2.is_shot IS DISTINCT FROM ''1''
  AND imi2.procedure_cd IS NOT NULL
  AND pro_hosp_cd IS NOT NULL
  AND (SELECT medicine_send_type::NUMERIC FROM ini_value) = 1
GROUP BY
  pc.pro_hosp_cd,
  imi2.hosp_cd
)
, medi_union_2_with_sorted as (
    select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    pro_title,
    procedure_cd,
    pro_hosp_cd,
    ROW_NUMBER() OVER(
        ORDER BY
        CASE 
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no
        END,
        CASE
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
            WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no
        END,
        medi_code_order
        ) AS in_grp_rank
    from medi_union_2
    LEFT JOIN mst_medi mmd ON mst_cd = mmd.medicine_cd
    LEFT JOIN timing_order ON timing_cd = timing_order.timing_code
    LEFT JOIN procedure_order ON procedure_cd = procedure_order.procedure_code
    order by in_grp_rank
)
, group_scored AS (
  SELECT
    r.*,
    -- 各グループ（pro_hosp_cd）に属する行の中で最小の in_grp_rank をグループの「強さ」として採用
    -- → グループ内で一番上位に来る要素の順位をグループ全体の強さの代表値とする
    MIN(in_grp_rank) OVER (PARTITION BY pro_hosp_cd) AS grp_strength
  FROM medi_union_2_with_sorted r
)
, with_grp_order AS (
  SELECT
    g.*,
    -- grp_strength が若い（= グループの代表+順位が高い）ほど強いとみなし、グループに順位を付与
    -- → 強いグループから順に DENSE_RANK() を振る
    DENSE_RANK() OVER (ORDER BY grp_strength) AS grp_rank_by_strength
  FROM group_scored g
)
, procedure_medi_sorted AS (
-- 薬剤ごとに出力する場合は施設設定マスタの並び順をそのまま出力
  select 
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    in_grp_rank as sort_num
  from medi_union_2_with_sorted
  cross join ini_value
  where ini_value.medicine_send_type = ''0''
  union all
-- 手技でまとめる場合はgroup_scored、with_grp_orderの処理結果を出力
  SELECT
    title,
    mst_cd,
    hosp_cd,
    amount,
    unit,
    procedure_cd,
    pro_hosp_cd,
    -- グループ順位 × 大きな係数 + グループ内順位 で全体のソートキーを生成
    (grp_rank_by_strength * 1000000) + in_grp_rank AS sort_num
  FROM with_grp_order
  cross join ini_value
  where ini_value.medicine_send_type = ''1''
  ORDER BY sort_num
)
, equip_union AS (
-- 医療材料情報（吸着カラム,1次膜,2次膜,医療材料情報）
SELECT
  title,
  hosp_cd,
  amount,
  unit,
  ROW_NUMBER() OVER(
      ORDER BY
  CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN ind_equip_table.meq_code_order END,
    CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN ind_equip_table.temp_no
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN ind_equip_table.meq_class_code_order
        WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN ind_equip_table.meq_code_order END, 
    ind_equip_table.meq_code_order
      ) AS sort_num
FROM
  (SELECT
    ''吸着カラム'' AS title,
    ads.*
  FROM
    ind_adsorption ads
  WHERE
    ads.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''1次膜'' AS title,
    one.*
  FROM
    ind_one_film one
  WHERE
    one.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''2次膜'' AS title,
    two.*
  FROM
    ind_two_film two
  WHERE
    two.mst_cd IS NOT NULL
UNION ALL
  SELECT
    ''医療材料情報'' AS title,
    iei.*
  FROM
    ind_equip_info iei
  WHERE
    iei.mst_cd IS NOT NULL    
) AS ind_equip_table
ORDER BY
  sort_num
)
, equip_sort_num AS (
SELECT
  DISTINCT ON (un.hosp_cd) un.hosp_cd AS hosp_cd,
  un.r_num
FROM
  (SELECT
    ROW_NUMBER() OVER () AS r_num,
    ut.hosp_cd
  FROM
    equip_union ut
) AS un
ORDER BY
  un.hosp_cd,
  un.r_num
)
, equip_sort_union AS (
-- 医療材料情報の合算とソート
SELECT
  ams.title,
  ams.hosp_cd AS hosp_cd,
  ams.amount AS amount,
  ams.unit AS unit,
  NULL AS proc_cd
FROM
  (SELECT
    STRING_AGG(DISTINCT title, ''-'') AS title,
    hosp_cd,
    SUM(amount) AS amount,
    unit
  FROM
    equip_union
  GROUP BY
    hosp_cd,
    unit
) AS ams
INNER JOIN equip_sort_num AS un ON un.hosp_cd = ams.hosp_cd
ORDER BY un.r_num
)
, union_table AS (
-- 全項目をUNION ALL
SELECT
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL AS proc_cd
FROM
  ind_treatment tre
WHERE
  tre.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''透析困難コード'' AS title,
  ddi.hosp_cd AS hosp_cd,
  ddi.amount AS amount,
  ddi.unit AS unit,
  NULL AS proc_cd
FROM
  dial_diff_info ddi
WHERE
  ddi.hosp_cd IS NOT NULL
UNION ALL
SELECT
  ''ダイアライザ'' AS title,
  dia.hosp_cd AS hosp_cd,
  dia.amount AS amount,
  dia.unit AS unit,
  NULL AS proc_cd
FROM
  ind_dialyzer dia
WHERE
  dia.hosp_cd IS NOT NULL
UNION ALL
SELECT
  eu.title AS title,
  eu.hosp_cd AS hosp_cd,
  eu.amount AS amount,
  eu.unit AS unit,
  NULL AS proc_cd
FROM
  equip_sort_union eu
WHERE
  eu.hosp_cd IS NOT NULL
UNION ALL
SELECT
  mu1.title AS title,
  mu1.hosp_cd AS hosp_cd,
  mu1.amount AS amount,
  mu1.unit AS unit,
  NULL AS proc_cd
FROM
  medi_union_1 mu1
WHERE
  mu1.hosp_cd IS NOT NULL
UNION ALL
SELECT
  pms.title AS title,
  pms.hosp_cd AS hosp_cd,
  pms.amount AS amount,
  pms.unit AS unit,
  pms.pro_hosp_cd AS proc_cd
FROM
  procedure_medi_sorted pms
WHERE
  pms.hosp_cd IS NOT NULL
)
, numbered AS (
SELECT
  *,
  ROW_NUMBER() OVER () AS rn
FROM
  union_table
)
, recursive_rp AS (
-- 再帰で RP, RpItem を採番
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  1 AS RP,
  1 AS RpItem,
  NULL::text AS last_proc_cd,
  ARRAY[]::text[] AS proc_cd_list,
  FALSE AS need_procedure_insert,
  FALSE AS need_treatment_insert
FROM
  numbered n,
  ini_value m
WHERE
  n.rn = 1
UNION ALL
SELECT
  n.rn,
  n.title,
  n.hosp_cd,
  n.amount,
  n.unit,
  n.proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.RP + 1
    WHEN r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL) THEN r.RP + 1
    ELSE r.RP
  END AS RP,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
       OR (r.RpItem >= 20 OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL))) THEN 2
    ELSE r.RpItem + 1
  END AS RpItem,
  CASE
    WHEN n.proc_cd IS NOT NULL THEN n.proc_cd
    ELSE r.last_proc_cd
  END AS last_proc_cd,
  CASE
    WHEN n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)) THEN r.proc_cd_list || n.proc_cd
    ELSE r.proc_cd_list
  END AS proc_cd_list,
  CASE
    WHEN ((n.proc_cd IS NOT NULL AND NOT (n.proc_cd = ANY(r.proc_cd_list)))
       OR (m.medicine_send_type::NUMERIC = 0 AND n.proc_cd IS NOT NULL)
       OR r.RpItem >= 20 AND n.proc_cd IS NOT NULL) THEN TRUE
    ELSE FALSE
  END AS need_procedure_insert,
  CASE
    WHEN r.RpItem >= 20 AND n.proc_cd IS NULL THEN TRUE
    ELSE FALSE
  END AS need_treatment_insert
FROM
  recursive_rp r
  JOIN numbered n ON n.rn = r.rn + 1
  CROSS JOIN ini_value m
)

, procedure_inserts AS (
-- 手技コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''手技コード'' AS title,
  last_proc_cd AS hosp_cd,
  1 AS amount,
  '''' AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
WHERE
  need_procedure_insert
)
, treatment_inserts AS (
-- 治療項目コード差し込み
SELECT
  RP,
  1 AS RpItem,
  ''治療方法'' AS title,
  tre.hosp_cd AS hosp_cd,
  tre.amount AS amount,
  tre.unit AS unit,
  NULL::text AS proc_cd,
  (rn - 0.5)::NUMERIC AS sort_key
FROM
  recursive_rp
  CROSS JOIN ind_treatment tre
WHERE
  need_treatment_insert
)
, recursive_rp_with_sort AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  rn::NUMERIC AS sort_key
FROM
  recursive_rp
)
, final_data AS (
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  recursive_rp_with_sort
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  procedure_inserts
UNION ALL
SELECT
  RP,
  RpItem,
  title,
  hosp_cd,
  amount,
  unit,
  proc_cd,
  sort_key
FROM
  treatment_inserts
)
SELECT
  RP AS rp_no,
  RpItem AS item_no,
  CASE 
  WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
  ELSE substring(
      hosp_cd FROM (
      SELECT MIN(i)
      FROM generate_series(1, char_length(hosp_cd)) AS i
      WHERE octet_length(substring(hosp_cd FROM i)) <= 8
      )
  )
  END AS medi_cd,
  TRUNC(amount, 4)::FLOAT8::TEXT AS medi_amount,
  unit,
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id
FROM
  final_data
WHERE
  rp < 11
ORDER BY
  RP,
  sort_key;

-- SQL: -1102002 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムの透析指示_処置項目情報取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}, {"sql_cd": -1102004, "field_name": "pat_personal_info", "replace_var": "@patPersonalInfo"}]');
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100018, '-- SQL: -1100018 begin
WITH params AS (
    SELECT 
        CASE
            WHEN @coopCd in(''ind_dial'',''rst_dial'') THEN 2
            WHEN @coopCd in(''exam_ord'',''rad_ord'') THEN 1
        END AS coopCd
),
memo AS (
    SELECT
        split_part(save_2 ->> ''memo'', ''#'', coopCd) AS memo,
        split_part(save_2 ->> ''memo'', ''#'', coopCd+2) AS karte_memo
    FROM
        pat_coop_detail AS detail,params
    WHERE
        facility_cd = @facilityCd
        AND pat_id = @patId
        AND (save_2 ->> ''ord_no'')::integer = @ordNo
        AND (save_2 ->> ''coop_cd'') = @coopCd
    ORDER BY
        up_date DESC
    LIMIT 1
)
SELECT 
    TO_CHAR(
        TO_DATE(
            split_part(memo, ''|'', @position),
            ''YYYYMMDD''
        ), ''YYYY-MM-DD''
    ) AS send_day,
    TO_CHAR(
        TO_TIMESTAMP(
            split_part(memo, ''|'', @position+1),
            ''HH24MISS''
        ), ''HH24:MI:SS''
    ) AS seq_no,
    TO_CHAR(
        TO_DATE(
            CASE
                WHEN @coopCd in(''ind_dial'',''rst_dial'')
                    THEN split_part(karte_memo, ''|'', @position)
            END , ''YYYYMMDD''
        ), ''YYYY-MM-DD''
    ) AS k_send_day,
    TO_CHAR(
        TO_TIMESTAMP(
            CASE
                WHEN @coopCd in(''ind_dial'',''rst_dial'')
                    THEN split_part(karte_memo, ''|'', @position+1)
            END, ''HH24MISS''
        ), ''HH24:MI:SS''
    ) AS k_seq_no
FROM
    memo
-- SQL: -1100018 end', '2', '[{}]', '0', '{"applications": [4]}', NULL, 'セコム連携 送信履歴メモから発生日/SEQ番号の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100016, 'WITH dump_text AS (
SELECT
  convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM
  sys_coop_journal AS scj
WHERE
  pat_id = @patId
  AND facility_cd = @facilityCd
  AND crud = ''C''
  AND ord_no = @ordNo
  AND coop_cd = @coopCd
  AND key0 = @key0
  AND ana_result = ''9''
  AND coop_result = ''9''
ORDER BY
  scj.up_date DESC
LIMIT 1
)
SELECT
  CASE Count(*)
    WHEN 0 THEN NULL
	ELSE 1
  END AS dump_result
FROM
	dump_text', '2', '[]', '0', '{"applications": [4]}', NULL, 'セコム連携_従来処理呼出判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-1100010, 'select
  CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
@folderName AS folder_name', '2', '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL(カルテ用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]');

