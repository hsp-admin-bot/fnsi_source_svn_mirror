delete from ntss.sys_data_set where sql_cd  IN (-66675,
-66674,
-66673,
-66672,
-66671,
-66670,
-66669,
-66668,
-66667,
-66666,
-66665,
-66664,
-66663,
-66662,
-66661,
-66660);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66675, 'select 
	( CASE ppm.in_out_class WHEN ''1'' THEN ''1'' ELSE''0'' END ) AS in_out,
	(case ppm.in_out_class when ''0'' then ''1'' when ''1'' then ''2''  else ''1'' end) as exam_in_out
from 
	pat_personal_main ppm
where
	pat_id = @patId ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）入外区分', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66674, 'SELECT 
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
 ORDER BY order_no ASC LIMIT 1', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ：施設内職員ID(内容部)取得.削除', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -44, "field_name": "staff_cd_data", "replace_var": "@userId"}, {"sql_cd": -66672, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66673, 'SELECT 
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
 ORDER BY order_no ASC LIMIT 1', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ：施設内職員ID(共通部)取得.削除', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -44, "field_name": "staff_cd_comm", "replace_var": "@userId"}, {"sql_cd": -66672, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66672, 'WITH default_user_no AS (
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
 when 0 =(select reg_exam_date from weekend)		
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
 when 0 =(select reg_exam_date from weekend)		
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼者 ★削除用',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66671, 'WITH examin_info AS ( 
  -- 血液検査情報
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
),
pat_exam_main_hst_do as (
select * FROM
  pat_exam_main_hst AS exam 
WHERE
  exam.exam_main_cd = @ordNo
	order by up_date desc limit 1
)
, conv_order_class_info AS ( 
  -- 透析前後変換(->電子カルテ)
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) ,
sbt_cd_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_sbt_cd''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) 
, examin_hosp_code_info AS ( 
  -- 心電図オーダ送信用の検査セッの院内コード
  SELECT
   COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_IN_HOSP_CODE'' -- TODO：[検査オーダ種別判定]不明、EXAMIN_IN_HOSP_CODEを設定する
		AND info->>''key2'' = ''PHY''
),
data_exam_all as (
SELECT
    T01.order_no
  ,T01.detail_id ::text
  , T01.in_hospital_cd1
  ,T01.sbt_cd1
  ,T01.exam_set_cd
  ,T01.exam_set_name
  , T01.item_name
  , T01.tag_name
  ,T01.sbt_cd1_sort
  ,T01.ordernow
FROM
  (
  SELECT
      0 AS order_no
    , ''検査項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN item.in_hospital_cd1
      WHEN ''2'' THEN item.in_hospital_cd2
      WHEN ''3'' THEN item.in_hospital_cd3
      ELSE item.in_hospital_cd1
      END AS in_hospital_cd1
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd_set
--     , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
	 ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''PHYSIOLOGY_CLASS_ATTR''
		AND info->>''key2'' = (CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
		end))
     ,mset.exam_set_cd,
		 mset.exam_set_name
    , order_info->>''item_name'' AS item_name
    ,
		CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
		end AS tag_name
		,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1_sort
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') =@key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''PHYSIOLOGY_CLASS_SORT''
		AND info->>''key2'' = (CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
		end))
    ,set_info->>''no'' as ordernow
  FROM
    pat_exam_main_hst_do AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''no'' = set_info->>''no'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
  ) AS T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(T01.in_hospital_cd_set, ''''), ''no_cd'') <> ''no_cd'' 
  AND (SELECT value FROM examin_hosp_code_info  )!= ''''-- 心電図オーダの院内コードを設定が存在しない場合は電文が送信されない。
	AND (SELECT value FROM examin_hosp_code_info )is not null
  AND T01.in_hospital_cd_set = (select value from examin_hosp_code_info )
  AND sbt_cd1 <> '''' AND SBT_CD1 IS NOT NULL
order by T01.ordernow
),
max_balance as (
select ((select count(1) from data_exam_all where ordernow  = (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))-
(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))) as balance
,(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa )) as min_number
)
select * from (
(select * from data_exam_all 
where (select balance  from max_balance )  = 0 
limit 298)
union all
(select * from data_exam_all  where (select balance  from max_balance ) != 0 
limit (298 - (select min_number  from max_balance)))
-- 3.7.4.3.3 透析前後区分の設定
UNION ALL
SELECT
  3 AS order_no
  , ''検査項目'' AS detail_id
  , COALESCE(NULLIF((SELECT VALUE FROM conv_order_class_info WHERE key2 = exam.reg_order_class), '''') , exam.reg_order_class) AS           in_hospital_cd1
	
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM  examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    END AS sbt_cd1
    ,NULL AS exam_set_cd
    ,'''' AS exam_set_name
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_NAME''), ''''), ''透析前'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_NAME''), ''''), ''透析後'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_NAME''), ''''), ''その他'') 
    END AS item_name
    , '''' AS tag_name
    ,'''' AS sbt_cd1_sort	
     ,'''' AS ordernow
FROM
pat_exam_main_hst_do as exam

)as T02
ORDER BY
   order_no ASC
  , ordernow ASC
  , sbt_cd1_sort ASC
LIMIT 299 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）依頼検査繰り返し部 ★削除用',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66670, 'with examin_info AS ( 
  --  透析心電図オーダ情報
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
) 
, conv_order_class_info AS ( 
  -- 透析前後変換(->電子カルテ)
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) ,
sbt_cd_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_sbt_cd''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) 
, examin_hosp_code_info AS ( 
  -- 心電図オーダ送信用の検査セッの院内コード
  SELECT
   COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_IN_HOSP_CODE'' -- TODO：[検査オーダ種別判定]不明、EXAMIN_IN_HOSP_CODEを設定する
		AND info->>''key2'' = ''PHY''
) ,
data_exam_all as (
SELECT
    T01.order_no
  ,T01.detail_id ::text
  , T01.in_hospital_cd1
  ,T01.sbt_cd1
  ,T01.exam_set_cd
  ,T01.exam_set_name
  , T01.item_name
  , T01.tag_name
  ,T01.sbt_cd1_sort
  ,T01.ordernow
FROM
  (
  SELECT
      0 AS order_no
    , ''検査項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN item.in_hospital_cd1
      WHEN ''2'' THEN item.in_hospital_cd2
      WHEN ''3'' THEN item.in_hospital_cd3
      ELSE item.in_hospital_cd1
      END AS in_hospital_cd1
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd_set
--     , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
	 ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''PHYSIOLOGY_CLASS_ATTR''
		AND info->>''key2'' = (CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
		end))
     ,mset.exam_set_cd,
		 mset.exam_set_name
    , order_info->>''item_name'' AS item_name
    ,
		CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
		end AS tag_name
		,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1_sort
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') =@key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''PHYSIOLOGY_CLASS_SORT''
		AND info->>''key2'' = (CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
		end))
    ,set_info->>''no'' as ordernow
  FROM
    pat_exam_main AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''no'' = set_info->>''no'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND exam.exam_main_cd = @ordNo 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
  ) AS T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(T01.in_hospital_cd_set, ''''), ''no_cd'') <> ''no_cd'' 
  AND (SELECT value FROM examin_hosp_code_info  )!= ''''-- 心電図オーダの院内コードを設定が存在しない場合は電文が送信されない。
	AND (SELECT value FROM examin_hosp_code_info )is not null
  AND T01.in_hospital_cd_set = (select value from examin_hosp_code_info )
  AND sbt_cd1 <> '''' AND SBT_CD1 IS NOT NULL
