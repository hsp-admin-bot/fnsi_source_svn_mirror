DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-8, -44, -26, -195, 3105, -511, 3110, -63, 3203, 2106, 2101, 2102, 3202, 3107, 3104, 3109, 3102);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-195, 'WITH default_user_no AS (
  -- デフォルト利用者番号（透析予約用）123
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''SCH_DEFAULT_USER_NO''
  UNION
  SELECT
    1 AS order_no
    , '''' AS staff_cd
  ORDER BY order_no ASC LIMIT 1
)
, user_no_setting AS (
  -- 利用者番号出力設定（透析予約用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''SCH_USER_NO_SETTING''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS setting
  ORDER BY order_no ASC LIMIT 1
)
, ind_upd_user_info AS(
  -- 指示者
  -- 操作者
  (SELECT
    0 AS order_no
    , om.ind_schedule_user_info ->> ''ind_user_id'' AS ind_staff_cd 
    , om.ind_schedule_user_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main_restore AS om
  WHERE
    om.ord_no = @ordNo
 
    AND om.facility_cd = @facilityCd
 
    AND om.is_del = ''0'' 
		ORDER BY om.del_date DESC LIMIT 1)
  UNION 
  (SELECT
    1 AS order_no
    , ind_cond_info ->> ''ind_user_id'' AS ind_staff_cd 
    , ind_cond_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    (SELECT
       om.ind_cond_info -> jsonb_object_keys(om.ind_cond_info) AS ind_cond_info 
     FROM
       ord_main_restore AS om 
     WHERE
       om.ord_no = @ordNo
 
     AND om.facility_cd = @facilityCd
 
     AND om.is_del = ''0'' 
		 ORDER BY om.del_date DESC
     LIMIT 1 ) AS T)
  UNION 
  (SELECT
    2 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main_restore AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_medi_info ::json) info 
  WHERE
    om.ord_no = @ordNo
 
  AND om.facility_cd = @facilityCd
 
  AND om.is_del = ''0'' 
	ORDER BY om.del_date DESC LIMIT 1)
  UNION
  (SELECT
    3 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main_restore AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) info 
  WHERE
    om.ord_no = @ordNo
 
  AND om.facility_cd = @facilityCd
 
  AND om.is_del = ''0'' 
	ORDER BY om.del_date DESC LIMIT 1)
  UNION
  (SELECT
    4 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main_restore AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_ind_comment_info ::json) info 
  WHERE
    om.ord_no = @ordNo
 
    AND om.facility_cd = @facilityCd
 
    AND om.is_del = ''0'' 
  ORDER BY order_no ASC, om.del_date DESC LIMIT 1)
)
, staff_user_info AS(
  -- 担当者
  SELECT
    ROW_NUMBER() OVER (ORDER BY staff ->> ''is_main'' DESC, staff ->> ''is_charge'' DESC, staff ->> ''is_puncture'' DESC, staff ->> ''ctl_no'' ASC) AS CNT
    , staff ->> ''staff_cd'' AS staff_cd 
  FROM
    pat_main pm 
    CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
  WHERE
    pm.is_del = ''0'' 
    AND pm.pat_id = @patId
 
    AND staff ->> ''is_main'' = ''1'' 
)
,
 mst_user_authenticator as (--常勤医
         select 
                (json_array_elements((mst.mst_user_authentication ->> ''data'')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main_restore ord where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Mon''
                                 when 2 = (select treat_week from ord_main_restore where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Tues''
                                 when 3 = (select treat_week from ord_main_restore where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Wednes''
                                 when 4 = (select treat_week from ord_main_restore ord where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Thurs''
                                 when 5 = (select treat_week from ord_main_restore where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Fri''
                                 when 6 = (select treat_week from ord_main_restore ord where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Satur''
                                 when 7 = (select treat_week from ord_main_restore ord where ord.ord_no = @ordNo ORDER BY del_date
																 desc limit 1
)
                                     then ''Sun''
                                 END) as aaa))::json ->> ''user_id'' as staff_cd
         from (select * from ord_main_restore where ord_no = @ordNo ORDER BY del_date
																 desc limit 1 ) ord,
              mst_kur mst
         where ord.ind_kur_cd = mst.kur_cd)	 
SELECT
  COALESCE(NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), ''''),'''') staff_cd_comm
  , COALESCE(NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), ''''),'''') staff_cd_data,
  (SELECT staff_cd  AS default_staff_cd FROM default_user_no)
FROM
  ( 
    -- 0：共通部 指示者
    SELECT ''comm'' AS part, ind_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) = ''0''
    -- 1：共通部 担当医１
    -- 4：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'') AND CNT = 1
    -- 2：共通部 担当医２
    -- 5：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'') AND CNT = 2
    -- 3：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, upd_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) IN (''3'',''4'',''5'')
   UNION 
    SELECT ''comm'' AS part,  staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) = ''6''
    -- 0：内容部 指示者
    -- 3：内容部 指示者
    UNION 
    SELECT ''data'' AS part, ind_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) IN (''0'', ''3'')
    -- 1：内容部 担当医１
    -- 4：内容部 担当医１
    UNION 
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'') AND CNT = 1
    -- 2：内容部 担当医２
    -- 5：内容部 担当医２
    UNION 
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'') AND CNT = 2
		   UNION 
    SELECT ''data'' AS part,  staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) = ''6''
  ) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：共通部と伝票情報の利用者番号取得', '2022-02-28 14:34:34.866', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3107, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録GCJL
select case when staff_cd like ''%2%'' then ''2'' else ''0'' end  as taking from (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd''
    AND info ->> ''key1'' = ''ORDER_RECV''
    AND info ->> ''key2'' = ''ORDER_RECV_TAKING'')   as taking_info 
)
, sub_category_name_info AS (
  -- 観察記録のサブカテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS sub_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_SUB_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS sub_category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_name_info AS (
  -- 観察記録カテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_info AS (
  -- 観察記録の内容
  SELECT
    template.template_cd
    , template.template_name
    , cat.category_cd
    , cat.category_name
    , sub_cat.use_type
    , template.input_params
    , sub_cat.sub_category_cd
    , sub_cat.sub_category_name
  FROM
    mst_pat_event_sub_category AS sub_cat
    INNER JOIN mst_pat_event_category AS cat ON cat.is_del = ''0'' AND cat.is_disp=''1'' AND cat.category_cd=sub_cat.category_cd AND category_name = (SELECT category_name FROM category_name_info)
    INNER JOIN mst_pat_event_data_template AS template ON template.is_del = ''0'' AND template.is_disp=''1'' AND template.template_cd = sub_cat.template_cd
    CROSS JOIN LATERAL jsonb_array_elements(template.input_params ::jsonb) AS info 
  WHERE
    sub_cat.is_del = ''0'' 
    AND sub_cat.is_disp = ''1'' 
    AND sub_cat.facility_cd = ''@facilityCd'' 
    AND sub_cat.sub_category_name = (SELECT sub_category_name FROM sub_category_name_info)
    AND info->>''format_class''  = ''1'' -- テンプレートにテキストエリアが有りか
  ORDER BY 
   sub_cat.sub_category_cd ASC LIMIT 1
) 
, result_params_info AS ( 
  SELECT
    json_build_object(''format_class'', TO_NUMBER((info->>''format_class'' :: TEXT), ''FM999999999999'')
      , ''result_value'' 
      , CASE (info->>''format_class'' :: TEXT)
        WHEN ''1'' THEN
				case when (''浄化申込情報'' = (select sub_category_name from sub_category_name_info)
				and ''連携通知'' = (select category_name from category_name_info)
				)
				then
				to_jsonb(''<p>'' || REPLACE(''@patMemoInfo.content'','' 【'',''</p><p>【'')||''</p>'')
				else
				to_jsonb('''' || REPLACE(''@patMemoInfo.content'','' 【'',E''\n【'')) 
				end
        WHEN ''10'' THEN jsonb_build_object(''notice_start_date'',null, ''notice_end_date'',null, ''staff_info'', jsonb_build_object(''target'',''0'', ''staff_cd'',''[-1]''::JSONB))
        ELSE null END
     ) AS result_params 
  FROM
    category_info
    CROSS JOIN LATERAL jsonb_array_elements(input_params ::jsonb) AS info 
)
INSERT 
INTO pat_event (
  pat_id
  , facility_cd
  , fn_ctl_no
  , event_status
  , template_cd
  , template_name
  , category_cd
  , category_name
  , ord_no
  , input_params
  , event_start_date
  , sub_category_cd
  , sub_category_name
  , result_params
  , score_total
  , reg_staff_info
  , up_staff_info
  , bbs_ctl_no
  , is_newest
  , is_del
  , reg_date
  , up_date
  , letter_info
  , use_type
  , event_end_date
  , event_start_time
  , event_end_time
  , report_url
  , report_date
)
SELECT
  @patId AS pat_id
  , ''@facilityCd'' AS facility_cd
  , 0 AS fn_ctl_no
  , ''1'' AS event_status
  , template_cd
  , template_name
  , category_cd
  , category_name
  , 0 AS ord_no
  , input_params
  , SUBSTR(''@regDate'', 1, 8) AS event_start_date
  , sub_category_cd
  , sub_category_name
  , ((SELECT array_to_json(ARRAY_AGG(result_params)) FROM result_params_info)::JSONB || (''[{"upDate":"'' || CURRENT_TIMESTAMP || ''"}]'')::JSONB)AS result_params
  , null AS score_total
  , json_build_object(''reg_staff_cd'', -1, ''reg_staff_name'', null) AS reg_staff_info
  , json_build_object(''up_staff_cd'', -1, ''up_staff_name'', null) AS up_staff_info
  , 0 AS bbs_ctl_no
  , ''1'' AS is_newest
  , ''0'' AS is_del
  , CURRENT_TIMESTAMP AS reg_date
  , CURRENT_TIMESTAMP AS up_date
  , null AS letter_info
  , use_type
  , SUBSTR(''@regDate'', 1, 8) AS event_end_date
  , NULLIF(SUBSTR(''@regDate'', 9, 4), ''0000'') AS event_start_time
  , null AS event_end_time
  , null AS report_url
  , null AS report_date
