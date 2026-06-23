DELETE FROM ntss.sys_data_set WHERE sql_cd IN (1009, 1015, 1202, 1203, 1210, 1211, 1212, 1714, 1715);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1009, '-- 原疾患が存在しない場合の更新有無(0：更新する(デフォルト)、 1：更新しない)
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
  AND ini.facility_cd = @facilityCd
  AND COALESCE(ini_info ->> ''key0'','''') = @key0	
  AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
  AND TRIM(ini_info ->> ''key2'') = ''UP_BASE_DISEASE_FLG'' 
UNION 
SELECT
  2 AS order_no
  , ''0'' AS up_base_disease_flg
ORDER BY
  order_no ASC LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)原疾患コードの設定場合、連携設定の原疾患が存在しない場合の更新有無取得', '2022-03-10 09:51:01.219', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1015, 'SELECT
    CASE WHEN @inOutClass = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@inOutClass, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_INOUT_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)連携設定[患者個人情報]の取得', '2022-06-11 12:57:35.682', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1210, 'WITH take_cource_info AS (SELECT 1 AS order_no
                               , CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
                                     ELSE TRIM(ini_info ->> ''value'')
        END                        AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
                            AND ini.facility_cd = ''@facilityCd''
														AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
                            AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML''
                            AND TRIM(ini_info ->> ''key2'') = ''IND_DOCTOR_FLG''
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     noForDoc as (select count(1) + 1 as counts
                  from (select jsonb_array_elements(charge_staff_info) as t0
                        from pat_main
                        where pat_id = @patId) as t1
                  where t1.t0 ->> ''flg'' = ''doc''),
     noForNur as (select (case
                              when take_cource_info.take_cource_flg = ''0'' then c + 3
                              when take_cource_info.take_cource_flg = ''1'' then c + 2 end) as counts
                  from (select count(1) as c
                        from (select jsonb_array_elements(charge_staff_info) as t0
                              from pat_main
                              where pat_id = @patId) as t1
                        where t1.t0 ->> ''flg'' = ''nur'') as t2,
                       take_cource_info),
     countAll as (select coalesce(nullif(max(t1.t0 ->> ''disp_order''), '''')::integer, 0) as counts
                  from (select jsonb_array_elements(charge_staff_info) as t0
                        from pat_main
                        where pat_id = @patId) as t1),
     dispOrderForDoc as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                          from pat_main,
                                               noForDoc
                                                   CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                          where pat_id = @patId
                                            and info ->> ''ctl_no'' = cast(noForDoc.counts as text)
                                            and info ->> ''flg'' is null),
                                         cast((countAll.counts + 1) as text)) as dispOrder
                         from countAll),
     dispOrderForNur as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                          from pat_main,
                                               noForNur
                                                   CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                          where pat_id = @patId
                                            and info ->> ''ctl_no'' = cast(noForNur.counts as text)
                                            and info ->> ''flg'' is null),
                                         cast((countAll.counts + 1) as text)) as dispOrder
                         from countAll),
     changeStatusForDoc as (select 1                                     as no,
                                   coalesce(info ->> ''is_charge'', ''0'')   as isCharge,
                                   coalesce(info ->> ''is_puncture'', ''0'') as isPuncture
                            from pat_main,
                                 noForDoc
                                     CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                            where pat_id = @patId
                              and info ->> ''ctl_no'' = cast(noForDoc.counts as text)
                            union
                            select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                            order by no
                            limit 1),
     changeStatusForNur as (select 1                                     as no,
                                   coalesce(info ->> ''is_charge'', ''0'')   as isCharge,
                                   coalesce(info ->> ''is_puncture'', ''0'') as isPuncture
                            from pat_main,
                                 noForNur
                                     CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                            where pat_id = @patId
                              and info ->> ''ctl_no'' = cast(noForNur.counts as text)
                            union
                            select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                            order by no
                            limit 1),
     checkStaffCode as (select (case ''@chargeStaffInfo.staffCd''
                                    when '''' then ''-999999''
                                    else ''@chargeStaffInfo.staffCd'' end) as staffCode),
     checkIndicatorStaffCode as (select (case ''@chargeStaffInfo.indicatorStaffCd''
                                             when '''' then ''-999999''
                                             else ''@chargeStaffInfo.indicatorStaffCd'' end) as staffCode),
     checkFortest as (select ''@check'' as check)