order by T01.ordernow
),
max_balance as (
select ((select count(1) from data_exam_all where ordernow  = (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))-
(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))) as balance
,(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa )) as min_number
)
select * from (
(select * from data_exam_all 
where (select balance  from max_balance )  = 0 
limit 298)
union all
(select * from data_exam_all  where (select balance  from max_balance ) != 0 
limit (298 - (select min_number  from max_balance)))
-- 3.7.4.3.3 透析前後区分の設定
UNION ALL
SELECT
  3 AS order_no
  , ''検査項目'' AS detail_id
  , COALESCE(NULLIF((SELECT VALUE FROM conv_order_class_info WHERE key2 = exam.reg_order_class), '''') , exam.reg_order_class) AS           in_hospital_cd1
	
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM  examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    END AS sbt_cd1
    ,NULL AS exam_set_cd
    ,'''' AS exam_set_name
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_NAME''), ''''), ''透析前'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_NAME''), ''''), ''透析後'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_NAME''), ''''), ''その他'') 
    END AS item_name
    , '''' AS tag_name
    ,'''' AS sbt_cd1_sort	
     ,'''' AS ordernow
FROM
  pat_exam_main AS exam 
WHERE
  exam.exam_main_cd  = @ordNo 
)as T02
ORDER BY
   order_no ASC
  , ordernow ASC
  , sbt_cd1_sort ASC
