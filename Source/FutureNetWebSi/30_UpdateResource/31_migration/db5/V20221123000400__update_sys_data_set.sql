DELETE FROM "ntss"."sys_data_set" WHERE sql_cd in(-666,-26,-44);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-666, 'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
    SELECT
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_staff_cd 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''DIAL_DEFAULT_USER_NO''
				LIMIT 1
    ),
    user_no_setting AS (-- 利用者番号出力設定（透析実績用）
    SELECT
        0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), COALESCE ( NULLIF ( info ->> ''default_v'', '''' ), ''0'' ) ) AS setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''DIAL_USER_NO_SETTING'' UNION
    SELECT
        1 AS order_no,
        ''0'' AS setting 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ),
    up_user_id_info AS (-- 版確定者
    SELECT
        0 AS order_no,
        NULLIF ( TO_CHAR( om.up_user_id, ''FM9999999999'' ), '''' ) AS staff_cd 
    FROM
        ord_main om 
    WHERE
        om.ord_no = @ordNo 
    ),
    staff_user_info AS (-- 担当医
    SELECT
        1 AS order_no,
        NULLIF ( staff ->> ''staff_cd'', '''' ) AS staff_cd 
    FROM
        pat_main pm
        CROSS JOIN LATERAL json_array_elements ( pm.charge_staff_info :: json ) staff 
    WHERE
        staff ->> ''is_main'' = ''1'' 
        AND pm.pat_id = @patId
    ),
		  mst_user_authenticator as (--常勤医
         select 1                                                  as no,
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
           and ord.ord_no = @ordNo
         UNION
         SELECT 3        AS no,
                default_staff_cd AS default_staff_cd
         from default_user_no
         order by no
         limit 1)	 
		
SELECT 
    COALESCE( NULLIF ( MAX ( CASE part WHEN ''comm'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_cd_comm,
    COALESCE( NULLIF ( MAX ( CASE part WHEN ''data'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_cd_data,
		(SELECT default_staff_cd FROM default_user_no)
FROM
(
    (-- 0：共通部 版確定者   
      SELECT ''comm'' AS part, staff_cd  FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) = ''0'' ) UNION   
     -- 1：共通部 担当医１
   -- 3：共通部 担当医１
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) = ''1'' LIMIT 1 OFFSET 0 ) UNION
		( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) = ''3'' LIMIT 1 OFFSET 0 ) UNION
     -- 2：共通部 担当医２
   -- 4：共通部 担当医２
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) = ''2''  LIMIT 1 OFFSET 1 ) UNION
		( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) = ''4''  LIMIT 1 OFFSET 0 ) UNION
	 -- 5：共通部：常勤医		
 		(select ''comm'' AS part,staff_cd from mst_user_authenticator WHERE ( SELECT setting FROM user_no_setting ) IN ( ''5'' )  LIMIT 1 OFFSET 0) UNION
    -- 0：内容部 版確定者
      SELECT ''data'' AS part, staff_cd  FROM up_user_id_info  WHERE ( SELECT setting FROM user_no_setting ) = ''0''  UNION
    -- 1：内容部 担当医１
    -- 3：内容部 担当医１
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN ( ''1'', ''3'' )  LIMIT 1 OFFSET 0 ) UNION
    -- 2：内容部 担当医２
    -- 4：内容部 担当医２
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN ( ''2'', ''4'' )  LIMIT 1 OFFSET 1 ) 
 		union
		-- 5：内容部：常勤医		
 		(select ''data'' AS part,staff_cd from mst_user_authenticator WHERE ( SELECT setting FROM user_no_setting ) IN ( ''5'' )  LIMIT 1 OFFSET 0)
    ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '（実績）利用者番号出力設定', '2022-08-15 00:53:33.139',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-26, 'WITH default_user_no AS (
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
rst_kur_cd as (
 select rst_kur_cd from ord_main where pat_id = (select pat_id from pat_exam_main where exam_main_cd = @ordNo)
 and     date_part(''YEAR'',up_date)= (select date_part(''YEAR'',reg_exam_date) from pat_exam_main where exam_main_cd = @ordNo) 
 and     date_part(''month'',up_date)= (select date_part(''month'',reg_exam_date) from pat_exam_main where exam_main_cd = @ordNo) 
 and     date_part(''day'',up_date)= (select date_part(''day'',reg_exam_date) from pat_exam_main where exam_main_cd = @ordNo) 
 order by up_date
 limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_main where exam_main_cd = @ordNo
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
and (select rst_kur_cd from rst_kur_cd ) is null
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
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select rst_kur_cd from rst_kur_cd)
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼者', '2020-05-12 12:15:09.001',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-44, 'WITH default_user_no AS (
    -- デフォルト利用者番号（検査オーダ用）
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
	rst_kur_cd as (
	select rst_kur_cd from (
	 select 1 as no,rst_kur_cd from ord_main where pat_id = (select pat_id from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1)
 and     date_part(''YEAR'',up_date)= (select date_part(''YEAR'',reg_exam_date)  from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1) 
 and     date_part(''month'',up_date)= (select date_part(''month'',reg_exam_date) from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1) 
 and     date_part(''day'',up_date)= (select date_part(''day'',reg_exam_date) from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1) 
 union all
 (select 2 as no,rst_kur_cd from ord_main_restore where pat_id = (select pat_id from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1)
 and     date_part(''YEAR'',up_date)= (select date_part(''YEAR'',reg_exam_date)  from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1) 
 and     date_part(''month'',up_date)= (select date_part(''month'',reg_exam_date) from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1) 
 and     date_part(''day'',up_date)= (select date_part(''day'',reg_exam_date) from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1) 
 order by ord_main_restore.del_date desc
 limit 1)) A order by A.no limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_main_hst where exam_main_cd = @ordNo order by up_date desc limit 1
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
and (select rst_kur_cd from rst_kur_cd ) is null
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
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select rst_kur_cd from rst_kur_cd)
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼者 ★削除用', '2022-01-17 15:02:47',CURRENT_TIMESTAMP, NULL);
