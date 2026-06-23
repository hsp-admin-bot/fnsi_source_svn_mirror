DELETE FROM "ntss"."sys_data_set" WHERE sql_cd in(-662,-663,-664,-665);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-663, 'WITH default_user_no AS (
    -- デフォルト利用者番号delete（検査オーダ用）
    SELECT 0                                                            AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
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
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
    UNION
    SELECT 1   AS order_no
         , ''0'' AS setting
    ORDER BY order_no ASC
    LIMIT 1)
   , ind_user_info AS (
 -- 指示者
  SELECT
    TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_main_hst pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.ind_user_id IS NOT NULL
		order by up_date desc limit 1
)
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
  SELECT
    TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_main_hst pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.up_staff IS NOT NULL
		order by up_date desc limit 1
),
	ind_kur_cd1 as (
	
	 select ind_kur_cd,facility_cd from ord_main where pat_id = (select pat_id from pat_rad_main_hst where rad_result_cd = @ordNo
 order by up_date desc limit 1)
 and     date_part(''YEAR'',cast(treat_date as date))= (select date_part(''YEAR'',reg_rad_date)  from pat_rad_main_hst where rad_result_cd = @ordNo
 order by up_date desc limit 1) 
 and     date_part(''month'',cast(treat_date as date))= (select date_part(''month'',reg_rad_date) from pat_rad_main_hst where rad_result_cd = @ordNo
 order by up_date desc limit 1) 
 and     date_part(''day'',cast(treat_date as date))= (select date_part(''day'',reg_rad_date) from pat_rad_main_hst where rad_result_cd = @ordNo
 order by up_date desc limit 1) 

),
	ind_kur_cd as (
	 select kur_cd as ind_kur_cd from mst_kur,ind_kur_cd1 where mst_kur.kur_cd = ind_kur_cd1.ind_kur_cd and mst_kur.facility_cd = ind_kur_cd1.facility_cd
	 and is_del = ''0'' order by kur_end_time  limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_main_hst where rad_result_cd = @ordNo order by up_date desc limit 1
),
mst_user_authenticator as(
select 2 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>
(select  (
case when 1 =(select reg_rad_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_rad_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_rad_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_rad_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_rad_date from weekend )		
then ''Fri'' 
 when 6 =(select reg_rad_date from weekend )		
then ''Satur'' 
 when 0 =(select reg_rad_date from weekend )		
then ''Sun'' 
END ) as aaa)
)::json->>''user_id'' as staff_cd from mst_kur mst where
facility_cd = @facilityCd
and kur_name = ''午前''
and (select ind_kur_cd from ind_kur_cd ) is null
union 
select 1 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_rad_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_rad_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_rad_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_rad_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_rad_date from weekend)		
then ''Fri'' 
 when 6 =(select reg_rad_date from weekend)		
then ''Satur'' 
 when 7 =(select reg_rad_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
 UNION
         SELECT 3        AS no,
                       staff_cd 
         from default_user_no
         order by no
         limit 1
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
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) =''6''
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
      SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator 
		  WHERE (SELECT setting FROM user_no_setting) =''6''	
				) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）rad_ord利用者番号delete', '2020-05-11 17:19:24.215',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-662, 'WITH default_user_no AS (
  -- デフォルトrad_ord利用者番号（検査オーダ用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
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
    pat_rad_main pem
  WHERE
    pem.rad_result_cd = @ordNo
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
    pat_rad_main pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.up_staff IS NOT NULL
),
ind_kur_cd1 as (
 select ind_kur_cd,facility_cd from ord_main where pat_id = (select pat_id from pat_rad_main where rad_result_cd = @ordNo)
 and     date_part(''YEAR'',cast(treat_date as date))= (select date_part(''YEAR'',reg_rad_date) from pat_rad_main where rad_result_cd = @ordNo) 
 and     date_part(''month'',cast(treat_date as date))= (select date_part(''month'',reg_rad_date) from pat_rad_main where rad_result_cd = @ordNo) 
 and     date_part(''day'',cast(treat_date as date))= (select date_part(''day'',reg_rad_date) from pat_rad_main where rad_result_cd = @ordNo) 
),
	ind_kur_cd as (
	 select kur_cd as ind_kur_cd from mst_kur,ind_kur_cd1 where mst_kur.kur_cd = ind_kur_cd1.ind_kur_cd and mst_kur.facility_cd = ind_kur_cd1.facility_cd
	 and is_del = ''0'' order by kur_end_time  limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_main where rad_result_cd = @ordNo
),
mst_user_authenticator as(
select 2 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>
(select  (
case when 1 =(select reg_rad_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_rad_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_rad_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_rad_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_rad_date from weekend )		
then ''Fri'' 
 when 6 =(select reg_rad_date from weekend )		
then ''Satur'' 
 when 0 =(select reg_rad_date from weekend )		
then ''Sun'' 
END ) as aaa)
)::json->>''user_id'' as staff_cd from mst_kur mst where
facility_cd = @facilityCd
and kur_name = ''午前''
and (select ind_kur_cd from ind_kur_cd ) is null
union 
select 1 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_rad_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_rad_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_rad_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_rad_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_rad_date from weekend)		
then ''Fri'' 
 when 6 =(select reg_rad_date from weekend)		
then ''Satur'' 
 when 7 =(select reg_rad_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
 UNION
         SELECT 3        AS no,
                       staff_cd 
         from default_user_no
         order by no
         limit 1
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
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) =''6''
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
    SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) =''6''
  ) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）rad_ord利用者番号', '2020-05-11 17:19:24.215',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-664, 'SELECT 
 0 AS order_no
  ,disp_user_id   AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id ::TEXT = @userId
 UNION
SELECT 
1 AS order_no
, @default_user_no
 ORDER BY order_no ASC LIMIT 1', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通rad_ord）利用者番号comm取得', '2022-05-07 16:27:46.684',CURRENT_TIMESTAMP, '[{"sql_cd": -662, "field_name": "staff_cd_comm", "replace_var": "@userId"}, {"sql_cd": -662, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-665, 'SELECT 
 0 AS order_no
  ,disp_user_id   AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id ::TEXT = @userId
 UNION
SELECT 
1 AS order_no
, @default_user_no
 ORDER BY order_no ASC LIMIT 1', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通oad_ord）利用者番号data取得', '2022-05-07 16:27:46.685',CURRENT_TIMESTAMP, '[{"sql_cd": -662, "field_name": "staff_cd_data", "replace_var": "@userId"}, {"sql_cd": -662, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
