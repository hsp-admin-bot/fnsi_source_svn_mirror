DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-23,-24);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-23, 'WITH sch_start_time_info AS (
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：検査日時取得', '2020-05-11 15:02:47.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-24, 'with
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
reg_order_class as (
select reg_order_class from pat_exam_main where exam_main_cd = @ordNo
),
kur_qt as(
select (staff.value ->''set_cd'')::text as exam_set_cd from pat_exam_main as pat CROSS JOIN LATERAL json_array_elements(pat.order_exam_set_info ::json) staff where pat.exam_main_cd = @ordNo 
),
kur_time as (
select kur_cd,kur_start_time :: time as time1,kur_end_time ::time as time2 from mst_kur where facility_cd = @facilityCd and is_del = ''0''
),
ind_kur_cd3 as (
select kur_cd ::text as ind_kur_cd from kur_time where time1 <= (select other_exam_time :: time as mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd ) and time2 >= (select other_exam_time ::time as mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd)
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
END ) as aaa))::json->>''disp_user_id'' as staff_cd from mst_kur mst where  mst.kur_cd::text = (select ind_kur_cd from ind_kur_cd3)
and facility_cd = @facilityCd

),
mst_user_authenticator as(
select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
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
END ) as aaa))::json->>''disp_user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
),
	
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
  AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
	AND info ->> ''key1'' = ''EXAMSCHESEND'' 
	AND info ->> ''key2'' = ''DOCTOR_SELECT_MODE'' 
	),
	mst_user_authenticator2 as (
select 
case when (select reg_order_class from reg_order_class) = ''0''
then (select staff_cd from mst_user_authenticator1)
else
(select staff_cd from mst_user_authenticator) end as staff_cd
)
     select staff_cd,code from((SELECT 
    charge_staff ->> ''staff_cd'' AS staff_cd ,
    0  as code
    FROM
      pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
    WHERE
      pm.pat_id = @patId
  
  		AND charge_staff ->> ''is_main'' = ''1''
  		and ''1'' = (select * from ini_key)
  		order by charge_staff ->> ''is_main'' asc LIMIT 1
  		)
  	UNION
  	SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd ,
  		1 as code
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
  	facility_cd = @facilityCd
  
  	AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
    AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
  	AND info ->> ''key1'' = ''EXAMSCHESEND'' 
  	AND info ->> ''key2'' = ''DOCTOR_DEF''
  	and
  	 ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')FROM
      pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
      WHERE
      pm.pat_id = @patId
  
  		AND charge_staff ->> ''is_main'' = ''1'')
  		AND ''1'' = (select * from ini_key)
  		UNION
     select  (case when (((select staff_cd  from mst_user_authenticator2)is NULL OR 
 		(select staff_cd from mst_user_authenticator2)= ''''
 		OR  (select staff_cd from mst_user_authenticator2) = ''0'') and
 	  ''2'' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
 	  facility_cd = @facilityCd
 	  AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
    AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
 	  AND info ->> ''key1'' = ''EXAMSCHESEND'' 
 	  AND info ->> ''key2'' = ''DOCTOR_DEF'' )  
 	  when ((select staff_cd from mst_user_authenticator2)is not NULL and
 		(select staff_cd from mst_user_authenticator2)!= ''''
 		and (select staff_cd from mst_user_authenticator2) != ''0''  and
 	  ''2'' = (select * from ini_key) ) then 
 	  (select staff_cd from mst_user_authenticator2)
 		end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null
		', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼ID', '2020-05-11 17:19:24.215',CURRENT_TIMESTAMP, NULL);