UPDATE pat_main
SET charge_staff_info =
        CASE ''@chargeStaffInfoFlg''
            WHEN ''''
                THEN ''@chargeStaffInfoValue''
            ELSE (case
                      when take_cource_info.take_cource_flg = ''0'' and
                           ''@chargeStaffInfo.staffCd'' <> ''@'' || ''chargeStaffInfo.staffCd''
                          then (case
                                    when ''@chargeStaffInfo.isMain'' = ''1'' and ''@chargeStaffInfo.isCharge'' = ''0'' and
                                         noForDoc.counts < 3 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForDoc.counts || '',
                          "disp_order": "'' || dispOrderForDoc.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "1",
                          "is_charge": "'' || changeStatusForDoc.isCharge || ''",
                          "is_puncture": "'' || changeStatusForDoc.isPuncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                    when ''@chargeStaffInfo.isMain'' = ''0'' and ''@chargeStaffInfo.isCharge'' = ''1'' and
                                         noForNur.counts < 5 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForNur.counts || '',
                          "disp_order": "'' || dispOrderForNur.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "0",
                          "is_charge": "1",
                          "is_puncture": "'' || changeStatusForNur.isPuncture || ''",
                          "flg":"nur"
                        }
                      ]'' as text) :: jsonb
                                    else charge_staff_info end)
                      when take_cource_info.take_cource_flg = ''1''
                          then (case
                                    when noForDoc.counts = 1 and ''@chargeStaffInfo.indicatorStaffCd'' <> ''@''||''chargeStaffInfo.indicatorStaffCd'' then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": 1,
                          "disp_order": "'' || dispOrderForDoc.dispOrder || ''",
                          "staff_cd": '' || checkIndicatorStaffCode.staffCode || '',
                          "is_main": "1",
                          "is_charge": "'' || changeStatusForDoc.isCharge || ''",
                          "is_puncture": "'' || changeStatusForDoc.isPuncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                    when ''@chargeStaffInfo.isMain'' = ''0'' and ''@chargeStaffInfo.isCharge'' = ''1'' and
                                         ''@chargeStaffInfo.staffCd'' <> ''@'' || ''chargeStaffInfo.staffCd'' and
                                         noForNur.counts < 4 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForNur.counts || '',
                          "disp_order": "'' || dispOrderForNur.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "0",
                          "is_charge": "1",
                          "is_puncture": "'' || changeStatusForNur.isPuncture || ''",
                          "flg":"nur"
                        }
                      ]'' as text) :: jsonb
                                    else charge_staff_info end)
                      else charge_staff_info END) END
from take_cource_info,
     noForDoc,
     noForNur,
     checkStaffCode,
     checkIndicatorStaffCode,
     dispOrderForDoc,
     dispOrderForNur,
     changeStatusForDoc,
     changeStatusForNur
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-06-13 02:07:03.922', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1211, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd''
	  AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''HOSPITALIZATION_DEPT_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
		(''@medicalCareInfo.mainCourseCd2'' :: TEXT) AS dialysis_course_cd
    ,(CASE WHEN ((SELECT take_cource_flg FROM take_cource_info) = ''0'')
			    THEN (''@medicalCareInfo.mainCourseCd2'' :: TEXT)
					ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClassOut'') = ''1'' -- ''1''：入院
                     THEN (''@medicalCareInfo.mainCourseCd'' :: TEXT) 
											ELSE ('''' :: TEXT)
                END)
			END) AS main_course_cd
    , CASE WHEN (''@inOutClassOut'') = ''1'' -- ''1''：入院
      THEN (''@medicalCareInfo.wardCd'' :: TEXT) 
      ELSE ('''' :: TEXT) END AS ward_cd
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF((SELECT dialysis_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', '2022-06-11 01:22:40.159', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1212, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd''
	  AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''	
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''HOSPITALIZATION_DEPT_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
		COALESCE(NULLIF((''@medicalCareInfo.mainCourseCd2''), ''''), medical_care_info->>''dialysis_course_cd'') :: TEXT AS dialysis_course_cd
    ,(CASE WHEN ((SELECT take_cource_flg FROM take_cource_info) = ''0'')
			    THEN COALESCE(NULLIF(''@medicalCareInfo.mainCourseCd2'', ''''), medical_care_info->>''main_course_cd'')
					ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClassOut'') = ''1'' -- ''1''：入院
                     THEN COALESCE(NULLIF(''@medicalCareInfo.mainCourseCd'', ''''), NULLIF(''@medicalCareInfo.mainCourseCd2'', ''''), medical_care_info->>''main_course_cd'')
                     ELSE medical_care_info->>''main_course_cd''
                END)
			END) :: TEXT AS main_course_cd
    , (CASE WHEN (''@inOutClassOut'') = ''1'' -- ''1''：入院
      THEN COALESCE(NULLIF(''@medicalCareInfo.wardCd'', ''''), medical_care_info->>''ward_cd'')
      ELSE '''' END) :: TEXT AS ward_cd
  FROM 
    pat_main
  WHERE 
    is_del = ''0'' 
    AND pat_id = @patId
)
UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
  , medical_care_info = json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF((SELECT dialysis_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_count''
      , medical_care_info->''dialysis_count''
      , ''purification_count''
      , medical_care_info->''purification_count''
      , ''other_dialysis_count''
      , medical_care_info->''other_dialysis_count''
      , ''pat_dialysis_count''
      , medical_care_info->''pat_dialysis_count''
      , ''facility_cd''
      , medical_care_info->>''facility_cd''
      , ''dialysis_start_date''
      , medical_care_info->>''dialysis_start_date''
      , ''hospital_start_date''
      , medical_care_info->>''hospital_start_date''
    )
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル_患者基本情報の修正', '2022-06-11 01:22:40.189', CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1714, 'WITH exam_date_tmp AS ( 
    SELECT CASE WHEN ''@physicalInfo.ctr'' <> '''' THEN NULLIF(''@physicalInfo.examDate_CTR_GMTDate'', '''') ELSE '''' END AS exam_date,
           CASE WHEN ''@physicalInfo.examDate_CTR_GMTDate'' = ''@physicalInfo.examDate_height_GMTDate'' 
                   AND ''@physicalInfo.examDate_height_GMTDate'' <> '''' THEN 1 
                WHEN ''@physicalInfo.examDate_CTR_GMTDate'' <> ''@physicalInfo.examDate_height_GMTDate'' 
                   AND ''@physicalInfo.examDate_CTR_GMTDate'' = '''' 
                   AND ''@physicalInfo.examDate_height_GMTDate'' <> '''' THEN 1
           ELSE 0 END AS do_height_flag
) 
, exam_date_info AS ( 
  SELECT
    CASE WHEN exam_date <> '''' THEN exam_date END AS exam_date
    , CASE WHEN exam_date <> '''' THEN REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS inspect_date
    , CASE WHEN exam_date <> '''' THEN REPLACE(SUBSTR(exam_date, 1, 10), ''-'', '''') END AS indicator_start_date
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
    AND ini.facility_cd = ''@facilityCd''
	  AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''	
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
   T01.indicator_cd
  FROM
   (
    -- 患者情報の担当医の最上位（並び順が最も上）
    (SELECT
       3 AS order_no
       , staff_info->>''staff_cd'' AS indicator_cd 
     FROM
       pat_main AS pat 
       CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info :: json) AS staff_info
     WHERE    
       pat.is_del = ''0'' 
       AND pat.pat_id = @patId
       AND pat.facility_cd = ''@facilityCd'' 
     ORDER BY 
       CASE WHEN staff_info->>''is_main'' = ''1'' THEN 0  WHEN staff_info->>''is_charge'' = ''1'' THEN 1 ELSE 2 END ASC
       , staff_info->>''ctl_no'' ASC 
       LIMIT 1
    )
    -- なければ施設設定の25番のIDを使用
    UNION 
    SELECT
      2 AS order_no
      , COALESCE(NULLIF(TRIM(fset.value), ''''), ''0'')  AS indicator_cd 
    FROM
      mst_facility_setting AS fset 
    WHERE
      fset.facility_setting_no = ''1025'' 
      AND fset.facility_cd = ''@facilityCd'' 
    -- 未指定の場合は連携設定のデフォルト指示医とする
    UNION 
    SELECT
      1 AS order_no
      , CASE 
        WHEN TRIM(ini_info ->> ''value'') = '''' OR TRIM(ini_info ->> ''value'') = ''0'' 
          THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END AS indicator_cd 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
      AND ini.facility_cd = ''@facilityCd''
		  AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''	
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''DEFAULT_DOCTOR'' 
    -- デフォルト
    UNION 
    SELECT
      0 AS order_no
      , '''' AS indicator_cd 
   ) AS T01
  WHERE
    T01.indicator_cd <> ''0''
  ORDER BY
    T01.order_no DESC LIMIT 1
) 
, data_new_info AS (
  SELECT 
    NULL AS dw,
    TRIM(NULLIF(''@physicalInfo.ctr'', ''''), ''0'') AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    CASE WHEN (SELECT do_height_flag FROM exam_date_tmp) = 1 THEN TRIM(NULLIF(''@physicalInfo.height'', ''''), ''0'') ELSE NULL END AS height,
    CASE WHEN ''@physicalInfo.ctr'' = '''' THEN NULL ELSE TRIM(NULLIF(''@physicalInfo.chestDia'', ''''), ''0'') END AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    CASE WHEN ''@physicalInfo.ctr'' = '''' THEN NULL ELSE TRIM(NULLIF(''@physicalInfo.breastDia'', ''''), ''0'') END AS breast_dia,
    TRIM(NULLIF(''@physicalInfo.ctrWeight'', ''''), ''0'') AS ctr_weight,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    COALESCE(NULLIF((SELECT order_class FROM order_class_info), ''0''), ''3'') AS order_class,
    (SELECT indicator_cd FROM indicator_info) AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date,
    ''-1'' AS target_weight
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS OLD 
    , data_new_info AS NEW 
  WHERE
    patu.pat_id = @patId 
    AND patu.facility_cd = ''@facilityCd'' 
    AND patu.is_del = ''0'' 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''ctr''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.ctr ::TEXT, ''''), ''0''), ''FM9999.99'') 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''chest_dia''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.chest_dia ::TEXT, ''''), ''0''), ''FM9999.99'') 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''breast_dia''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.breast_dia ::TEXT, ''''), ''0''), ''FM9999.99'') 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''height''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.height, ''''), ''0''), ''FM9999.99'')
    AND SUBSTR(OLD->>''exam_date''::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
    --AND TO_NUMBER(OLD->>''ctr_weight''::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.ctr_weight ::TEXT, ''FM9999.99'') 
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
    ''indicator_cd'', (NULLIF(indicator_cd, '''') :: INTEGER),
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
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' 
  AND ((''@physicalInfo.ctr'' <> '''' AND ''@physicalInfo.examDate_CTR_GMTDate'' <> '''')
  OR (''@physicalInfo.height'' <> '''' AND ''@physicalInfo.examDate_height_GMTDate'' <> ''''))
  AND (SELECT exam_date FROM data_new_info) IS NOT NULL', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_身体情報', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1715, 'WITH exam_date_tmp AS ( 
  SELECT 
    NULLIF(''@physicalInfo.examDate_height_GMTDate'', '''') AS exam_date,
    CASE WHEN NULLIF(''@physicalInfo.examDate_height_GMTDate'', '''') = NULLIF(''@physicalInfo.examDate_CTR_GMTDate'', '''') THEN 0 ELSE 1 END AS date_flag
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
    AND ini.facility_cd = ''@facilityCd''
	  AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''	
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
   T01.indicator_cd
  FROM
   (
    -- 患者情報の担当医の最上位（並び順が最も上）
    (SELECT
       3 AS order_no
       , staff_info->>''staff_cd'' AS indicator_cd 
     FROM
       pat_main AS pat 
       CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info :: json) AS staff_info
     WHERE    
       pat.is_del = ''0'' 
       AND pat.pat_id = @patId
       AND pat.facility_cd = ''@facilityCd'' 
     ORDER BY 
       CASE WHEN staff_info->>''is_main'' = ''1'' THEN 0  WHEN staff_info->>''is_charge'' = ''1'' THEN 1 ELSE 2 END ASC
       , staff_info->>''ctl_no'' ASC 
       LIMIT 1
    )
    -- なければ施設設定の25番のIDを使用
    UNION 
    SELECT
      2 AS order_no
      , COALESCE(NULLIF(TRIM(fset.value), ''''), ''0'')  AS indicator_cd 
    FROM
      mst_facility_setting AS fset 
    WHERE
      fset.facility_setting_no = ''1025'' 
      AND fset.facility_cd = ''@facilityCd'' 
    -- 未指定の場合は連携設定のデフォルト指示医とする
    UNION 
    SELECT
      1 AS order_no
      , CASE 
        WHEN TRIM(ini_info ->> ''value'') = '''' OR TRIM(ini_info ->> ''value'') = ''0'' 
          THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
        ELSE TRIM(ini_info ->> ''value'') 
        END AS indicator_cd 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
    WHERE
      ini.is_del = ''0'' 
      AND ini.facility_cd = ''@facilityCd''
		  AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''	
      AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
      AND TRIM(ini_info ->> ''key2'') = ''DEFAULT_DOCTOR'' 
    -- デフォルト
    UNION 
    SELECT
      0 AS order_no
      , '''' AS indicator_cd 
   ) AS T01
  WHERE
    T01.indicator_cd <> ''0''
  ORDER BY
    T01.order_no DESC LIMIT 1
) 
, data_new_info AS (
  SELECT 
    NULL AS dw,
    NULL AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    TRIM(NULLIF(''@physicalInfo.height'', ''''), ''0'') AS height,
    NULL AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    NULL AS breast_dia,
    TRIM(NULLIF(''@physicalInfo.ctrWeight'', ''''), ''0'') AS ctr_weight,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    COALESCE(NULLIF((SELECT order_class FROM order_class_info), ''0''), ''3'') AS order_class,
    (SELECT indicator_cd FROM indicator_info) AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date,
    ''-1'' AS target_weight
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS OLD 
    , data_new_info AS NEW 
  WHERE
    patu.pat_id = @patId 
    AND patu.facility_cd = ''@facilityCd'' 
    AND patu.is_del = ''0'' 
    AND TO_NUMBER(COALESCE(NULLIF(OLD->>''height''::TEXT, ''''), ''0''), ''FM9999.99'') = TO_NUMBER(COALESCE(NULLIF(NEW.height ::TEXT, ''''), ''0''), ''FM9999.99'') 
    --AND TO_NUMBER(OLD->>''ctr_weight''::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.ctr_weight ::TEXT, ''FM9999.99'') 
    AND SUBSTR(OLD->>''exam_date''::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
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
    ''indicator_cd'', (NULLIF(indicator_cd, '''') :: INTEGER),
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
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' 
  AND (SELECT date_flag FROM exam_date_tmp) = 1
  AND ''@physicalInfo.examDate_height_GMTDate'' <> ''''
  AND ''@physicalInfo.height'' <> ''''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_身体情報', '2022-06-10 10:47:32.927', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
		AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClass'') = ''1'' -- ''1''：入院
      THEN (''@medicalCareInfo.mainCourseCd'' :: TEXT) 
      ELSE ('''' :: TEXT) END AS main_course_cd
    , (''@medicalCareInfo.wardCd'' :: TEXT) AS ward_cd
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', '2022-01-28 18:21:40', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'WITH take_cource_info AS (SELECT 1 AS order_no
                               , CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'')
                                     ELSE TRIM(ini_info ->> ''value'')
        END                        AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
                            AND ini.facility_cd = ''@facilityCd''
														AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
                            AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND''
                            AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG''
                          UNION
                          SELECT 2   AS order_no
                               , ''1'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     cource_ward_info AS (SELECT (CASE
                                      WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND
                                           (''@inOutClass'') = ''1'' -- ''1''：入院
                                          THEN ''@medicalCareInfo.mainCourseCd''
                                      ELSE medical_care_info ->> ''main_course_cd''
         END) :: TEXT                                                     AS main_course_cd
                               , (case ''@medicalCareInfo.wardCd''
                                      when '''' then medical_care_info ->> ''ward_cd''
                                      else ''@medicalCareInfo.wardCd'' end) AS ward_cd
                          FROM pat_main
                          WHERE is_del = ''0''
                            AND pat_id = @patId)
UPDATE pat_main
SET up_date              = CURRENT_TIMESTAMP
  , in_out_current_state = (case ''@isDie'' when ''1'' then ''11'' else in_out_current_state end)
  , medical_care_info    = json_build_object(
        ''main_course_cd''
    , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
    , ''dialysis_course_cd''
    , medical_care_info -> ''dialysis_course_cd''
    , ''ward_cd''
    , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
    , ''dialysis_count''
    , medical_care_info -> ''dialysis_count''
    , ''purification_count''
    , medical_care_info -> ''purification_count''
    , ''other_dialysis_count''
    , medical_care_info -> ''other_dialysis_count''
    , ''pat_dialysis_count''
    , medical_care_info -> ''pat_dialysis_count''
    , ''facility_cd''
    , medical_care_info ->> ''facility_cd''
    , ''dialysis_start_date''
    , medical_care_info ->> ''dialysis_start_date''
    , ''hospital_start_date''
    , medical_care_info ->> ''hospital_start_date''
    )
WHERE is_del = ''0''
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-01-28 18:21:40', CURRENT_TIMESTAMP, NULL);