FROM category_info
WHERE
  ''@patMemoInfo.content'' != ''''
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録(患者イベント情報)_登録', '2022-03-14 14:46:10.256', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3109, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録jsb
 select case when staff_cd like ''%2%'' then ''2'' else ''0'' end  as taking from (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd''
    AND info ->> ''key1'' = ''ORDER_RECV''
    AND info ->> ''key2'' = ''ORDER_RECV_TAKING'')   as taking_info 
),
bbs_title AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録memo
SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS bbs_title
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = ''@facilityCd''
	AND is_del = ''0''
	-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
	AND COALESCE(info->>''key0'','''') = @key0
	-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
	AND info ->> ''key1'' = ''ORDER_RECV''
	AND info ->> ''key2'' = ''ORDER_RECV_BBS_TITLE''
)
, bbs_flag_info AS (
  -- 掲示板出力フラグ:0または未設定：出力なし、1：出力あり
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_FLAG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_flag
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_life_list_flg_info AS (
  -- 掲示板_観察記録出力フラグ:0または未設定：出力なし、1：出力あり
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS bbs_life_list_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_LIFE_LIST_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_life_list_flg
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_span_info AS (
  -- 掲示板掲載期間:当日からの掲載日数を指定（0または未設定：当日のみ）
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'')
      END AS bbs_span 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_SPAN'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS bbs_span
  ORDER BY
    order_no ASC LIMIT 1
)
, bbs_category_name_info AS (
  -- 掲示板のカテゴリ名
  SELECT
     CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
      ELSE TRIM(ini_info ->> ''value'') 
      END AS bbs_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_CATEGORY_NAME'' 
)
, bbs_kind_info AS (
  -- 掲示板のカテゴリを取得する
  SELECT
    kind_no
    , (select bbs_title from bbs_title) AS title
    , default_contents AS content
    , CASE WHEN T01.bbs_category_name IS NULL THEN 0 ELSE 1 END AS order_no
  FROM
    mst_bbs_kind AS bbs
    LEFT OUTER JOIN (SELECT bbs_category_name FROM bbs_category_name_info) AS T01 ON bbs.kind_name = T01.bbs_category_name AND NULLIF(T01.bbs_category_name, '''') IS NOT NULL
  WHERE 
    bbs.is_del = ''0'' 
    AND bbs.is_disp= ''1'' 
    AND bbs.facility_cd = ''@facilityCd'' 
  ORDER BY
    order_no DESC, kind_no ASC LIMIT 1
)
, notice_date AS (
  -- 掲載開始日時と掲載終了日時
  SELECT
    SUBSTR(''@regDate'', 1, 8) AS start_date
    , SUBSTR(TO_CHAR((TO_DATE(''@regDate'', ''YYYYMMDDHH24MISS'') +  (bbs_span || '' day'')::interval), ''YYYYMMDDHH24MISS''), 1, 8) AS end_date
    , SUBSTR(''@regDate'', 9, 4) AS start_time
    , COALESCE(NULLIF(SUBSTR(''@regDate'', 9, 4), ''0000''), ''2359'') AS end_time
  FROM bbs_span_info
)
, content_info AS (
  -- 掲載内容
  SELECT
    (CASE WHEN (SELECT bbs_life_list_flg FROM bbs_life_list_flg_info) = ''1'' 
      THEN (REPLACE(''@patMemoInfo.content'','' 【'',E''\n【'')) 
      ELSE ''''
      END) AS content
)
, new_bbs_info AS (
  -- 新規データ
  SELECT
    (''@facilityCd'')::TEXT AS facility_cd
    , jsonb_build_object(''target'', ''0'', ''detail'', (''['' || @patId ||'']'')::JSONB) AS pat_info
    , jsonb_build_object(''target'', ARRAY[@staffCd]::integer[], ''read'', ''[]''::JSONB) AS staff_info
    , (''020'')::TEXT AS func_cd
    , kind.kind_no AS kind_no
    , (SELECT content FROM content_info) AS content
    , ''[]''::JSONB AS file_info
    , nd.start_date AS notice_start_date
    , nd.end_date AS notice_end_date
    , -1 AS reg_staff_id
    , null AS reg_staff_name
    , -1 AS upd_staff_id
    , null AS upd_staff_name
    , (''observe-record'')::TEXT AS transition_router_path
    , 1 AS reg_func_class
    , CURRENT_TIMESTAMP AS reg_date
    , CURRENT_TIMESTAMP AS up_date
    , kind.title AS title
    , nd.start_date AS notice_fac_cal_start_date
    , '''' AS notice_fac_cal_end_date
    , ''1''::TEXT AS is_disp_bbs 
    , (''#ffffff'')::TEXT AS color
    , (''<p style=\"font-size: 14pt; font-family: メイリオ;\">'' || (SELECT content FROM content_info) || ''</p>'')::TEXT AS html_content
    , start_time AS notice_fac_cal_start_time
    , '''' AS notice_fac_cal_end_time
    , ''1''::TEXT AS is_time_start_flg
    , ''1''::TEXT AS is_time_end_flg
    , (''#000000'')::TEXT AS font_color
    , ''0''::TEXT AS is_del
    , ''1''::TEXT AS is_disp
  FROM 
    bbs_kind_info AS kind, notice_date AS nd
)
INSERT 
INTO bbs_info (
  facility_cd
  , pat_info
  , staff_info
  , func_cd
  , kind_no
  , content
  , file_info
  , notice_start_date
  , notice_end_date
  , reg_staff_id
  , reg_staff_name
  , upd_staff_id
  , upd_staff_name
  , transition_router_path
  , reg_func_class
  , reg_date
  , up_date
  , title
  , notice_fac_cal_start_date
  , notice_fac_cal_end_date
  , is_disp_bbs 
  , color
  , html_content
  , notice_fac_cal_start_time
  , notice_fac_cal_end_time
  , is_time_start_flg
  , is_time_end_flg
  , font_color
  , is_del
  , is_disp
)
SELECT
  facility_cd
  , pat_info
  , staff_info
  , func_cd
  , kind_no
  , content
  , file_info
  , notice_start_date
  , notice_end_date
  , reg_staff_id
  , reg_staff_name
  , upd_staff_id
  , upd_staff_name
  , transition_router_path
  , reg_func_class
  , reg_date
  , up_date
  , title
  , notice_fac_cal_start_date
  , notice_fac_cal_end_date
  , is_disp_bbs 
  , color
  , html_content
  , notice_fac_cal_start_time
  , notice_fac_cal_end_time
  , is_time_start_flg
  , is_time_end_flg
  , font_color
  , is_del
  , is_disp
FROM new_bbs_info
WHERE
  ''@patMemoInfo.content'' != ''''
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
--   AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  AND (SELECT bbs_flag FROM bbs_flag_info) = ''1'' -- 掲示板出力フラグ＝「1：出力あり」
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報_登録', '2022-03-14 14:46:10.256', CURRENT_TIMESTAMP, '[{"sql_cd": 2020, "field_name": "staff_cd", "replace_var": "@staffCd"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3110, 'WITH pat_event_cd_info AS (
  -- この部分SQLは3016のSQLです
  WITH taking_title_info AS (
    -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
        ELSE TRIM(ini_info ->> ''value'') 
        END AS taking_title 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
      AND TRIM(ini_info ->> ''key2'') = @patMemoInfo.title 
      AND @patMemoInfo.title != ''''
    UNION 
    SELECT
      2 AS order_no
      , '''' AS taking_title
    ORDER BY
      order_no ASC LIMIT 1
  )
  , sub_category_name_info AS (
    -- 観察記録のサブカテゴリ名
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END AS sub_category_name 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_SUB_CATEGORY_NAME'' 
    UNION 
    SELECT
      2 AS order_no
      , ''観察記録'' AS sub_category_name
    ORDER BY
      order_no ASC LIMIT 1
  )
  , category_name_info AS (
    -- 観察記録カテゴリ名
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END AS category_name 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_CATEGORY_NAME'' 
    UNION 
    SELECT
      2 AS order_no
      , ''観察記録'' AS category_name
    ORDER BY
      order_no ASC LIMIT 1
  )
  , taking_info AS (
    -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
    SELECT
      1 AS order_no
      , ''2'' AS taking
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
      AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
        OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
    UNION 
    SELECT
      2 AS order_no
      , ''0'' AS taking
    ORDER BY
      order_no ASC LIMIT 1
  )
  , category_info AS (
      -- 観察記録の内容
      SELECT
          template.template_cd
          , template.template_name
          , cat.category_cd
          , cat.category_name
          , sub_cat.use_type
          , template.input_params
          , sub_cat.sub_category_cd
          , sub_cat.sub_category_name
      FROM
          mst_pat_event_sub_category AS sub_cat
          INNER JOIN mst_pat_event_category AS cat ON cat.is_del = ''0'' AND cat.is_disp=''1'' AND cat.category_cd=sub_cat.category_cd AND category_name = (SELECT category_name FROM category_name_info)
          INNER JOIN mst_pat_event_data_template AS template ON template.is_del = ''0'' AND template.is_disp=''1'' AND template.template_cd = sub_cat.template_cd
          CROSS JOIN LATERAL jsonb_array_elements(template.input_params ::jsonb) AS info 
      WHERE
          sub_cat.is_del = ''0'' 
          AND sub_cat.is_disp = ''1'' 
          AND sub_cat.facility_cd = @facilityCd 
          AND sub_cat.sub_category_name = (SELECT sub_category_name FROM sub_category_name_info)
          AND info->>''format_class''  = ''1'' -- テンプレートにテキストエリアが有りか
      ORDER BY 
       sub_cat.sub_category_cd ASC LIMIT 1
  ) 
  SELECT
    pat.pat_event_cd
  FROM 
    pat_event AS pat 
    CROSS JOIN LATERAL jsonb_array_elements(pat.result_params ::jsonb) AS result 
    INNER JOIN category_info AS cat ON pat.template_cd = cat.template_cd 
        AND pat.template_cd = cat.template_cd 
        AND pat.category_cd = cat.category_cd 
        AND pat.use_type = cat.use_type 
        AND pat.input_params = cat.input_params 
        AND pat.input_params = cat.input_params 
        AND pat.sub_category_cd = cat.sub_category_cd 
  WHERE 
    pat.is_del = ''0'' 
    AND pat.facility_cd = @facilityCd 
    AND pat.pat_id = @patId 
    AND pat.event_status = ''1'' 
    AND pat.event_start_date = SUBSTR(@regDate, 1, 8)
    AND pat.event_start_time = SUBSTR(@regDate, 9, 4)
    AND result->>''format_class'' = ''1''
    AND result->>''result_value'' = (''【'' || (SELECT taking_title FROM taking_title_info) || ''】'' || @patMemoInfo.content) 
    AND @patMemoInfo.content != ''''
    AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
    AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
)
, bbs_ctl_no_info AS (
  -- この部分SQLは3018のSQLです
  WITH taking_info AS (
    -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
    SELECT
      1 AS order_no
      , ''2'' AS taking
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
      AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
        OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
    UNION 
    SELECT
      2 AS order_no
      , ''0'' AS taking
    ORDER BY
      order_no ASC LIMIT 1
  )
  , taking_title_info AS (
    -- コメントのタイトルを指定※タイトルが未設定の場合、対象の項目属性は取込み対象外とします。
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
        ELSE TRIM(ini_info ->> ''value'') 
        END AS taking_title 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV_TAKING_TITLE'' 
      AND TRIM(ini_info ->> ''key2'') = @patMemoInfo.title 
      AND @patMemoInfo.title != ''''
    UNION 
    SELECT
      2 AS order_no
      , '''' AS taking_title
    ORDER BY
      order_no ASC LIMIT 1
  )
  , bbs_flag_info AS (
    -- 掲示板出力フラグ:0または未設定：出力なし、1：出力あり
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
        ELSE TRIM(ini_info ->> ''value'')
        END AS bbs_flag 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_FLAG'' 
    UNION 
    SELECT
      2 AS order_no
      , ''0'' AS bbs_flag
    ORDER BY
      order_no ASC LIMIT 1
  )
  , bbs_life_list_flg_info AS (
    -- 掲示板_観察記録出力フラグ:0または未設定：出力なし、1：出力あり
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END AS bbs_life_list_flg 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_LIFE_LIST_FLG'' 
    UNION 
    SELECT
      2 AS order_no
      , ''0'' AS bbs_life_list_flg
    ORDER BY
      order_no ASC LIMIT 1
  )
  , bbs_span_info AS (
    -- 掲示板掲載期間:当日からの掲載日数を指定（0または未設定：当日のみ）
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
        ELSE TRIM(ini_info ->> ''value'')
        END AS bbs_span 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_SPAN'' 
    UNION 
    SELECT
      2 AS order_no
      , ''0'' AS bbs_span
    ORDER BY
      order_no ASC LIMIT 1
  )
  , bbs_stuff_info AS (
    -- 掲示板対象スタッフ:掲示板対象スタッフＩＤ（未設定：全スタッフ）カンマ区切りで複数指定可能
    SELECT
      1 AS order_no
      , CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), '''') 
        ELSE TRIM(ini_info ->> ''value'')
        END AS bbs_stuff 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_STUFF'' 
    UNION 
    SELECT
      2 AS order_no
      , '''' AS bbs_stuff
    ORDER BY
      order_no ASC LIMIT 1
  )
  , bbs_category_name_info AS (
    -- 掲示板のカテゴリ名
    SELECT
       CASE TRIM(ini_info ->> ''value'') 
        WHEN '''' THEN TRIM(ini_info ->> ''default_v'')
        ELSE TRIM(ini_info ->> ''value'') 
        END AS bbs_category_name 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND ini.facility_cd = @facilityCd 
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_BBS_CATEGORY_NAME'' 
  )
  , bbs_kind_info AS (
    -- 掲示板のカテゴリを取得する
    SELECT
      kind_no
      , default_title AS title
      , default_contents AS content
      , CASE WHEN T01.bbs_category_name IS NULL THEN 0 ELSE 1 END AS order_no
    FROM
      mst_bbs_kind AS bbs
      LEFT OUTER JOIN (SELECT bbs_category_name FROM bbs_category_name_info) AS T01 ON bbs.kind_name = T01.bbs_category_name AND NULLIF(T01.bbs_category_name, '''') IS NOT NULL
    WHERE 
      bbs.is_del = ''0'' 
      AND bbs.is_disp= ''1'' 
      AND bbs.facility_cd = @facilityCd 
    ORDER BY
      order_no DESC, kind_no ASC LIMIT 1
  )
  , notice_date AS (
    -- 掲載開始日時と掲載終了日時
    SELECT
      SUBSTR(@regDate, 1, 8) AS start_date
      , SUBSTR(TO_CHAR((TO_DATE(@regDate, ''YYYYMMDDHH24MISS'') +  (bbs_span || '' day'')::interval), ''YYYYMMDDHH24MISS''), 1, 8) AS end_date
      , SUBSTR(@regDate, 9, 4) AS start_time
      , COALESCE(NULLIF(SUBSTR(@regDate, 9, 4), ''0000''), ''2359'') AS end_time
    FROM bbs_span_info
  )
  , content_info AS (
    -- 掲載開始日時と掲載終了日時
    SELECT
      (''血液浄化申込情報を受信しました。'' || 
        CASE WHEN (SELECT bbs_life_list_flg FROM bbs_life_list_flg_info) = ''1'' 
        THEN (''\n'' || ''【'' ||  taking_title || ''】'' || @patMemoInfo.content) 
        ELSE ''''
        END) AS content
    FROM taking_title_info
  )
  , new_bbs_info AS (
    -- 新規データ
    SELECT
      (@facilityCd)::TEXT AS facility_cd
      , jsonb_build_object(''target'', ''0'', ''detail'', (''['' || @patId ||'']'')::JSONB) AS pat_info
      , jsonb_build_object(''target'', (''['' || (SELECT COALESCE(NULLIF(bbs_stuff, ''0''), '''') FROM bbs_stuff_info) || '']'')::JSONB, ''read'', ''[]''::JSONB) AS staff_info
      , (''020'')::TEXT AS func_cd
      , kind.kind_no AS kind_no
      , (SELECT content FROM content_info) AS content
      , ''[]''::JSONB AS file_info
      , nd.start_date AS notice_start_date
      , nd.end_date AS notice_end_date
      , -1 AS reg_staff_id
      , null AS reg_staff_name
      , -1 AS upd_staff_id
      , null AS upd_staff_name
      , (''observe-record'')::TEXT AS transition_router_path
      , 1 AS reg_func_class
      , CURRENT_TIMESTAMP AS reg_date
      , CURRENT_TIMESTAMP AS up_date
      , kind.title AS title
      , nd.start_date AS notice_fac_cal_start_date
      , nd.end_date AS notice_fac_cal_end_date
      , ''1''::TEXT AS is_disp_bbs 
      , (''#ffffff'')::TEXT AS color
      , (''<p style="font-size: 14pt; font-family: メイリオ;">'' || (SELECT content FROM content_info) || ''</p>'')::TEXT AS html_content
      , start_time AS notice_fac_cal_start_time
      , end_time AS notice_fac_cal_end_time
      , ''1''::TEXT AS is_time_start_flg
      , ''1''::TEXT AS is_time_end_flg
      , (''#000000'')::TEXT AS font_color
      , ''0''::TEXT AS is_del
      , ''1''::TEXT AS is_disp
    FROM 
      bbs_kind_info AS kind, notice_date AS nd
  )
  SELECT
    bbs.bbs_ctl_no
  FROM 
    bbs_info AS bbs 
    INNER JOIN new_bbs_info AS new ON new.facility_cd = bbs.facility_cd
        AND new.pat_info = bbs.pat_info
        AND new.kind_no = bbs.kind_no
        AND new.content = bbs.content 
        AND new.notice_start_date = bbs.notice_start_date 
        AND new.notice_end_date = bbs.notice_end_date 
        AND new.transition_router_path = bbs.transition_router_path 
        AND new.reg_func_class = bbs.reg_func_class
        AND new.notice_fac_cal_start_date = bbs.notice_fac_cal_start_date 
        AND new.notice_fac_cal_end_date = bbs.notice_fac_cal_end_date 
        AND new.is_disp_bbs = bbs.is_disp_bbs 
  WHERE 
    bbs.is_del = ''0'' 
    AND bbs.is_disp = ''1'' 
    AND bbs.facility_cd = @facilityCd 
    AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
    AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
    AND (SELECT bbs_flag FROM bbs_flag_info) = ''1'' -- 掲示板出力フラグ＝「1：出力あり」
    AND @patMemoInfo.content != ''''
)
SELECT
  event.pat_event_cd
  , bbs.bbs_ctl_no
FROM pat_event_cd_info AS event, bbs_ctl_no_info AS bbs', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→掲示板情報有り場合、掲示板情報と患者イベント情報の取得', '2022-03-10 09:51:01.157', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2101, 'WITH order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''key2'') WHEN ''CODE_BEFORE_DIALYSIS'' THEN ''1'' ELSE ''2'' END reg_order_class
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND (TRIM(ini_info ->> ''key2'') = ''CODE_BEFORE_DIALYSIS'' OR TRIM(ini_info ->> ''key2'') = ''CODE_AFTER_DIALYSIS'')
    AND ( CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN TRIM(ini_info ->> ''default_v'') ELSE TRIM(ini_info ->> ''value'') END) = @regOrderClass
    AND '''' <> @regOrderClass
  UNION
  SELECT
    2 AS order_no
    , ''0'' AS reg_order_class
  ORDER BY order_no ASC LIMIT 1
) 
SELECT
  exam_main_cd
  , pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , TO_CHAR(reg_exam_date, ''YYYYMMDDHH24MISS'') AS reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , TO_CHAR(result_exam_date, ''YYYYMMDDHH24MISS'') AS result_exam_date
  , result_comment
  , exam_result_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
  , is_order
  , exam_week
  , TO_CHAR(exam_from, ''YYYYMMDDHH24MISS'') AS exam_from
  , TO_CHAR(exam_to, ''YYYYMMDDHH24MISS'') AS exam_to
  , exam_pattern
  , ( 
    SELECT (COALESCE(MAX(TO_NUMBER(COALESCE(NULLIF(RESULT ->> ''disp_order'', ''''), ''0''), ''FM99999'')) , 0) + 1) AS next_disp_order 
    FROM
      pat_exam_main exam 
      CROSS JOIN LATERAL json_array_elements(exam.exam_result_info ::json) RESULT 
    WHERE
      exam.exam_main_cd = pat_exam_main.exam_main_cd
  ) AS next_disp_order 
FROM
  pat_exam_main 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = @facilityCd
  AND TO_CHAR(reg_exam_date, ''YYYYMMDDHH24MI'') = SUBSTR(@regExamDate, 1, 12) 
  AND reg_order_class = (SELECT reg_order_class FROM order_class_info)
  AND exam_status = ''1''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2102, 'WITH order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''key2'') WHEN ''CODE_BEFORE_DIALYSIS'' THEN ''1'' ELSE ''2'' END reg_order_class
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd''
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND (TRIM(ini_info ->> ''key2'') = ''CODE_BEFORE_DIALYSIS'' OR TRIM(ini_info ->> ''key2'') = ''CODE_AFTER_DIALYSIS'')
    AND (CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN TRIM(ini_info ->> ''default_v'') ELSE TRIM(ini_info ->> ''value'') END) = ''@regOrderClass''
    AND '''' <> ''@regOrderClass''
  UNION
  SELECT
    2 AS order_no
    , ''0'' AS reg_order_class
  ORDER BY order_no ASC LIMIT 1
) 
INSERT 
INTO pat_exam_main( 
  pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , result_exam_date
  , result_comment
  , exam_result_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
  , is_order
  , exam_week
  , exam_from
  , exam_to
  , exam_pattern
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , CASE ''@ordNo'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@ordNo'', ''FM999999999999999999'') 
    END
  , NULLIF(''@fnPatId'', '''')
  , TO_TIMESTAMP(SUBSTR(''@regExamDate'', 1, 12), ''YYYYMMDDHH24MI'' ) 
  , (SELECT reg_order_class FROM order_class_info)
  , NULLIF(''@examStatus'', '''')
  , NULLIF(''@orderComment'', '''')
  , ''@orderExamSetInfoValue''
  , ''@examOrderInfoValue''
  , ''@orderLabelInfoValue''
  , NULLIF(''@dataGenClass'', '''')
  , TO_TIMESTAMP(SUBSTR(''@resultExamDate'', 1, 12), ''YYYYMMDDHH24MI'') 
  , NULLIF(''@resultComment'', '''')
  , ''@examResultInfoValue''
  , CASE ''@copOrderNo1'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@copOrderNo1'', ''FM999999999999999999'') 
    END
  , CASE ''@copOrderNo2'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@copOrderNo2'', ''FM999999999999999999'') 
    END
  , NULLIF(''@isLock'', '''')
  , CASE ''@indUserId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@indUserId'', ''FM999999999999999999'') 
    END
  , ''0''
  , CURRENT_TIMESTAMP
  , CASE ''@regStaff'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@regStaff'', ''FM999999999999999999'') 
    END
  , CURRENT_TIMESTAMP
  , CASE ''@upStaff'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@upStaff'', ''FM999999999999999999'') 
    END
  , NULLIF(''@isOrder'', '''')
  , CASE ''@examWeek'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@examWeek'', ''FM999999999999999999'') 
    END
  , CASE ''@examFrom'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@examFrom'', ''yyyymmddhh24miss'') 
    END
  , CASE ''@examTo'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@examTo'', ''yyyymmddhh24miss'') 
    END
  , CASE ''@examPattern'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@examPattern'', ''FM999999999999999999'') 
    END
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (2106, 'WITH result_comment1 AS (
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), (''結果コメント１コード[@examResultInfo.resultComment1Code]'')) 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS comment_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAM_COMMENT_CODE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.resultComment1Code'' 
    AND '''' <> ''@examResultInfo.resultComment1Code''
  UNION
  SELECT
    1 AS order_no
    , ''結果コメント１コード[@examResultInfo.resultComment1Code]'' AS comment_text
  WHERE
    '''' <> ''@examResultInfo.resultComment1Code''
  ORDER BY order_no ASC LIMIT 1
) 
, result_comment2 AS ( 
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), (''結果コメント２コード[@examResultInfo.resultComment2Code]'')) 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS comment_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAM_COMMENT_CODE'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.resultComment2Code'' 
    AND '''' <> ''@examResultInfo.resultComment2Code''
  UNION
  SELECT
    1 AS order_no
    , ''結果コメント２コード[@examResultInfo.resultComment2Code]'' AS comment_text
  WHERE
    '''' <> ''@examResultInfo.resultComment2Code''
  ORDER BY order_no ASC LIMIT 1
) 
, examin_get_info AS ( 
  SELECT
    0 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS examin_get_flag 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''EXAMIN_GET_DESTINATION'' 
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS examin_get_flag
  ORDER BY order_no ASC LIMIT 1
) 
, freememo_info_join_0 AS ( 
  SELECT
    0 AS order_no
    , ''@examResultInfo.freememo'' AS freememo_text 
  UNION 
  SELECT
    1 AS order_no
    , (SELECT comment_text FROM result_comment1) AS freememo_text 
  UNION 
  SELECT
    2 AS order_no
    , (SELECT comment_text FROM result_comment2) AS freememo_text 
  ORDER BY
    order_no ASC
) 
, result_freememo_info AS ( 
  -- 0:電文.検査結果
  SELECT
    ''@examResultInfo.result'' AS result
    , (SELECT STRING_AGG(freememo_text, '','') AS freememo FROM freememo_info_join_0 WHERE NULLIF(freememo_text, '''') IS NOT NULL) AS freememo
  WHERE
    (SELECT examin_get_flag FROM examin_get_info) = ''0''
  -- 1:電文.検査結果フリー
  UNION 
  SELECT
    -- Ⅰ)検査結果フリーに値がある場合
    CASE WHEN ''@examResultInfo.freememo'' != '''' 
           THEN ''@examResultInfo.freememo'' 
         -- Ⅱ)検査結果フリーに値がなく、検査結果と結果コメント１コードのいずれにも値がある場合
         WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
           THEN ''@examResultInfo.result'' || (SELECT comment_text FROM result_comment1)
         -- Ⅲ) 検査結果フリーに値がなく、検査結果のみに値がある場合
         WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NULL
           THEN ''@examResultInfo.result''
         -- Ⅳ) 検査結果フリーに値がなく、結果コメント１コードのみに値がある場合
         WHEN ''@examResultInfo.result'' ='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
           THEN ''''
         ELSE ''''
         END AS result
    , CASE WHEN ''@examResultInfo.freememo'' != '''' 
             THEN '''' 
           WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
             THEN '''' 
           WHEN ''@examResultInfo.result'' !='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NULL
             THEN '''' 
           WHEN ''@examResultInfo.result'' ='''' AND NULLIF((SELECT comment_text FROM result_comment1), '''') IS NOT NULL
             THEN (SELECT comment_text FROM result_comment1)
         ELSE ''''
         END AS freememo
  WHERE
    (SELECT examin_get_flag FROM examin_get_info) != ''0''
) 
, mstInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''item_cd'' AS item_cd 
    , ms->>''item_name'' AS item_name 
    , ms->>''type'' AS type 
    , ms->>''unit'' AS unit 
    , ms->>''exam_class'' AS exam_class 
    , ms->>''normal_value_upper'' AS upper 
    , ms->>''normal_value_lower'' AS lower 
    , ms->>''com_cd'' AS com_cd 
    , ms->>''disp_order'' AS disp_order 
    , NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF((SELECT result FROM result_freememo_info), '''') AS result
    , NULLIF((SELECT freememo FROM result_freememo_info), '''') AS freememo
    , TO_CHAR(TO_TIMESTAMP(NULLIF(''@examResultInfo.resultDate'', ''''), ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS result_date
  FROM
    pat_exam_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.exam_result_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND exam_main_cd = @examMainCd 
    AND ms->>''item_cd'' :: TEXT = ''@examResultInfo.itemCd''
  UNION
  SELECT
    2 AS order_no
    , NULL AS idx
    , (A.exam_item_cd :: TEXT) AS item_cd
    , A.exam_item_name AS item_name
    , A.data_type AS type
    , A.unit
    , A.exam_class
    , A.input_upper AS upper
    , A.input_lower AS lower
    , null AS com_cd
    , NULLIF(''@nextDispOrder'', '''') AS disp_order
    , NULLIF(''@examResultInfo.hl'', '''') AS hl
    , NULLIF((SELECT result FROM result_freememo_info), '''') AS result
    , NULLIF((SELECT freememo FROM result_freememo_info), '''') AS freememo
    , TO_CHAR(TO_TIMESTAMP(NULLIF(''@examResultInfo.resultDate'', ''''), ''YYYYMMDDHH24MISS''), ''YYYY/MM/DD HH24:MI:SS'') AS result_date
  FROM
    mst_exam_item A
  WHERE
    A.exam_item_cd = TO_NUMBER(''@examResultInfo.itemCd'', ''FM999999999999999999'')
  ORDER BY order_no ASC LIMIT 1
) 
, do_middle_check_data AS (
    SELECT COUNT(*) AS resultDeleteFalg
    FROM (
        SELECT result, NULLIF(com_cd, '''') AS com_cd, freememo
        FROM mstInfo
        WHERE result <> '''' OR NULLIF(com_cd, '''') <> '''' OR freememo <> '''') AS middleData 
)
UPDATE pat_exam_main 
SET exam_result_info = jsonb_set(
  COALESCE(exam_result_info, ''[]'') :: JSONB,
  CAST((SELECT ''{'' || COALESCE(idx, 999) || ''}'' FROM mstInfo ) AS TEXT []),
  (SELECT jsonb_build_object(''item_cd'', TO_NUMBER(item_cd, ''FM999999999999999999'')
          , ''item_name'' , NULLIF(item_name, '''')
          , ''type'' , TO_NUMBER(NULLIF(type, ''''), ''FM999999999999999999'') 
          , ''unit'' , NULLIF(unit, '''')
          , ''exam_class'' , NULLIF(exam_class, '''')
          , ''upper'' , TO_NUMBER(NULLIF(upper, ''''), ''FM999999999999999999'')
          , ''lower'' , TO_NUMBER(NULLIF(lower, ''''), ''FM999999999999999999'')
          , ''com_cd'' , NULLIF(com_cd, '''')
          , ''disp_order'' , TO_NUMBER(NULLIF(disp_order, ''''), ''FM999999999999999999'') 
          , ''hl'' , NULLIF(hl, '''')
          , ''result'' , mstInfo.result
          , ''freememo'' , NULLIF(freememo, '''')
          , ''result_date'' , NULLIF(result_date, '''')) FROM mstInfo) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の検査結果', '2022-08-15 11:33:51.609', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-63, 'WITH pdf_path_info AS (
SELECT
				0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS pdf_file_path
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''REPORT_SEND'' 
        AND info ->> ''key2'' = ''URL_PREFIX'' 
)
,data_info AS (
  SELECT
    TO_CHAR((CASE WHEN ord.rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END), ''FM0999999999999999999'') AS ord_no
    , ord.rst_edition
    , coop.hosp_pat_id
  FROM
    ord_main AS ord, sys_coop_journal AS coop
  WHERE
    ord.ord_no = @ordNo
  AND coop.ctl_no = @ctlNo
  AND coop.ord_no = ord.ord_no
)
, hosp_pat_id_length AS (
	SELECT
	COALESCE(NULLIF(((distribute_setting -> ''protocolInfo'' ->> ''hospPatIdLen'') :: INTEGER), NULL), 0) AS len
	FROM
	mst_coop_distribute
	WHERE
		facility_cd = @facilityCd 
		AND is_del = ''0'' 
		AND coop_cd = ''rep_dial''
		AND coop_cd_index = ''pdf''
		AND direction = ''S''
	ORDER BY len DESC
	LIMIT 1
)
SELECT
  pdf_path_info.pdf_file_path|| LPAD(LTRIM(data_info.hosp_pat_id) , len, ''0'') 
	|| ''/''
  || LTRIM(data_info.hosp_pat_id)
  || (CASE WHEN CHAR_LENGTH(ord_no::TEXT) > 12 THEN RIGHT(ord_no::TEXT,12) ELSE RPAD(ord_no::TEXT, 12, ''0'') END)
  || LPAD(rst_edition::TEXT, 4, ''0'') 
  || ''.pdf'' AS filename
FROM data_info,pdf_path_info,hosp_pat_id_length
WHERE pdf_path_info.order_no = 0', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）PDFファイルパスの取得', '2022-04-04 16:37:06.279', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3202, 'WITH exam_date_tmp AS ( 
  SELECT
    ''@examDate_GMTDate''::TEXT AS exam_date
) 
, exam_date_info AS ( 
  SELECT
    CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD'') ELSE exam_date END AS exam_date
    , CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') ELSE REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS inspect_date
    , CASE WHEN NULLIF(exam_date, '''') IS NULL THEN TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') ELSE REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS indicator_start_date
  FROM
    exam_date_tmp
) 
, order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_CLASS'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS order_class 
  ORDER BY
    order_no ASC LIMIT 1
) 
, indicator_info AS ( 
  SELECT
   ''@staffCd''::TEXT AS indicator_cd
) 
, data_new_info AS (
  SELECT 
    TRIM(NULLIF(''@physicalInfo.dw'', ''''), ''0'') AS dw,
    NULL AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    NULL AS height,
    NULL AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    NULL AS breast_dia,
    NULL AS ctr_weight,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    COALESCE(NULLIF((SELECT order_class FROM order_class_info), ''0''), ''3'') AS order_class,
    (SELECT indicator_cd FROM indicator_info) AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date,
    ''-1'' AS target_weight
)
, data_exam_date AS (
	SELECT COALESCE
		( NULLIF ( info ->> ''dw'', '''' ) ) AS dw 
	FROM
		pat_unique AS pu
		CROSS JOIN LATERAL json_array_elements ( pu.physical_info :: json ) info 
	WHERE
		pat_id = @patId 
		AND facility_cd = ''@facilityCd'' 
		AND is_del = ''0'' 
	ORDER BY
		info ->> ''exam_date'' DESC 
		LIMIT 1 
)
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    pat_unique patu 
    , data_exam_date AS OLD 
    , data_new_info AS NEW 
  WHERE
    patu.pat_id = @patId 
    AND patu.facility_cd = ''@facilityCd'' 
    AND patu.is_del = ''0'' 
    AND TO_NUMBER(OLD.dw::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.dw ::TEXT, ''FM9999.99'')
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no
    , dw ::TEXT AS dw
    , ctr ::TEXT AS ctr
    , memo ::TEXT AS memo
    , ctl_no ::TEXT AS ctl_no
    , height ::TEXT AS height
    , chest_dia ::TEXT AS chest_dia
    , exam_date ::TEXT AS exam_date
    , breast_dia ::TEXT AS breast_dia
    , ctr_weight ::TEXT AS ctr_weight
    , facility_cd ::TEXT AS facility_cd
    , order_class ::TEXT AS order_class
    , indicator_cd ::TEXT AS indicator_cd
    , inspect_date ::TEXT AS inspect_date
    , pre_scale_lower ::TEXT AS pre_scale_lower
    , pre_scale_upper ::TEXT AS pre_scale_upper
    , indicator_start_date ::TEXT AS indicator_start_date 
    , target_weight ::TEXT AS target_weight 
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , info ->> ''dw'' AS dw
    , info ->> ''ctr'' AS ctr
    , info ->> ''memo'' AS memo
    , info ->> ''ctl_no'' AS ctl_no
    , info ->> ''height'' AS height
    , info ->> ''chest_dia'' AS chest_dia
    , info ->> ''exam_date'' AS exam_date
    , info ->> ''breast_dia'' AS breast_dia
    , info ->> ''ctr_weight'' AS ctr_weight
    , info ->> ''facility_cd'' AS facility_cd
    , info ->> ''order_class'' AS order_class
    , info ->> ''indicator_cd'' AS indicator_cd
    , info ->> ''inspect_date'' AS inspect_date
    , info ->> ''pre_scale_lower'' AS pre_scale_lower
    , info ->> ''pre_scale_upper'' AS pre_scale_upper
    , info ->> ''indicator_start_date'' AS indicator_start_date 
    , info ->> ''target_weight'' AS target_weight 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS info 
  WHERE
    pat_id = @patId  
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
  ORDER BY order_no DESC, ctl_no ASC)
, json_data AS (
  SELECT json_build_object(''dw'', TO_NUMBER(dw , ''FM9999.99''),
    ''ctr'', TO_NUMBER(ctr, ''FM9999.99''),
    ''memo'', memo,
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''height'', TO_NUMBER(height, ''FM9999.99''),
    ''chest_dia'', TO_NUMBER(chest_dia, ''FM9999.99''),
    ''exam_date'', exam_date,
    ''breast_dia'', TO_NUMBER(breast_dia, ''FM9999.99''),
    ''ctr_weight'', TO_NUMBER(ctr_weight, ''FM9999.99''),
    ''facility_cd'', facility_cd,
    ''order_class'', (order_class :: INTEGER),
    ''indicator_cd'', NULLIF(indicator_cd, ''''),
    ''inspect_date'', inspect_date,
    ''target_weight'', TO_NUMBER(target_weight, ''FM9999.99''),
    ''pre_scale_lower'', TO_NUMBER(pre_scale_lower, ''FM9999.99''),
    ''pre_scale_upper'', TO_NUMBER(pre_scale_upper, ''FM9999.99''),
    ''indicator_start_date'', indicator_start_date) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  physical_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→身体情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-44, 'WITH default_user_no AS (
    -- デフォルト利用者番号（検査オーダ用）
    SELECT 0                                                            AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO''
    UNION
    SELECT 1  AS order_no
         , '''' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1)
   , user_no_setting AS (
    -- 利用者番号出力設定（検査オーダ用）
    SELECT 0                                                                                       AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
    UNION
    SELECT 1   AS order_no
         , ''0'' AS setting
    ORDER BY order_no ASC
    LIMIT 1)
   , ind_user_info AS (
    -- 指示者
    SELECT TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
    FROM pat_exam_main_hst pem
    WHERE pem.exam_main_cd = @ordNo
      AND pem.ind_user_id IS NOT NULL)
   , staff_user_info AS (
    -- 担当者
    SELECT ROW_NUMBER() OVER () AS CNT
         , staff ->> ''staff_cd'' AS staff_cd
    FROM pat_main pm
             CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff
    WHERE pm.is_del = ''0''
      AND pm.pat_id = @patId
      AND staff ->> ''is_main'' = ''1'')
   , up_user_info AS (
    -- 操作者
    SELECT TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
    FROM pat_exam_main_hst pem
    WHERE pem.exam_main_cd = @ordNo
      AND pem.up_staff IS NOT NULL),
reg_order_class as (
select reg_order_class from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1
),
kur_qt as(
select (staff.value ->''set_cd'')::text as exam_set_cd from pat_exam_main_hst as pat CROSS JOIN LATERAL json_array_elements(pat.order_exam_set_info ::json) staff where pat.exam_main_cd = @ordNo order by up_date desc limit 1
),
kur_time as (
select kur_cd,kur_start_time:: time as time1,kur_end_time::time as time2 from mst_kur where facility_cd = @facilityCd and is_del = ''0''
),
ind_kur_cd3 as (
select kur_cd ::text as ind_kur_cd from kur_time where time1 <= (select other_exam_time::time as  mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd ) and time2 >= (select other_exam_time::time as mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd)

),
	ind_kur_cd1 as (
	
	 select ind_kur_cd,facility_cd from ord_main where pat_id = (select pat_id from pat_exam_main_hst where exam_main_cd = @ordNo
 order by up_date desc limit 1)
 and     date_part(''YEAR'',cast(treat_date as date))= (select date_part(''YEAR'',reg_exam_date)  from pat_exam_main_hst where exam_main_cd = @ordNo
 order by up_date desc limit 1) 
 and     date_part(''month'',cast(treat_date as date))= (select date_part(''month'',reg_exam_date) from pat_exam_main_hst where exam_main_cd = @ordNo
 order by up_date desc limit 1) 
 and     date_part(''day'',cast(treat_date as date))= (select date_part(''day'',reg_exam_date) from pat_exam_main_hst where exam_main_cd = @ordNo
 order by up_date desc limit 1) 

),
	ind_kur_cd as (
	 select kur_cd as ind_kur_cd from mst_kur,ind_kur_cd1 where mst_kur.kur_cd = ind_kur_cd1.ind_kur_cd and mst_kur.facility_cd = ind_kur_cd1.facility_cd
	 and is_del = ''0'' order by kur_end_time  limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1
),
mst_user_authenticator1 as (
select
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend)		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend)		
then ''Satur'' 
 when 7 =(select reg_exam_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd::text = (select ind_kur_cd from ind_kur_cd3)
and facility_cd = @facilityCd
),
mst_user_authenticator as(
select 2 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>
(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend )		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend )		
then ''Satur'' 
 when 0 =(select reg_exam_date from weekend )		
then ''Sun'' 
END ) as aaa)
)::json->>''user_id'' as staff_cd from mst_kur mst where
facility_cd = @facilityCd
and kur_name = ''午前''
and (select ind_kur_cd from ind_kur_cd ) is null
union 
select 1 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend)		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend)		
then ''Satur'' 
 when 7 =(select reg_exam_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
 UNION
         SELECT 3        AS no,
                       staff_cd 
         from default_user_no
         order by no
         limit 1
),
mst_user_authenticator2 as (
select 
case when (select reg_order_class from reg_order_class) = ''0''
then (select staff_cd from mst_user_authenticator1)
else
(select staff_cd from mst_user_authenticator) end as staff_cd
)
SELECT NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_comm
     , NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_data
     , (SELECT staff_cd FROM default_user_no)                           AS default_user_no
FROM (SELECT ''comm'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''0''
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''1''
        AND CNT = 1
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''2''
        AND CNT = 2
      UNION
      SELECT ''comm'' AS part, staff_cd FROM up_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''3'', ''4'', ''5'')
			UNION
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator2 WHERE (SELECT setting FROM user_no_setting) =''6''
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) in (''0'', ''3'')
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'')
        AND CNT = 1
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'')
        AND CNT = 2
			UNION
      SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator2 
		  WHERE (SELECT setting FROM user_no_setting) =''6''	
				) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼者 ★削除用', '2022-01-17 15:02:47', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-26, 'WITH default_user_no AS (
  -- デフォルト利用者番号（検査オーダ用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''FJI_COM_INFO''
    AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO''
  UNION
  SELECT
    1 AS order_no
    , '''' AS staff_cd
  ORDER BY order_no ASC LIMIT 1
)
, user_no_setting AS (
  -- 利用者番号出力設定（検査オーダ用）
 SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''FJI_COM_INFO''
    AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS setting
  ORDER BY order_no ASC LIMIT 1
)
, ind_user_info AS(
  -- 指示者
  SELECT
    TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
  FROM
    pat_exam_main pem
  WHERE
    pem.exam_main_cd = @ordNo
    AND pem.ind_user_id IS NOT NULL
)
, staff_user_info AS(
  -- 担当者
  SELECT
    ROW_NUMBER() OVER () AS CNT
    , staff ->> ''staff_cd'' AS staff_cd
  FROM
    pat_main pm
    CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff
  WHERE
    pm.is_del = ''0''
    AND pm.pat_id = @patId
    AND staff ->> ''is_main'' = ''1''
)
, up_user_info AS(
  -- 操作者
  SELECT
    TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
  FROM
    pat_exam_main pem
  WHERE
    pem.exam_main_cd = @ordNo
    AND pem.up_staff IS NOT NULL
),
reg_order_class as (
select reg_order_class from pat_exam_main where exam_main_cd = @ordNo
),
kur_qt as(
select (staff.value ->''set_cd'')::text as exam_set_cd from pat_exam_main as pat CROSS JOIN LATERAL json_array_elements(pat.order_exam_set_info ::json) staff where pat.exam_main_cd = @ordNo 
),
kur_time as (
select kur_cd,LEFT(kur_start_time,4)as time1,LEFT(kur_end_time,4) as time2 from mst_kur where facility_cd = @facilityCd and is_del = ''0''
),
ind_kur_cd3 as (
select kur_cd ::text as ind_kur_cd from kur_time where time1 <= (select other_exam_time mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd ) and time2 > (select other_exam_time mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd)
),
ind_kur_cd1 as (
 select ind_kur_cd,facility_cd from ord_main where pat_id = (select pat_id from pat_exam_main where exam_main_cd = @ordNo)
 and     date_part(''YEAR'',cast(treat_date as date))= (select date_part(''YEAR'',reg_exam_date) from pat_exam_main where exam_main_cd = @ordNo) 
 and     date_part(''month'',cast(treat_date as date))= (select date_part(''month'',reg_exam_date) from pat_exam_main where exam_main_cd = @ordNo) 
 and     date_part(''day'',cast(treat_date as date))= (select date_part(''day'',reg_exam_date) from pat_exam_main where exam_main_cd = @ordNo) 
),
	ind_kur_cd as (
	 select kur_cd as ind_kur_cd from mst_kur,ind_kur_cd1 where mst_kur.kur_cd = ind_kur_cd1.ind_kur_cd and mst_kur.facility_cd = ind_kur_cd1.facility_cd
	 and is_del = ''0'' order by kur_end_time  limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_main where exam_main_cd = @ordNo
),
mst_user_authenticator1 as (
select
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend)		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend)		
then ''Satur'' 
 when 7 =(select reg_exam_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd::text = (select ind_kur_cd from ind_kur_cd3)
and facility_cd = @facilityCd

),
mst_user_authenticator as(
select 2 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>
(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend )		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend )		
then ''Satur'' 
 when 0 =(select reg_exam_date from weekend )		
then ''Sun'' 
END ) as aaa)
)::json->>''user_id'' as staff_cd from mst_kur mst where
facility_cd = @facilityCd
and kur_name = ''午前''
and (select ind_kur_cd from ind_kur_cd ) is null
union 
select 1 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend)		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend)		
then ''Satur'' 
 when 7 =(select reg_exam_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
 UNION
         SELECT 3        AS no,
                       staff_cd 
         from default_user_no
         order by no
         limit 1
),
mst_user_authenticator2 as (
select 
case when (select reg_order_class from reg_order_class) = ''0''
then (select staff_cd from mst_user_authenticator1)
else
(select staff_cd from mst_user_authenticator) end as staff_cd
)

SELECT
   NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''') AS  staff_cd_comm
  ,NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''')  AS staff_cd_data
 ,(SELECT staff_cd  FROM default_user_no) AS default_user_no
FROM
  (

  -- 3：共通部 操作者
  -- 4：共通部 操作者
  -- 5：共通部 操作者
    SELECT ''comm'' AS part, staff_cd FROM up_user_info WHERE (SELECT setting FROM user_no_setting) IN (''3'',''4'',''5'')
    -- 0：共通部 指示者
    UNION
  SELECT ''comm'' AS part, staff_cd FROM ind_user_info WHERE (SELECT setting FROM user_no_setting) IN (''0'')
    -- 1：共通部 担当医１
    UNION
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) = ''1'' AND CNT = 1
    -- 2：共通部 担当医２
    UNION
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) =''2'' AND CNT = 2
		UNION
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator2 WHERE (SELECT setting FROM user_no_setting) =''6''
    -- 0：内容部 指示者
  -- 3：内容部 指示者
  UNION
  SELECT ''data'' AS part, staff_cd FROM ind_user_info WHERE (SELECT setting FROM user_no_setting)  in (''0'',''3'')
    -- 1：内容部 担当医１
    -- 4：内容部 担当医１
    UNION
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'') AND CNT = 1
    -- 2：内容部 担当医２
    -- 5：内容部 担当医２
    UNION
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'') AND CNT = 2
			UNION
    SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator2 WHERE (SELECT setting FROM user_no_setting) =''6''
  ) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼者', '2020-05-12 12:15:09.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-8, 'WITH default_user_no AS (
  -- デフォルト利用者番号（透析予約用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''SCH_DEFAULT_USER_NO''
  UNION
  SELECT
    1 AS order_no
    , '''' AS staff_cd
  ORDER BY order_no ASC LIMIT 1
)
, user_no_setting AS (
  -- 利用者番号出力設定（透析予約用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''SCH_USER_NO_SETTING''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS setting
  ORDER BY order_no ASC LIMIT 1
)
, ind_upd_user_info AS(
  -- 指示者
  -- 操作者
  SELECT
    0 AS order_no
    , om.ind_schedule_user_info ->> ''ind_user_id'' AS ind_staff_cd 
    , om.ind_schedule_user_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
  WHERE
    om.ord_no = @ordNo 
    AND om.facility_cd = @facilityCd 
    AND om.is_del = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , ind_cond_info ->> ''ind_user_id'' AS ind_staff_cd 
    , ind_cond_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    (SELECT
       om.ind_cond_info -> jsonb_object_keys(om.ind_cond_info) AS ind_cond_info 
     FROM
       ord_main AS om 
     WHERE
       om.ord_no = @ordNo 
     AND om.facility_cd = @facilityCd 
     AND om.is_del = ''0'' 
     LIMIT 1 ) AS T
  UNION 
  SELECT
    2 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_medi_info ::json) info 
  WHERE
    om.ord_no = @ordNo 
  AND om.facility_cd = @facilityCd 
  AND om.is_del = ''0'' 
  UNION
  SELECT
    3 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) info 
  WHERE
    om.ord_no = @ordNo 
  AND om.facility_cd = @facilityCd 
  AND om.is_del = ''0'' 
  UNION
  SELECT
    4 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    ord_main AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_ind_comment_info ::json) info 
  WHERE
    om.ord_no = @ordNo 
    AND om.facility_cd = @facilityCd 
    AND om.is_del = ''0'' 
  ORDER BY order_no ASC LIMIT 1
)
, staff_user_info AS(
  -- 担当者
  SELECT
    ROW_NUMBER() OVER (ORDER BY staff ->> ''is_main'' DESC, staff ->> ''is_charge'' DESC, staff ->> ''is_puncture'' DESC, staff ->> ''ctl_no'' ASC) AS CNT
    , staff ->> ''staff_cd'' AS staff_cd 
  FROM
    pat_main pm 
    CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
  WHERE
    pm.is_del = ''0'' 
    AND pm.pat_id = @patId 
    AND staff ->> ''is_main'' = ''1'' 
),
 mst_user_authenticator as (--常勤医
         select 
                (json_array_elements((mst.mst_user_authentication ->> ''data'')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Mon''
                                 when 2 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Tues''
                                 when 3 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Wednes''
                                 when 4 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Thurs''
                                 when 5 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Fri''
                                 when 6 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Satur''
                                 when 7 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Sun''
                                 END) as aaa))::json ->> ''user_id'' as staff_cd
         from ord_main ord,
              mst_kur mst
         where ord.ind_kur_cd = mst.kur_cd
           and ord.ord_no = @ordNo)	 
SELECT
  COALESCE(NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), ''''),'''') staff_cd_comm
  , COALESCE(NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), ''''), '''') staff_cd_data, 
  (SELECT staff_cd  AS default_staff_cd FROM default_user_no)
FROM
  ( 
    -- 0：共通部 指示者
    SELECT ''comm'' AS part, ind_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) = ''0''
    -- 1：共通部 担当医１
    -- 4：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'') AND CNT = 1
    -- 2：共通部 担当医２
    -- 5：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'') AND CNT = 2
    -- 3：共通部 操作者
    UNION 
    SELECT ''comm'' AS part, upd_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) IN (''3'',''4'', ''5'')
   UNION 
    SELECT ''comm'' AS part,  staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) = ''6''
    -- 0：内容部 指示者
    -- 3：内容部 指示者
    UNION 
    SELECT ''data'' AS part, ind_staff_cd AS staff_cd FROM ind_upd_user_info WHERE (SELECT setting FROM user_no_setting) IN (''0'', ''3'')
    -- 1：内容部 担当医１
    -- 4：内容部 担当医１
    UNION 
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'') AND CNT = 1
    -- 2：内容部 担当医２
    -- 5：内容部 担当医２
    UNION 
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'') AND CNT = 2
		   UNION 
    SELECT ''data'' AS part,  staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) = ''6''
  ) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：共通部と伝票情報の利用者番号取得', '2022-02-28 14:34:34.866', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3104, 'WITH taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録memo
 select case when staff_cd like ''%1%'' then ''1'' else ''0'' end  as taking from (
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd''
    AND info ->> ''key1'' = ''ORDER_RECV''
    AND info ->> ''key2'' = ''ORDER_RECV_TAKING'')   as taking_info 
),
memo_title AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録memo
SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS memo_title
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd = ''@facilityCd''
	AND is_del = ''0''
	-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
	AND COALESCE(info->>''key0'','''') = @key0
	-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
	AND info ->> ''key1'' = ''ORDER_RECV''
	AND info ->> ''key2'' = ''ORDER_RECV_MEMO_TITLE''
)
, memo_id_info AS (
  -- 患者メモの番号:患者メモの番号(1~20を設定する、初期値は1)
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS memo_id 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_MEMO_ID'' 
  UNION 
  SELECT
    2 AS order_no
    , ''20'' AS memo_id
  ORDER BY
    order_no ASC LIMIT 1
)
, mstInitInfo AS ( 
  SELECT
    1 AS order_no
    , (idx - 1) AS idx
    , ms->>''ctl_no'' AS ctl_no 
    , ms->>''title'' AS title 
    , ms->>''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms->>''ctl_no''::TEXT) = (SELECT memo_id FROM memo_id_info) -- 患者メモの番号が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
--     AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  UNION 
  SELECT
    2 AS order_no
    , (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no 
    , ms ->> ''title'' AS title 
    , ms ->> ''content'' AS content 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.pat_memo_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND (ms->>''ctl_no''::TEXT) = ''1'' -- 患者メモの番号[1]が有り
    AND (SELECT taking FROM taking_info) = ''1'' -- 取込先指定＝「1：患者メモ」
--     AND (SELECT taking_title FROM taking_title_info) != '''' -- コメントのタイトルを指定済み
  ORDER BY order_no ASC LIMIT 1
),
-- memo_info AS (
-- select
-- case when 
-- (memo_info ->> ''title'') = (select taking_title from taking_title_info)
-- then (memo_info ->> ''content'')::text
-- else '''' end as memo
-- from pat_main  pm
--  CROSS JOIN LATERAL json_array_elements(pm.pat_memo_info ::json) AS memo_info 
-- where 
--      pat_id = @patId
-- AND  facility_cd = ''@facilityCd''
-- AND  memo_info ->> ''ctl_no'' = (SELECT memo_id FROM memo_id_info)
-- AND  is_del = ''0'' 
-- )
 mstInfo AS (
  SELECT
		idx,
	 ctl_no,
    (select memo_title from memo_title)::text AS title ,
		REPLACE(''@patMemoInfo.content'','' 【'',''\n【'')
     AS content
		 from mstInitInfo
)
UPDATE pat_main 
SET pat_memo_info = jsonb_set (
  COALESCE ( pat_memo_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' || idx || ''}'' FROM mstInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"ctl_no":'' || ctl_no || '', "title":"'' || title || ''", "content":"'' || content || ''"}'' FROM mstInfo ) AS JSONB ) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND (SELECT content FROM mstInfo) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→患者メモ', '2022-03-14 14:46:10.256', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3203, 'WITH up_base_disease_flg_info AS (
  -- 原疾患が存在しない場合の更新有無(0：更新する(デフォルト)、 1：更新しない)
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS up_base_disease_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''UP_BASE_DISEASE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS up_base_disease_flg
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS (
  SELECT
    info ->> ''memo'' AS memo, 
    info ->> ''ctl_no'' AS ctl_no, 
    info ->> ''die_date'' AS die_date, 
    info ->> ''out_come'' AS out_come, 
    info ->> ''course_cd'' AS course_cd, 
    info ->> ''is_notice'' AS is_notice, 
    info ->> ''disease_cd'' AS disease_cd, 
    info ->> ''disp_order'' AS disp_order, 
    info ->> ''disease_day'' AS disease_day, 
    info ->> ''facility_cd'' AS facility_cd, 
    info ->> ''disease_date'' AS disease_date, 
    info ->> ''disease_year'' AS disease_year, 
    info ->> ''is_diagnosed'' AS is_diagnosed, 
    info ->> ''diagnosis_day'' AS diagnosis_day, 
    info ->> ''disease_month'' AS disease_month, 
    info ->> ''out_come_date'' AS out_come_date, 
    info ->> ''course_is_free'' AS course_is_free, 
    info ->> ''diagnosis_date'' AS diagnosis_date, 
    info ->> ''diagnosis_year'' AS diagnosis_year, 
    info ->> ''diagnosis_month'' AS diagnosis_month, 
    info ->> ''is_main_disease'' AS is_main_disease, 
    info ->> ''diagnostician_cd'' AS diagnostician_cd, 
    info ->> ''diagnosis_facility_cd'' AS diagnosis_facility_cd, 
    info ->> ''diagnostician_is_free'' AS diagnostician_is_free, 
    info ->> ''is_confirmation_biopsy'' AS is_confirmation_biopsy, 
    info ->> ''diagnosis_facility_is_free'' AS diagnosis_facility_is_free, 
    CASE WHEN (SELECT up_base_disease_flg FROM up_base_disease_flg_info) = ''0''
      THEN ''0''
      ELSE info ->> ''is_dialysis_underlying_disease''
      END AS is_dialysis_underlying_disease
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.medical_hst_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    ctl_no ASC
)
, json_data AS (
  SELECT json_build_object(
    ''memo'', memo, 
    ''ctl_no'', (ctl_no :: INTEGER), 
    ''die_date'', die_date, 
    ''out_come'', out_come, 
    ''course_cd'', (course_cd :: INTEGER), 
    ''is_notice'', is_notice, 
    ''disease_cd'', (disease_cd :: INTEGER), 
    ''disp_order'', (disp_order :: INTEGER), 
    ''disease_day'', disease_day, 
    ''facility_cd'', facility_cd, 
    ''disease_date'', disease_date, 
    ''disease_year'', disease_year, 
    ''is_diagnosed'', is_diagnosed, 
    ''diagnosis_day'', diagnosis_day, 
    ''disease_month'', disease_month, 
    ''out_come_date'', out_come_date, 
    ''course_is_free'', course_is_free, 
    ''diagnosis_date'', diagnosis_date, 
    ''diagnosis_year'', diagnosis_year, 
    ''diagnosis_month'', diagnosis_month, 
    ''is_main_disease'', is_main_disease, 
    ''diagnostician_cd'', (diagnostician_cd :: INTEGER), 
    ''diagnosis_facility_cd'', diagnosis_facility_cd, 
    ''diagnostician_is_free'', diagnostician_is_free, 
    ''is_confirmation_biopsy'', is_confirmation_biopsy, 
    ''diagnosis_facility_is_free'', diagnosis_facility_is_free, 
    ''is_dialysis_underlying_disease'', is_dialysis_underlying_disease) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  medical_hst_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→既往歴情報(透析導入原疾患として扱う→チェック オフ)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3105, 'WITH sub_category_name_info AS (
  -- 観察記録のサブカテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS sub_category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_SUB_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS sub_category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, category_name_info AS (
  -- 観察記録カテゴリ名
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''観察記録'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS category_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end 
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_CATEGORY_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , ''観察記録'' AS category_name
  ORDER BY
    order_no ASC LIMIT 1
)
, taking_info AS (
  -- 取込先指定:カンマ区切りで複数指定が可能。0または未設定：取込みなし、1：患者メモ、2：観察記録
  SELECT
    1 AS order_no
    , ''2'' AS taking
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND ini.facility_cd = @facilityCd 
    AND TRIM(ini_info->>''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info->>''key2'') = ''ORDER_RECV_TAKING'' 
    AND ((TRIM(ini_info->>''value'') !='''' AND TRIM(ini_info->>''value'') like ''%2%'') 
      OR ((ini_info->>''value'') = '''' AND TRIM(ini_info->>''default_v'') like ''%2%'')) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS taking
  ORDER BY
    order_no ASC LIMIT 1
)
-- 取込先指定＝「2：観察記録」の場合、観察記録のテンプレートを取得する
SELECT
  template.template_cd
  , template.template_name
  , cat.category_cd
  , cat.category_name
  , sub_cat.use_type
  , template.input_params
  , sub_cat.sub_category_cd
  , sub_cat.sub_category_name
FROM
  mst_pat_event_sub_category AS sub_cat
  INNER JOIN mst_pat_event_category AS cat ON cat.is_del = ''0'' AND cat.is_disp=''1'' AND cat.category_cd=sub_cat.category_cd AND category_name = (SELECT category_name FROM category_name_info)
  INNER JOIN mst_pat_event_data_template AS template ON template.is_del = ''0'' AND template.is_disp=''1'' AND template.template_cd = sub_cat.template_cd
  CROSS JOIN LATERAL jsonb_array_elements(template.input_params ::jsonb) AS info 
WHERE
  sub_cat.is_del = ''0'' 
  AND sub_cat.is_disp = ''1'' 
  AND sub_cat.facility_cd = @facilityCd 
  AND sub_cat.sub_category_name = (SELECT sub_category_name FROM sub_category_name_info)
  AND info->>''format_class''  = ''1'' -- テンプレートにテキストエリアが有りか
  AND (SELECT taking FROM taking_info) = ''2'' -- 取込先指定＝「2：観察記録」
-- nullデータ(チェック用)
UNION
SELECT
  null AS template_cd
  , null AS template_name
  , null AS category_cd
  , null AS category_name
  , null AS use_type
  , null AS input_params
  , null AS sub_category_cd
  , null AS sub_category_name
ORDER BY 
 sub_category_cd ASC NULLS LAST LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の初回申し込み→依頼事項登録→観察記録の連携設定を取得する', '2022-03-14 14:46:10.256', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-511, 'with coop_ini as (SELECT COALESCE
                             (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
                  FROM mst_coop_ini AS ini
                           CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                  WHERE facility_cd = @facilityCd
                    AND is_del = ''0''
                    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
                    AND COALESCE(info->>''key0'','''') = @key0
                    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
                    AND info ->> ''key1'' = ''DIALYSISSEND''
                    AND info ->> ''key2'' = ''HEADER_MODE''
),
     journal as (
         SELECT coop_ord_no
         from sys_coop_journal
         WHERE facility_cd = @facilityCd
           AND ord_no = @ordNo
           AND coop_cd = ''rst_dial''
           AND coop_ord_no IS NOT NULL
         union
         select ''0'' as coop_ord_no
         order by coop_ord_no DESC
         LIMIT 1 )
select case
           when journal.coop_ord_no = ''0'' then ''            ''
           else
               (case
                   when coop_ini.header_mode = ''1''
                       then journal.coop_ord_no
                   else ''            ''
                   end)
           end coop_ord_no
FROM coop_ini,
     journal
', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：透析番号取得（削除）', '2022-09-05 08:14:41.911', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (3102, 'WITH take_cource_info AS (SELECT 1       AS order_no,
                                 CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
                                     ELSE TRIM(ini_info ->> ''value'')
                                     END AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
                            AND ini.facility_cd = ''@facilityCd''
                            AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV''
                            AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_DOCTOR_SETTING''
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     witch_ctl_no as (select (case take_cource_flg
                                  when ''0'' then (select (case
                                                             when position(''1'' in t.ctl_no_str) > 0 and position(''2'' in t.ctl_no_str) = 0
                                                                 then ''2''
                                                             when position(''1'' in t.ctl_no_str) = 0 and position(''2'' in t.ctl_no_str) > 0
                                                                 then ''1''
                                                             when position(''1'' in t.ctl_no_str) = 0 and position(''2'' in t.ctl_no_str) = 0
                                                                 then ''1''
                                                             else '''' end)
                                                 from (select coalesce(nullif(string_agg(staff_info ->> ''ctl_no'', '',''), ''''), '''') as ctl_no_str
                                                       from pat_main
                                                                CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                                                       where pat_id = @patId
                                                         and staff_info ->> ''is_main'' = ''1''
                                                         and (staff_info ->> ''ctl_no'' = ''1'' or staff_info ->> ''ctl_no'' = ''2'')) as t)
                                  else take_cource_flg end) as ctl_no
                      from take_cource_info),
     total_number_of_docs as (select count(staff_info) as total
                              from pat_main
                                       CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                              where pat_id = @patId
                                and staff_info ->> ''is_main'' = ''1''
                                and staff_info ->> ''ctl_no'' in (''1'', ''2'')),
     count_all as (select count(staff_info) as counts
                   from pat_main
                            CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                   where pat_id = @patId
                     and staff_info ->> ''is_main'' = ''1''),
     check_staff_code as (select (case ''@chargeStaffInfo.staffCd''
                                      when '''' then ''-999999''
                                      else ''@chargeStaffInfo.staffCd'' end) as staff_code),
     disp_order_For_Doc as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                             from pat_main,
                                                  witch_ctl_no
                                                      CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                             where pat_id = @patId
                                               and info ->> ''ctl_no'' = witch_ctl_no.ctl_no
                                               and info ->> ''flg'' is null),
                                            cast((count_all.counts + 1) as text)) as disp_order
                            from count_all),
     change_status_for_doc as (select 1                                     as no,
                                      coalesce(info ->> ''is_charge'', ''0'')   as is_charge,
                                      coalesce(info ->> ''is_puncture'', ''0'') as is_puncture
                               from pat_main,
                                    witch_ctl_no
                                        CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                               where pat_id = @patId
                                 and info ->> ''ctl_no'' = witch_ctl_no.ctl_no
                               union
                               select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                               order by no
                               limit 1),
     check_for_duplicate as (select (case when count(1) > 0 then false else true end) as check
                             from pat_main,
                                  check_staff_code
                                      CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                             where pat_id = @patId
                               and staff_info ->> ''is_main'' = ''1''
                               and staff_info ->> ''ctl_no'' in (''1'', ''2'')
                               and staff_info ->> ''staff_cd'' = check_staff_code.staff_code)
UPDATE pat_main
SET charge_staff_info = (case
                             when take_cource_info.take_cource_flg = ''0'' then (case
                                                                                   when total_number_of_docs.total < 2 and check_for_duplicate.check
                                                                                       then charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || witch_ctl_no.ctl_no || '',
                          "disp_order": '' || total_number_of_docs.total + 1 || '',
                          "staff_cd": '' || check_staff_code.staff_code || '',
                          "is_main": "1",
                          "is_charge": "0",
                          "is_puncture": "0",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                                                                   else charge_staff_info end)
                             when (take_cource_info.take_cource_flg = ''1'' or take_cource_info.take_cource_flg = ''2'') and
                                  check_for_duplicate.check
                                 then (charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || witch_ctl_no.ctl_no || '',
                          "disp_order": '' || disp_order_For_Doc.disp_order || '',
                          "staff_cd": '' || check_staff_code.staff_code || '',
                          "is_main": "1",
                          "is_charge": "'' || change_status_for_doc.is_charge || ''",
                          "is_puncture": "'' || change_status_for_doc.is_puncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb)
                             else charge_staff_info end),
    up_date           = CURRENT_TIMESTAMP
from take_cource_info,
     total_number_of_docs,
     witch_ctl_no,
     check_staff_code,
     disp_order_For_Doc,
     change_status_for_doc,
     check_for_duplicate
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