LIMIT 299 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）依頼検査繰り返し部',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66669, 'WITH sch_start_time_info AS (
    -- 予定開始時刻の取得先。0：クールマスタの標準開始時刻（デフォルト）、1：スケジュールの透析開始時刻
    SELECT 0 AS order_no, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sch_start_time
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
      AND COALESCE(info->>''key0'','''') = @key0
      -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''COOP_CONFIG''
      AND info ->> ''key2'' = ''SCH_START_TIME''
    UNION
    SELECT 1 AS order_no, ''0'' AS sch_start_time
    ORDER BY order_no ASC
    LIMIT 1),
     order_time_type_info AS (
         -- オーダ時間の設定値。0：連携設定で時刻を指定、1：透析スケジュールより当日１回目の予定開始時刻
         SELECT 0 AS order_no, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS order_time_type
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAMIN_INFO''
           AND info ->> ''key2'' = ''SET_ORDER_TIME_TYPE''
         UNION
         SELECT 1 AS order_no, ''1'' AS order_time_type
         ORDER BY order_no ASC
         LIMIT 1),
     order_time_info AS (
         -- オーダ時間に設定する値
         SELECT info ->> ''key2''                                                AS key2,
                COALESCE(NULLIF(info ->> ''value'', ''''),
                         COALESCE(NULLIF(info ->> ''default_v'', ''''), ''777700'')) AS order_time
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAMIN_INFO''
           AND info ->> ''key2'' IN (''ORDER_TIME_AFTER'', ''ORDER_TIME_BEFORE'', ''ORDER_TIME_OTHER'')
         UNION
         SELECT ''DEFAULT'' AS key2, ''777700'' AS order_time
         ORDER BY key2 ASC),
     margin_time_info AS (
         -- 検査時刻マージン時間:透析前/透析後マージン時間
         SELECT info ->> ''key2'' AS key2, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS margin_time
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAM_MARGIN_TIME''
           AND info ->> ''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')),
     ind_treat_start_date_time_info AS (
         -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
         SELECT pem.reg_order_class,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                ord.ord_no,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
                CASE
                    WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
         FROM pat_exam_main_hst AS pem
                  LEFT OUTER JOIN ord_main AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND
                                     ord.ind_kur_cd > 0 AND ord.is_del = ''0''
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd
         WHERE pem.exam_main_cd = @ordNo
           AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
         ORDER BY ind_treat_start_time ASC
         LIMIT 1),
     ind_treat_start_date_time_info_re AS (
         -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
         SELECT pem.reg_order_class,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                ord.ord_no,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
                CASE
                    WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
         FROM pat_exam_main_hst AS pem
                  LEFT OUTER JOIN ord_main_restore AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND
                                     ord.ind_kur_cd > 0 AND ord.is_del = ''0''
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd
         WHERE pem.exam_main_cd = @ordNo
           AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
         ORDER BY ind_treat_start_time ASC
         LIMIT 1)
-- ①オーダ時間の設定値。 0：連携設定で時刻を指定
SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
       CASE reg_order_class
           WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''),
                                  (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''),
                                  (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''),
                         (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           END                                AS exam_start_time
FROM pat_exam_main_hst AS pem
WHERE pem.exam_main_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定
-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他
UNION
SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')                     AS exam_date,
       COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') || ''00'' AS exam_start_time
FROM pat_exam_main_hst AS pem
         CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info
         LEFT OUTER JOIN mst_exam_set AS mset ON set_info ->> ''set_cd'' = (mset.exam_set_cd ::TEXT)
WHERE pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0''                                -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
UNION
select t.exam_date as exam_date, t.exam_start_time as exam_start_time
from (SELECT 0 as rows,
             ord.exam_date,
             TO_CHAR(
                     CASE
                         WHEN reg_order_class = ''1''
                             THEN TO_TIMESTAMP(ord.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                             - (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(NULLIF(
                                                      (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                      ''''),
                                              ''0''), ''FM999999''))
                         ELSE TO_TIMESTAMP(ord.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                              (INTERVAL ''1minute'' * ord.treat_times)
                             + (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(
                                             NULLIF(
                                                     (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                     ''''),
                                             ''0''),
                                     ''FM999999''))
                         END, ''HH24MISS'') AS exam_start_time
      FROM ind_treat_start_date_time_info ord
      WHERE ord_no IS NOT NULL                                       -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
        AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
      UNION
      SELECT 1 as rows,
             ord_re.exam_date,
             TO_CHAR(
                     CASE
                         WHEN reg_order_class = ''1''
                             THEN TO_TIMESTAMP(ord_re.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                             - (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(NULLIF(
                                                      (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                      ''''),
                                              ''0''), ''FM999999''))
                         ELSE TO_TIMESTAMP(ord_re.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                              (INTERVAL ''1minute'' * ord_re.treat_times)
                             + (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(
                                             NULLIF(
                                                     (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                     ''''),
                                             ''0''),
                                     ''FM999999''))
                         END, ''HH24MISS'') AS exam_start_time
      FROM ind_treat_start_date_time_info_re ord_re
      WHERE ord_re.ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
        AND (SELECT order_time_type FROM order_time_type_info) = ''1''
      order by rows
      limit 1) as t', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：検査日時取得 ★削除用',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66668, 'WITH course_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_code
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''USE_IN_HOSP_PHYNO'' 
    AND info ->> ''key2'' = ''SLIP_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS course_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, course_name_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_name
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''USE_IN_HOSP_PHYNO'' 
    AND info ->> ''key2'' = ''SLIP_NAME'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS course_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
SELECT 
case when ((SELECT course_code  from course_code_info) is null or
(SELECT course_code  from course_code_info) = '''')
then ''JXXX'' else
(SELECT course_code  from course_code_info) end AS SLIP_CODE ,
case when ((SELECT course_name  from course_name_info)is null or
(SELECT course_name  from course_name_info) = '''')
then ''透析発生生理機能検査'' else
(SELECT course_name from course_name_info  ) end AS SLIP_NAME
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：入外区分、診療科コード、病棟コード、予約枠コード(伝票情報部)取得',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66667, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
		AND COALESCE(info->>''key0'','''') = @key0
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
		AND COALESCE(info->>''key0'','''') = @key0
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
		AND COALESCE(info->>''key0'','''') = @key0
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
		AND COALESCE(info->>''key0'','''') = @key0
		-- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
    , dial_course.course_name AS dial_course_name
    , dial_course.in_hospital_cd_1 AS dial_course_in_hospital_cd 
  FROM
    pat_main AS main 
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
    LEFT JOIN mst_course AS course 
      ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
    LEFT JOIN mst_course AS dial_course
      ON dial_course.course_cd ::TEXT = main.medical_care_info ->> ''dialysis_course_cd'' 
  WHERE
    main.pat_id = @patId 
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    WHEN (SELECT course_from FROM course_from_info) = ''2'' 
      THEN COALESCE(NULLIF((SELECT dial_course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE @inOut WHEN ''1'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ(診療科コードと病棟コード)',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66666, 'WITH pkg_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''GX'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS pkg_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(ini_info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND TRIM(ini_info ->> ''key1'') = ''FJI_COM_INFO'' 
    AND TRIM(ini_info ->> ''key2'') = ''PKG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''GX'' AS pkg_name 
  ORDER BY
    order_no ASC LIMIT 1
) 
, reg_date_info AS ( 
  SELECT
    reg_date 
  FROM
    ord_coop_no 
  WHERE
    ord_no = @ordNo 
    AND ord_no > 0
    AND facility_cd = @facilityCd
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start

    AND coop_version = @coopVersion

-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    AND pat_id = @patId 
    AND coop_cd = (SELECT coop_cd FROM sys_coop_journal WHERE ctl_no = @ctlNo)
    ORDER BY reg_date DESC LIMIT 1
) 
SELECT
  save_2 ->> ''ord_no'' ::TEXT AS ord_no
  , save_2 ->> ''insu_no'' ::TEXT AS insu_no 
FROM
  pat_coop_detail 
WHERE
  pat_id = @patId 
  AND facility_cd = @facilityCd
-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start

  AND coop_version = @coopVersion

-- add 2023-01-16 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  AND is_disp = ''1'' 
  AND is_del = ''0'' 
  AND save_1 ->> ''pkg'' ::TEXT = (SELECT pkg_name FROM pkg_info) 
  AND ( ((SELECT reg_date FROM reg_date_info) IS NOT NULL AND reg_date <= (SELECT reg_date FROM reg_date_info)) 
     OR (SELECT reg_date FROM reg_date_info) IS NULL) 
ORDER BY reg_date DESC LIMIT 1
', 2, '[{}]', '1', '{"applications": [4]}', NULL, '富士通）患者連携情報(受信オーダ番号、保険パターン)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66665, 'WITH sch_start_time_info AS (
    -- 予定開始時刻の取得先。0：クールマスタの標準開始時刻（デフォルト）、1：スケジュールの透析開始時刻
    SELECT 0                                                            AS order_no,
           COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sch_start_time
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''COOP_CONFIG''
      AND info ->> ''key2'' = ''SCH_START_TIME''
    UNION
    SELECT 1   AS order_no
         , ''0'' AS sch_start_time
    ORDER BY order_no ASC
    LIMIT 1
)
   , order_time_type_info AS (
    -- オーダ時間の設定値。0：連携設定で時刻を指定、1：透析スケジュールより当日１回目の予定開始時刻
    SELECT 0                                                            AS order_no,
           COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS order_time_type
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''EXAMIN_INFO''
      AND info ->> ''key2'' = ''SET_ORDER_TIME_TYPE''
    UNION
    SELECT 1   AS order_no
         , ''1'' AS order_time_type
    ORDER BY order_no ASC
    LIMIT 1
)
   , order_time_info AS (
    -- オーダ時間に設定する値
    SELECT info ->> ''key2''                                                                              AS key2,
           COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''777700'')) AS order_time
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''EXAMIN_INFO''
      AND info ->> ''key2'' IN (''ORDER_TIME_AFTER'', ''ORDER_TIME_BEFORE'', ''ORDER_TIME_OTHER'')
    UNION
    SELECT ''DEFAULT'' AS key2
         , ''777700''  AS order_time
    ORDER BY key2 ASC
)
   , margin_time_info AS (
    -- 検査時刻マージン時間:透析前/透析後マージン時間
    SELECT info ->> ''key2''                                              AS key2,
           COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS margin_time
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
			AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
      AND info ->> ''key1'' = ''EXAM_MARGIN_TIME''
      AND info ->> ''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')
)
   , ind_treat_start_date_time_info AS (
    -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
    SELECT pem.reg_order_class,
           TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
           ord.ord_no,
           TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
           CASE
               WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                   THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'',
                                 kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
               ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
               END                                AS ind_treat_start_date_time,
           TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                     ''FM999999'')                  AS treat_times, -- 治療時間
           pem.exam_order_info
    FROM pat_exam_main AS pem
             LEFT OUTER JOIN ord_main AS ord
                             ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND
                                ord.ind_kur_cd > 0 AND ord.is_del = ''0''
             LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd
    WHERE pem.exam_main_cd = @ordNo
      AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
    ORDER BY ind_treat_start_time ASC
    LIMIT 1
)


select exam_date,
       exam_start_time,
       bool_and(in_hospital_cd1 is null and in_hospital_cd2 is null and
                in_hospital_cd3 is null) as has_not_in_hospital_cd
--        s.item_cd
from (
         select exam_date,
                exam_start_time,
                (json_array_elements(exam_order_info::json) -> ''item_cd'')::text as item_cd
         from (
-- ①オーダ時間の設定値。 0：連携設定で時刻を指定
                  SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                         CASE reg_order_class
                             WHEN ''1'' THEN COALESCE(
                                     NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''),
                                            ''''),
                                     (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
                             WHEN ''2'' THEN COALESCE(
                                     NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''),
                                            ''''),
                                     (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
                             ELSE COALESCE(
                                     NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''),
                                            ''''),
                                     (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
                             END                                AS exam_start_time,
                         pem.exam_order_info
                  FROM pat_exam_main AS pem
                  WHERE pem.exam_main_cd = @ordNo
                    AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定

-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他
                  UNION
                  SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')                     AS exam_date,
                         COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') || ''00'' AS exam_start_time,
                         pem.exam_order_info
                  FROM pat_exam_main AS pem
                           CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info
                           LEFT OUTER JOIN mst_exam_set AS mset ON set_info ->> ''set_cd'' = (mset.exam_set_cd ::TEXT)
                  WHERE pem.exam_main_cd = @ordNo
                    AND pem.reg_order_class = ''0''                                -- 0:その他
                    AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
                  UNION
                  SELECT exam_date,
                         TO_CHAR(CASE
                                     WHEN reg_order_class = ''1''
                                         THEN TO_TIMESTAMP(ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                                         - (INTERVAL ''1minute'' * TO_NUMBER(
                                                 COALESCE(NULLIF(
                                                                  (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                                  ''''),
                                                          ''0''), ''FM999999''))
                                     ELSE TO_TIMESTAMP(ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                                          (INTERVAL ''1minute'' * treat_times)
                                         + (INTERVAL ''1minute'' * TO_NUMBER(
                                                 COALESCE(
                                                         NULLIF(
                                                                 (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                                 ''''),
                                                         ''0''),
                                                 ''FM999999''))
                                     END, ''HH24MISS'') AS exam_start_time,
                         ind_treat_start_date_time_info.exam_order_info
                  FROM ind_treat_start_date_time_info
                  WHERE ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
                    AND (SELECT order_time_type FROM order_time_type_info) = ''1''-- 1：透析スケジュール
              ) exam_main) s,
     (
         select exam_item_cd::text as exam_item_cd, in_hospital_cd1, in_hospital_cd2, in_hospital_cd3
         from mst_exam_item) mst_exam_item
where s.item_cd = mst_exam_item.exam_item_cd
group by exam_date, exam_start_time
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：検査日時取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66664, 'SELECT
  ''0'' AS order_no 
  , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
    THEN ''01''
    ELSE ''00'' 
    END AS document_no 
FROM
  mst_coop_ini AS ini 
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
WHERE
  facility_cd = @facilityCd
 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=''GX''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info->>''key1'' = ''FJI_COM_INFO''
  AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
UNION
SELECT
  ''1'' AS order_no 
  , ''00'' AS document_no 
ORDER BY order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ：文書番号取得', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66663, 'select

hosp_pat_id
from

pat_personal_main

where

is_del = ''0''

and

pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '富士通', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66662, 'SELECT 
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
 ORDER BY order_no ASC LIMIT 1', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ：施設内職員ID(内容部)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -66660, "field_name": "staff_cd_data", "replace_var": "@userId"}, {"sql_cd": -26, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66661, 'SELECT 
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
 ORDER BY order_no ASC LIMIT 1', 1, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ：施設内職員ID(共通部)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -66660, "field_name": "staff_cd_comm", "replace_var": "@userId"}, {"sql_cd": -26, "field_name": "default_user_no", "replace_var": "@default_user_no"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66660, 'WITH default_user_no AS (
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
 when 0 =(select reg_exam_date from weekend)		
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
 when 0 =(select reg_exam_date from weekend)		
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通:透析心電図）検査依頼者', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
