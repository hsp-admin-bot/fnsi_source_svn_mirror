DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-55, -69, -61, -60);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-55, 'WITH sentence_type_info AS ( 
  -- 文書種別
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sentence_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''REPORT_SEND'' 
    AND info ->> ''key2'' = ''SENTENCE_TYPE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS sentence_type 
  ORDER BY
    order_no ASC LIMIT 1
) 
, document_no_setting_info AS (
  -- 文書番号末尾設定:0：無し、1：01固定
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS document_no_setting 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''DOCUMENT_NO_SETTING'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS document_no_setting 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ord_no_info AS (
  SELECT
    TO_CHAR((CASE WHEN rst_fn_dialysis_no IS NOT NULL AND rst_fn_dialysis_no > 0 THEN rst_fn_dialysis_no ELSE ord_no END), ''FM09999999999999999999999999999999'') AS ord_no
  FROM
    ord_main AS ord
  WHERE
    ord_no = @ordNo
)
, crud_info AS (
  -- 作成更新区分を取得
  SELECT crud FROM sys_coop_journal WHERE ctl_no = @ctlNo
)
, del_cnt_info AS (
-- 削除回数（ゼロ詰め3桁）
  SELECT CASE WHEN (SELECT crud FROM crud_info) = ''D'' THEN TO_CHAR(COUNT(1) - 1, ''FM099'') ELSE TO_CHAR(COUNT(1), ''FM099'') END AS del_cnt
    FROM ord_coop_no AS coopno
   WHERE coopno.facility_cd = @facilityCd AND coopno.pat_id = @patId AND coopno.ord_no= @ordNo AND coopno.coop_cd = ''rep_dial'' AND coopno.is_del = ''1'' 
)
SELECT
  SUBSTR(RPAD(COALESCE(NULLIF((SELECT sentence_type FROM sentence_type_info), ''''), ''''), 8, '' ''), 1, 4) AS sentence_type
  , (SELECT del_cnt FROM del_cnt_info) || CASE WHEN COALESCE(NULLIF((SELECT document_no_setting FROM document_no_setting_info), ''''), ''0'') = ''0'' 
    THEN RIGHT(ord_no, 15)
    ELSE RIGHT(ord_no, 13) || ''01''
    END AS ord_no
FROM ord_no_info', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析レポートの文書番号を取得', '2022-04-04 16:37:06.134', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-69, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''COURSE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS course_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, course_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''COURSE_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS course_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''WARD'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS ward_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ord_main_restore_info AS (
  SELECT 
	  ord_no,
	  pat_id,
		rst_ward_cd,
		rst_course_cd,
		rst_in_out_class
	FROM
	  ord_main_restore
	WHERE
	  pat_id = @patId
		AND
		ord_no = @ordNo
	ORDER BY
	  del_date DESC
	LIMIT 1
)
, exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
        , COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''')as  rst_in_out_class -- 院内コードの変換
  FROM
    pat_main AS main 
        INNER  JOIN ord_main_restore_info AS ord
            on main.pat_id = ord.pat_id
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd  = ord.rst_ward_cd
    LEFT JOIN mst_course AS course 
      ON course.course_cd  = ord.rst_course_cd
        where	
    main.pat_id =  @patId 
        and ord.ord_no = @ordNo
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' or (SELECT course_from FROM course_from_info) = ''2''
      THEN COALESCE(NULLIF((SELECT main_course_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE (SELECT  rst_in_out_class FROM  exam_info) WHEN ''2'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：診療科コードと病棟コード(-20を利用)', '2022-08-31 19:37:34.84', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-61, 'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
    SELECT 0                                                            AS order_no,
           COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
			AND COALESCE(info ->> ''key0'','''') = @key0
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''DIAL_DEFAULT_USER_NO''
    UNION
    SELECT 1  AS order_no,
           '''' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1),
     user_no_setting AS (-- 利用者番号出力設定（透析実績用）
         SELECT 0                                                                                       AS order_no,
                COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
					 AND COALESCE(info ->> ''key0'','''') = @key0
           AND info ->> ''key1'' = ''FJI_COM_INFO''
           AND info ->> ''key2'' = ''DIAL_USER_NO_SETTING''
         UNION
         SELECT 1   AS order_no,
                ''0'' AS setting
         ORDER BY order_no ASC
         LIMIT 1),
     up_user_id_info AS (-- 版確定者
         (SELECT 0                                                                         AS order_no,
                 COALESCE(NULLIF(TO_CHAR(om.up_user_id, ''FM9999999999''), ''''), dn.staff_cd) AS staff_cd
          FROM ord_main om,
               default_user_no dn
          WHERE om.ord_no = @ordNo)
         UNION
         (SELECT 2        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     staff_user_info_1 AS (-- 担当医1
         (SELECT row_number() over ()             AS order_no,
                 NULLIF(staff ->> ''staff_cd'', '''') AS staff_cd
          FROM pat_main pm
                   CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info :: json) staff
          WHERE staff ->> ''is_main'' = ''1''
            AND pm.pat_id = @patId
            AND staff ->> ''ctl_no'' = ''1''
          ORDER BY staff ->> ''disp_order'')
         UNION
         (SELECT 3        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     staff_user_info_2 AS (-- 担当医2
         (SELECT row_number() over ()             AS order_no,
                 NULLIF(staff ->> ''staff_cd'', '''') AS staff_cd
          FROM pat_main pm
                   CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info :: json) staff
          WHERE staff ->> ''is_main'' = ''1''
            AND pm.pat_id = @patId
            AND staff ->> ''ctl_no'' = ''2''
          ORDER BY staff ->> ''disp_order'')
         UNION
         (SELECT 3        AS order_no,
                 staff_cd AS staff_cd
          from default_user_no
          ORDER BY order_no ASC)
         limit 1),
     mst_user_authenticator as (--常勤医
         select (case when t0.staff_cd is null then default_user_no.staff_cd else t0.staff_cd end) as staff_cd
         from (select nullif((select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json) ->>
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
                                                      END) as weeks))::json ->> ''user_id''
                              from ord_main ord,
                                   mst_kur mst
                              where ord.rst_kur_cd = mst.kur_cd
                                and ord.ord_no = @ordNo), '''') as staff_cd) as t0,
              default_user_no)
SELECT (SELECT staff_cd FROM default_user_no)                                     as default_user_no,
       COALESCE(NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''')) as staff_cd_comm,
       COALESCE(NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''')) as staff_name_comm,
       COALESCE(NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''')) as staff_cd_data,
       COALESCE(NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''')) as staff_name_data
FROM (
         -- 0：共通部 版確定者
         (SELECT ''comm'' AS part, staff_cd
          FROM up_user_id_info
          WHERE (SELECT setting FROM user_no_setting) IN (''0'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 1， 3：共通部 担当医１
         (SELECT ''comm'' AS part, staff_cd
          FROM staff_user_info_1
          WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''3'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 2， 4：共通部 担当医２
         (SELECT ''comm'' AS part, staff_cd
          FROM staff_user_info_2
          WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''4'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 5：共通部：常勤医
         (SELECT ''comm'' AS part, staff_cd
          FROM mst_user_authenticator
          WHERE (SELECT setting FROM user_no_setting) IN (''5'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 0：内容部 版確定者
         (SELECT ''data'' AS part, staff_cd
          FROM up_user_id_info
          WHERE (SELECT setting FROM user_no_setting) IN (''0'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 1, 3：内容部 担当医１
         (SELECT ''data'' AS part, staff_cd
          FROM staff_user_info_1
          WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''3'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 2, 4：内容部 担当医２
         (SELECT ''data'' AS part, staff_cd
          FROM staff_user_info_2
          WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''4'')
          LIMIT 1 OFFSET 0)
         UNION
         -- 5：内容部：常勤医
         (SELECT ''data'' AS part, staff_cd
          FROM mst_user_authenticator
          WHERE (SELECT setting FROM user_no_setting) IN (''5'')
          LIMIT 1 OFFSET 0)) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '（実績）「利用者番号」に設定する値の取得', '2022-03-16 08:52:30.73', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-60, '	WITH report_send_post AS (
	SELECT
		info ->> ''key2'' AS key2,
		COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
	VALUE
  FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0'' 
		AND COALESCE(info ->> ''key0'','''') = @key0
		AND info ->> ''key1'' = ''REPORT_SEND'' 
	) 
SELECT 
COALESCE((select VALUE FROM report_send_post WHERE key2=''REPORT_POST''),'''') as report_post,
COALESCE((select VALUE FROM report_send_post WHERE key2=''EXECUTION_POST''),'''') as execution_post', 2, '[{}]', '0', '{"applications": [4]}', NULL, '連携で送信する報告部署・実施部署', '2022-03-14 14:46:10.373', CURRENT_TIMESTAMP, NULL);

