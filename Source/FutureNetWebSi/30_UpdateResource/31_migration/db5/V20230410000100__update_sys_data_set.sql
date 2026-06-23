DELETE FROM "ntss"."sys_data_set" WHERE sql_cd in (-192,-195,-59,-194,-150,-81,-800010,-53);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-192, 'select
	 staffs.*
from (
(select 
  1 as no,
	staff ->>''staff_cd'' as staff_cd
from 
	ord_main ord,
	pat_main pm
	cross join lateral
      json_array_elements (pm.charge_staff_info :: json) staff
where
	staff->>''is_main'' = ''1'' and
	ord.ord_no = @ordNo
 and
	pm.pat_id = ord.pat_id)
union
(select 
  3 as no,
 ord.ind_schedule_user_info->>''ind_user_id'' as staff_cd
from 
	ord_main ord
where
	ord.ord_no = @ordNo)
	union
(select 
  2 as no,
	staff ->>''staff_cd'' as staff_cd
from 
	ord_main_restore ord,
	pat_main pm
	cross join lateral
      json_array_elements (pm.charge_staff_info :: json) staff
where
	staff->>''is_main'' = ''1'' and
	ord.ord_no = @ordNo
 and
	pm.pat_id = ord.pat_id
	ORDER BY ord.del_date DESC LIMIT 1)
union
(select 
 4 as no,
 ord.ind_schedule_user_info->>''ind_user_id'' as staff_cd
from 
	ord_main_restore ord
where
	ord.ord_no = @ordNo
	ORDER BY ord.del_date DESC LIMIT 1)
) staffs

order by no limit 1
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '実績）担当医先頭１名(担当医→版確定者）', '2022-09-21 17:35:53.466',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-59, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
(SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time
FROM
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo)
	UNION
	(SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time
FROM
  ord_main_restore ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
	and (select count(1) from ord_main where ord_no = @ordNo) = ''0''
	order by del_date desc limit 1)', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：オーダ日付とオーダ時間取得', '2022-03-22 10:53:38.415',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-195, 'WITH default_user_no AS (
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
, do_ord AS (
(SELECT 
ord_no,
null as del_date,
pat_id,
fn_pat_id,
treat_date,
treat_week,
facility_cd,
facility_name,
ind_va_cd,
ind_treatment_cd,
ind_treatment_name,
ind_kur_cd,
ind_kur_name,
ind_treat_start_time,
ind_bed_cd,
ind_bed_name,
ind_schedule_user_info,
ind_cond_info,
ind_medi_info,
ind_equip_info,
ind_ind_comment_info,
ind_tare_info,
ind_off_water_info,
ind_device_set_info,
rst_fn_dialysis_no,
rst_relation_dialysis_no,
rst_edition,
rst_is_update_edition,
rst_input_class,
rst_dialysis_state,
rst_treatment_cd,
rst_treatment_name,
rst_kur_cd,
rst_kur_name,
rst_bed_cd,
rst_bed_name,
rst_machine_no,
rst_machine_name,
rst_cond_send_date,
rst_accept_date,
rst_start_date,
rst_end_date,
rst_return_home_date,
rst_in_out_class,
rst_dialysis_cnt,
rst_ward_cd,
rst_ward_name,
rst_course_cd,
rst_course_name,
rst_puncture_user_info,
rst_return_user_info,
rst_charge_user_info,
rst_blood_circulate_total,
rst_running_time,
rst_kt_v,
rec_set_date,
send_ctl_no,
blood_purifier_name,
pull_leave_amount,
rst_cond_info,
rst_medi_info,
rst_equip_info,
rst_ind_comment_info,
rst_tare_info,
rst_off_water_info,
rst_device_set_info,
rst_weight_info,
rst_vital_info,
rst_complaint_info,
rst_treatment_info,
rst_treat_staff_info,
rst_rounds_info,
is_del,
up_date ,
up_ind_user_id,
up_user_id,
reg_date,
treat_type,
rst_purification_cnt,
rst_dw,
weight_scale_no,
fn_plural,
is_confirm,
ind_dw,
addition_info,
rst_edition_date,
cur_edition_date,
bvms_path
 FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo
 AND ord_i.facility_cd = @facilityCd)
 UNION 
(SELECT 
*
FROM ord_main_restore as ord_i
WHERE ord_i.ord_no =  @ordNo
 AND ord_i.facility_cd = @facilityCd
 AND (SELECT count(1) FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo)=''0''
ORDER BY del_date DESC LIMIT 1)
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
    do_ord AS om
		)
  UNION 
  (SELECT
    1 AS order_no
    , ind_cond_info ->> ''ind_user_id'' AS ind_staff_cd 
    , ind_cond_info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    (SELECT
       om.ind_cond_info -> jsonb_object_keys(om.ind_cond_info) AS ind_cond_info 
     FROM
       do_ord AS om 
		 ) AS T)
  UNION 
  (SELECT
    2 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    do_ord AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_medi_info ::json) info )
  UNION
  (SELECT
    3 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    do_ord AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) info 
	)
  UNION
  (SELECT
    4 AS order_no
    , info ->> ''ind_user_id'' AS ind_staff_cd 
    , info ->> ''upd_user_id'' AS upd_staff_cd 
  FROM
    do_ord AS om
    CROSS JOIN LATERAL json_array_elements(om.ind_ind_comment_info ::json) info 
	)
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
    AND pm.pat_id = ''16897''

 
    AND staff ->> ''is_main'' = ''1'' 
)
,
 mst_user_authenticator as (--常勤医
         select 
                (json_array_elements((mst.mst_user_authentication ->> ''data'')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from do_ord ord )
                                     then ''Mon''
                                 when 2 = (select treat_week from do_ord ord )

                                     then ''Tues''
                                 when 3 = (select treat_week from do_ord ord) 

                                     then ''Wednes''
                                 when 4 = (select treat_week from do_ord ord )

                                     then ''Thurs''
                                 when 5 = (select treat_week from do_ord ord )
                                     then ''Fri''
                                 when 6 = (select treat_week from do_ord ord )

                                     then ''Satur''
                                 when 7 = (select treat_week from do_ord ord )
                                     then ''Sun''
                                 END) as aaa))::json ->> ''user_id'' as staff_cd
         from (select * from do_ord ord ) ord,
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：共通部と伝票情報の利用者番号取得', '2022-02-28 14:34:34.866',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-194, 'WITH dialysis_item_send AS (-- 透析項目送信
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
)
, do_ord_main AS (
(SELECT 
ord_no,
null as del_date,
pat_id,
fn_pat_id,
treat_date,
treat_week,
facility_cd,
facility_name,
ind_va_cd,
ind_treatment_cd,
ind_treatment_name,
ind_kur_cd,
ind_kur_name,
ind_treat_start_time,
ind_bed_cd,
ind_bed_name,
ind_schedule_user_info,
ind_cond_info,
ind_medi_info,
ind_equip_info,
ind_ind_comment_info,
ind_tare_info,
ind_off_water_info,
ind_device_set_info,
rst_fn_dialysis_no,
rst_relation_dialysis_no,
rst_edition,
rst_is_update_edition,
rst_input_class,
rst_dialysis_state,
rst_treatment_cd,
rst_treatment_name,
rst_kur_cd,
rst_kur_name,
rst_bed_cd,
rst_bed_name,
rst_machine_no,
rst_machine_name,
rst_cond_send_date,
rst_accept_date,
rst_start_date,
rst_end_date,
rst_return_home_date,
rst_in_out_class,
rst_dialysis_cnt,
rst_ward_cd,
rst_ward_name,
rst_course_cd,
rst_course_name,
rst_puncture_user_info,
rst_return_user_info,
rst_charge_user_info,
rst_blood_circulate_total,
rst_running_time,
rst_kt_v,
rec_set_date,
send_ctl_no,
blood_purifier_name,
pull_leave_amount,
rst_cond_info,
rst_medi_info,
rst_equip_info,
rst_ind_comment_info,
rst_tare_info,
rst_off_water_info,
rst_device_set_info,
rst_weight_info,
rst_vital_info,
rst_complaint_info,
rst_treatment_info,
rst_treat_staff_info,
rst_rounds_info,
is_del,
up_date ,
up_ind_user_id,
up_user_id,
reg_date,
treat_type,
rst_purification_cnt,
rst_dw,
weight_scale_no,
fn_plural,
is_confirm,
ind_dw,
addition_info,
rst_edition_date,
cur_edition_date,
bvms_path
 FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo
 AND ord_i.facility_cd = @facilityCd)
 UNION all
(SELECT 
*
FROM ord_main_restore as ord_i
WHERE ord_i.ord_no =  @ordNo
 AND ord_i.facility_cd = @facilityCd
 AND (SELECT count(1) FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo)=''0''
ORDER BY del_date DESC LIMIT 1)
)
,item_set_info AS (
  --連携設定の項目設定値
  SELECT
    info->>''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
)
, item_sort_info AS (
  --連携設定「項目情報部出力順（予約/実績送信用）」の設定値
  SELECT
    info->>''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''DIALYSIS_ITEM_SORT''
)
, ind_set_medicine_resolve_info AS (
  --セット薬剤の扱いの設定値
  SELECT
    info ->> ''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
)
, solution_cnt AS (
  --透析液取得件数
  SELECT 
    COUNT(*) AS cnt
  FROM
    do_ord_main ord
  LEFT OUTER JOIN
     mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
  WHERE
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
)
, dialysis_item_procedure_tag_info AS (
  --手技タグ名称の設定値
  SELECT
    info ->> ''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
)
,  device AS (
        SELECT device_mode
        FROM mst_treatment mst JOIN do_ord_main ord 
        ON ord.ind_treatment_cd = mst.treatment_cd 
)
, fji_com_info AS (-- 富士通共通設定
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''FJI_COM_INFO'' 
 )
, dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd =  @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT'' 
 )
, conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
 )
, conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
 )
, dialysis_send AS ( -- 透析发送
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_SEND'' 
 )
, int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
 )
, DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
  SELECT
   info ->> ''key2'' AS key2,
   COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE 
  FROM
   mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
   facility_cd = @facilityCd
   AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
 )
 , bed_conv as(       
    SELECT
    0 AS order_no,
        to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
     FROM
        mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''BED_CODE_CONV'' UNION
    SELECT
        1 AS order_no,
        1 AS bed_conv 
    ORDER BY
        order_no ASC 
        LIMIT 1 
)
, dialysis_difficulty_info AS ( 
    SELECT ROW_NUMBER
        ( ) OVER ( ) AS row_no,
        details 
    FROM
        ( SELECT regexp_split_to_table( ''182''
, '','' ) AS details ) AS T)
, do_order_data_equip_from AS ( --施設設定106设置获取
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt)
, do_mstmeq_cd AS (--医療材料マスタ表示顺
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
AND master_physical_name = ''mst_equipment'' )
, do_mstmeq_class_cd AS (--医療材料分類マスタ表示顺
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
AND master_physical_name = ''mst_equipment_class'' )
, do_order_data_from AS (--施設設定107设置获取
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt)
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicine_mix'' 
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicine'' 
)
, do_mstmedi_class_cd AS (
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicine_class'' 
)
, do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicate_timing'' 
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_procedure'' 
)
,kou_coag_procedur_falg AS (
    SELECT
        1 AS ctl 
    FROM
        (
        SELECT COUNT
            ( * ) AS cnt 
        FROM
            ind_set_medicine_resolve_info 
        WHERE
            ( key2 IN ( ''KOU_COAG_PROCEDURE_ATTR'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_CODE'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_NAME'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
        ) T 
    WHERE
        cnt = 3 UNION
    SELECT
        2 AS ctl 
    ORDER BY
        ctl 
        LIMIT 1
    ) 
, kou_coag_procedur_data AS(            
    SELECT 
    VALUE   
    FROM
        (
        SELECT
            info ->> ''key2'' AS key2,
            COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
        VALUE
            
        FROM
            mst_coop_ini AS ini
            CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
        WHERE
            facility_cd = @facilityCd
            AND is_del = ''0'' 
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start            
            AND COALESCE ( info ->> ''key0'', '''' ) = @key0 
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
        ) T 
    WHERE
        key2 = ( SELECT VALUE FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_PROCEDURE_CODE'' ) 
        LIMIT 1
) 
, data_middle_all AS (
SELECT
 all_cost.* 
FROM
 (SELECT
    --①ベッドＮＯ
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(
    CASE
      WHEN (ord.ind_bed_cd IS NULL or ord.ind_bed_cd = 0)
        THEN ''V9999999''
      ELSE
        CASE
          WHEN COALESCE((SELECT value FROM fji_com_info WHERE key2 = ''BED_CODE_CONV''), '''') = ''1''
            THEN mbd.in_hospital_cd_1
          WHEN COALESCE((SELECT value FROM fji_com_info WHERE key2 = ''BED_CODE_CONV''), '''') = ''2''
            THEN mbd.in_hospital_cd_2
          ELSE ''V9999999''
        END
    END, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BED_NO_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(mbd.bed_name, ''ベッド未登録'') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BED_NO_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BED_NO''), '''') AS e09 ,
        '''' as sorttag1,
        '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_bed mbd ON mbd.bed_cd = ord.ind_bed_cd
UNION
SELECT
    --②浄化方法
    ''予約詳細'' AS detail_id, 
    --項目コード
    CASE
    --患者の入外区分が外来の場合
     WHEN @inOut = ''0'' THEN COALESCE(mtt.in_hospital_cd_a1, '''')
    --患者の入外区分が入院の場合
    WHEN @inOut = ''1'' THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
    ELSE '''' END AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(mtt.treatment_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TREAT''), '''') AS e09,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt ON mtt.treatment_cd = ord.ind_treatment_cd
UNION
SELECT
    --③希望開始時刻
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    SUBSTRING(ord.ind_treat_start_time,1,2) || '':'' || SUBSTRING(ord.ind_treat_start_time,3,2) AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_START_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --④希望終了時刻
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    TO_CHAR(TO_TIMESTAMP(ord.treat_date||'' ''||SUBSTRING(ord.ind_treat_start_time,1,2)||'':''||SUBSTRING(ord.ind_treat_start_time,3,2)||'':00'', ''YYYYMMDD HH24:MI:SS'') + (interval ''1minute'' * TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')) ,''HH24:MI'') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_END_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT 
    --⑤予定所要時間
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SCHE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑥目標体重
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''/'' || SUBSTRING(ord.treat_date, 5, 2) || ''/'' || SUBSTRING(ord.treat_date, 7, 2), '''') AS e03, 
    --数量
    CASE
    --DWと同じの場合
    WHEN TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') = -1
      THEN TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value_dw'', ''0''),''9999999.999'') ,''FM0999999.990'')
    ELSE TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') ,''FM0999999.990'') END AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG''), '''') as e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TARGET_WEIGHT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑦ドライウェイト
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''/'' || SUBSTRING(ord.treat_date, 5, 2) || ''/'' || SUBSTRING(ord.treat_date, 7, 2), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''3''->>''value_dw'', ''0''),''9999999.999'') ,''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DRY_WEIGHT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑧ＶＡ
    ''予約詳細'' AS detail_id, 
    --項目コード 
    COALESCE(mva.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mva.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SHUNT_PART_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mva.va_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SHUNT_PART_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SHUNT_PART''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_va mva ON mva.va_cd = TO_NUMBER(ord.ind_cond_info->''2''->>''value'',''999999999999'')
UNION
SELECT
    --⑨透析器
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(mdz.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mdz.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mdz.model_number, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DIAL_INST''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_dialyzer mdz ON mdz.dialyzer_cd = TO_NUMBER(ord.ind_cond_info->''5''->>''value'',''999999999999'')
UNION
SELECT
    --⑩吸着器
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_ADSORPTION_INST_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''6''->>''value'',''999999999999'')
UNION
SELECT
    --⑪1次膜(吸着器or血漿分離器)
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_FIRST_FILM_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_FIRST_FILM_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FIRST_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''7''->>''value'',''999999999999'')
UNION
SELECT
    --⑫2次膜(吸着器or血漿分離器)
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SECOND_FILM_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SECOND_FILM_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SECOND_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''8''->>''value'',''999999999999'')
UNION
--⑬医療材料（回路・針など）
SELECT
    --A針情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''1'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''9''->>''value'' IS NOT NULL
UNION
SELECT
    --V針情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''2'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''10''->>''value'' IS NOT NULL
UNION
SELECT
    --SN針情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''3'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''11''->>''value'' IS NOT NULL
UNION
SELECT
    --血液回路情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''4'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''13''->>''value'' IS NOT NULL
UNION
SELECT 
    --⑭透析液
    ''予約詳細'' AS detail_id, 
    --項目コード
    --CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01,
        COALESCE(mmd.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
                     ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''17''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
                     ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''17''->>''value'',''0''), ''9999999.999'') + TO_NUMBER(COALESCE(ord.ind_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'')
      ELSE ''0000000.000''
    END AS e04,
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
--WHERE
--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
UNION
SELECT 
    --⑮置換液（補液）
    ''予約詳細'' AS detail_id, 
    --項目コード
    --CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE COALESCE(TRIM(mmd.in_hospital_cd_1), '''') END AS e01,
        COALESCE(mmd.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_REPLACE''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''19''->>''value'',''999999999999'')
WHERE
--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''REPLACE_RESOLVE_MODE'') = ''0''
    ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'' 
    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --⑯抗凝固剤・初回
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  mmd.in_hospital_cd_1 END), '''') AS e01, 
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''26''->>''value'', ''0''), ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05, 
    --単位コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' then mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑰抗凝固剤・持続
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  
        (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01, 
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE  mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''27''->>''value'', ''0''), ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05, 
    --単位コード
    CASE
      WHEN (SELECT value FROM item_set_info WHERE key2 = ''ADD_UNIT_FLG'') = ''1''
        THEN
          CASE 
            WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
              THEN 
                CASE
                  WHEN mmx.unit IS NULL OR mmx.unit = ''''
                    THEN ''''
                  ELSE mmx.unit || ''/h'' 
                END
            ELSE
              CASE
                WHEN mmd.unit IS NULL OR mmd.unit = ''''
                  THEN ''''
                ELSE mmd.unit || ''/h'' 
              END
          END
      ELSE 
        CASE 
          WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' 
            THEN
              COALESCE(mmx.unit, '''')
          ELSE
            COALESCE(mmd.unit, '''')
        END
    END AS e06, 
    --単位名称
    CASE
      WHEN (SELECT value FROM item_set_info WHERE key2 = ''ADD_UNIT_FLG'') = ''1''
        THEN
          CASE 
            WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
              THEN 
                CASE
                  WHEN mmx.unit IS NULL OR mmx.unit = ''''
                    THEN ''''
                  ELSE mmx.unit || ''/h'' 
                END
            ELSE
              CASE
                WHEN mmd.unit IS NULL OR mmd.unit = ''''
                  THEN ''''
                ELSE mmd.unit || ''/h'' 
              END
          END
      ELSE 
        CASE 
          WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' 
            THEN
              COALESCE(mmx.unit, '''')
          ELSE
            COALESCE(mmd.unit, '''')
        END
    END AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG''), '''') AS e09 ,
        '''' as sorttag1,
        '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT 
    --⑱抗凝固剤・ＴＯＴＡＬ
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  
        (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01,
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE  mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''26''->>''value'', ''0''), ''9999999.999'') + TO_NUMBER(COALESCE(ord.ind_cond_info->''28''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05, 
    --単位コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' then mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑲血液流量
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_NAME''), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''14''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BLOOD_AMT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    TO_NUMBER(ord.ind_cond_info->''14''->>''value'',''999999999999'') > 1
UNION
SELECT
    --⑳透析液流量
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_NAME''), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''16''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION_AMT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    (SELECT cnt FROM solution_cnt) > 0 
    AND TO_NUMBER(ord.ind_cond_info->''16''->>''value'',''999999999999'') > 1
UNION
SELECT
    --21補液量
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_NAME''), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''20''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_UP_LIQUID''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    TO_NUMBER(ord.ind_cond_info->''20''->>''value'',''999999999999'') > 1
--  AND (SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
    AND ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --24指示受け確認者1
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(@dispUser1Id :: TEXT, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(@checkUser1Name :: TEXT, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF'')|| ''-1'', '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo
    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
UNION
SELECT
    --24指示受け確認者2
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(@dispUser2Id :: TEXT, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(@checkUser2Name :: TEXT, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF'') || ''-2'', '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo
    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
 ) all_cost 
WHERE
     all_cost.e09 IS NOT NULL AND all_cost.e09 <> ''''
 AND all_cost.e01 != '''' AND all_cost.e01 IS NOT NULL
)
,data_middle AS (
SELECT  --抗凝固剤    
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  
    (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE        RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS yakuzai,
        ord.ind_cond_info->''25''->>''medicine_type'' AS medicine_type_yakuzai
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
)
, equip_data as (--医療材料の選択
  select 
    (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    COALESCE( TO_CHAR(TO_NUMBER(eqp ->> ''amount'',''9999999999.999''),''FM0999999.990'') ) AS e04
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(eqp, json_idx)
)
, medi_data as(--薬剤の選択
select 
     (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)

)
, do_medicine_mix_in_orders AS ( --調製薬剤内のソート順
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM (SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'') AS middl
        GROUP BY mix_M_cd)
)
, equip_all_data AS (
SELECT
    --22薬品手技(手技あり薬剤),単体薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01, 
    medi ->> ''no'' as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
    json_idx AS login_ord,
        0 AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
    do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
LEFT OUTER JOIN do_mstmedi_cd ON medi_code = TO_NUMBER(medi ->> ''cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmd.class_cd :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),単体薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01, 
    medi ->> ''no'' as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
    json_idx AS login_ord,
        0 AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
    do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
LEFT OUTER JOIN do_mstmedi_cd ON medi_code = TO_NUMBER(medi ->> ''cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmd.class_cd :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
WHERE
    medi->>''medicine_type'' = ''1'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
UNION
SELECT
    --22薬品手技(手技あり薬剤),調製薬剤
        TRIM(mmd.in_hospital_cd_1) AS e01,
    (medi->>''no'') as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
        json_idx AS login_ord,
        (SELECT login_ord_in_mm FROM do_medicine_mix_in_orders 
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd 
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm) AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
        do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
                    LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
                    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
                    LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
                    LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi ->> ''medicine_type'' = ''2''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),調製薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01,
    (medi->>''no'') as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
        json_idx AS login_ord,
        (SELECT login_ord_in_mm FROM do_medicine_mix_in_orders 
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd 
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm) AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
        do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
        LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
        LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
        LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
WHERE
    medi->>''medicine_type'' = ''2'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
)
, equip_all_over_order AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM equip_all_data
    ORDER BY 
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN ord_medicine_mix ELSE 0 END,
        ord_medicine_mix ) AS mid_data
)
, equip_all_copy AS (
SELECT
    --22薬品手技(手技),単体薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(mp.in_hospital_cd_a1, '''') AS e01, 
    --項目属性
    COALESCE(mp.in_hospital_cd_a2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_PROCEDURE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mp.pricedure_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''1'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''1'' END AS e09,
        ''手技'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤),単体薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01, 
    --項目属性
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(medi ->> ''amount'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, 
    --単位コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    medi ->> ''no''   as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),単体薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01, 
    --項目属性
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(medi->>''amount'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, 
    --単位コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''3'' as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    medi->>''medicine_type'' = ''1'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
UNION
SELECT
    --22薬品手技(手技),調製薬剤
    ''予約詳細'' AS detail_id,  
    --項目コード
    COALESCE(mp.in_hospital_cd_a1, '''') AS e01, 
    --項目属性
    COALESCE(mp.in_hospital_cd_a2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_PROCEDURE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mp.pricedure_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT || ''-''|| ''1'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT || ''-''|| ''1'' END AS e09,
        ''手技'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'' :: TEXT, ''999999999999'' )
    CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''2''
        AND (SELECT ord_medicine_mix FROM equip_all_over_order 
                 WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
                 AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') = 1
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤),調製薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01, 
        --項目属性
        COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
        --項目名称
        COALESCE(mmd.medicine_name, '''') AS e03, 
        --数量
        TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) AS e04, 
        --選択単位フラグ
        CASE 
            WHEN mmd.unit IS NULL OR mmd.unit = '''' THEN ''0'' ELSE ''1'' END AS e05, 
        --単位コード
        COALESCE(mmd.unit, '''') AS e06, 
        --単位名称
        COALESCE(mmd.unit, '''') AS e07,  
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    (medi->>''no'') as sorttag1,
    ''22'' as sorttag2,
    (medi->>''class_cd'') as sorttagclass
FROM
    do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi ->> ''medicine_type'' = ''2''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),調製薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01, 
        --項目属性
        COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
        --項目名称
        COALESCE(mmd.medicine_name, '''') AS e03, 
        --数量
        TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) AS e04, 
        --選択単位フラグ
        CASE 
            WHEN mmd.unit IS NULL OR mmd.unit = '''' THEN ''0'' ELSE ''1'' END AS e05, 
        --単位コード
        COALESCE(mmd.unit, '''') AS e06, 
        --単位名称
        COALESCE(mmd.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    (medi->>''no'') as sorttag1,
        ''33'' as sorttag2,
        (medi->>''class_cd'') as sorttagclass
FROM
    do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    medi->>''medicine_type'' = ''2'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
)
, data_all_copy AS (--と薬剤、の適合
SELECT equip_all_copy.detail_id, equip_all_copy.e01, equip_all_copy.e02, equip_all_copy.e03, equip_all_copy.e04, equip_all_copy.e05, equip_all_copy.e06, equip_all_copy.e07, equip_all_copy.e08, equip_all_copy.e09,sortTag1,sortTag2,sorttagclass, mmd.medicine_cd, mmd.class_cd as mdclass_cd 
FROM equip_all_copy 
    LEFT JOIN mst_medicine mmd ON equip_all_copy.e01 = mmd.in_hospital_cd_1 and equip_all_copy.e03 = mmd.medicine_name
        order by e09
)
, data_all_med as(--薬剤のモジュール
select detail_id,e01,e02,e03,data_all_copy.e04,e05,e06,e07,e08,e09,sortTag1,sortTag2,medicine_cd,
case when sorttag2 = ''22'' or sorttag2 = ''33'' then sorttagclass::text else mdclass_cd::text  end  as mdclass_cd 
             from data_all_copy where e09 > (SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'') or e09::INTEGER < ((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'')::INTEGER + 1)
)
, data_commmon as(--一般のモジュール
select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,''標準''::text as  aa from data_middle_all where e09<>(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')


ORDER BY  e09
)
, data_all_meq as(--医療材料のモジュール
SELECT
    --医療材料情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    COALESCE(TO_CHAR(TO_NUMBER(equip->>''amount'',''9999999.999'') ,''FM0999999.990''), '''') AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2,
		''医療材料''::text as aa,
		equip->>''cd'' as equipment_cd,
		equip->>''class_cd'' as mqclass_cd 
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_equip_info :: json) equip
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    equip->>''equip_type'' = ''0''
)
, order_qcode_F AS (--医療材料の1，2场合
 SELECT DISTINCT ON (item_cd_f)* FROM (
   SELECT
     e01 AS item_cd_f,  
     CASE WHEN ''1'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_qcd_f,
     CASE WHEN ''2'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_code_order :: text, ''999999999999'' ) ELSE NULL END AS meq_cd_f
   FROM
     data_all_meq
     LEFT OUTER JOIN do_mstmeq_cd ON meq_code ::text = data_all_meq.equipment_cd
--      LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code ::text= data_all_meq.mqclass_cd
     LEFT OUTER JOIN mst_equipment ON mst_equipment.equipment_cd ::text = data_all_meq.equipment_cd
     LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code = mst_equipment.class_cd
   ORDER BY item_cd_f asc) AS order_code_middle_QA 
 )
, order_qcode_S AS (--医療材料のない治療条件0场合
   SELECT
     (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
     CASE WHEN ''0'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
         (SELECT COALESCE(TO_CHAR(TO_NUMBER(eqp->> ''amount'',''9999999.999'') ,''FM0999999.990''), '''') FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'', ''FM0999999.990'')) AS amount,
         ROW_NUMBER() OVER() as class_cd,
         ROW_NUMBER() OVER() as equip_cd
   FROM
     do_ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(eqp, json_idx)
   ORDER BY item_cd_s, login_ord_s asc
    )   
, dataequipOrder as(--医療材料の0场合すでにソートされている
        select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,aa,ROW_NUMBER() OVER() as login_ord,class_cd,equip_cd from ( 
    (select ''予約詳細'' as detail_id, order_qcode_S.item_cd_s as e01, data_all_meq.e02, data_all_meq.e03, 
        order_qcode_S.amount as e04, data_all_meq.e05, data_all_meq.e06, data_all_meq.e07, data_all_meq.e08,
        data_all_meq.e09,data_all_meq.sortTag1,data_all_meq.sortTag2,
        data_all_meq.aa,order_qcode_S.login_ord_s,
     class_cd, 
      equip_cd
        from order_qcode_S,data_all_meq where order_qcode_S.item_cd_s = data_all_meq.e01 
        and aa = ''医療材料''
        and order_qcode_S.amount = data_all_meq.e04 order by login_ord_s
     )) as dataequipOrder)
, dataequipOrder1 as(
    select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,aa, 
    dataequipOrder.login_ord,order_qcode_F.class_qcd_f as class_cd,order_qcode_F.meq_cd_f as equip_cd
    from dataequipOrder,order_qcode_F where dataequipOrder.e01 =order_qcode_F.item_cd_f ) 
, equip_order as(
select *, ROW_NUMBER() OVER() as ordnow from (
 (select detail_id::text, e01, e02, e03, e04, e05, e06, e07, e08, e09, sortTag1::text,sortTag2::text,''治医療材料''::text as  aa
  from data_middle_all where e09=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'') and sortTag2 =''18'' 
	order by sorttag1)
	union all
(SELECT detail_id::text, e01, e02, e03, e04, e05, e06, e07, e08, e09, sortTag1::text,sortTag2::text, aa
 FROM dataequipOrder1
 ORDER BY 
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 2 THEN equip_cd END)
)as equip_order
) 
, kou_coag_procedu AS(
    SELECT
    * 
FROM
    ( SELECT 
   ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_ATTR''),'''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_NAME''),'''')  AS e03, 
    --数量
   ''0000000.000'' AS e04, 
    --選択単位フラグ
   ''0'' AS e05, 
    --単位コード
   '''' AS e06, 
    --単位名称
   '''' AS e07, 
    --タグ名称
   -- COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e08, 
      COALESCE(((SELECT VALUE FROM kou_coag_procedur_data)),'''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || ''0''||''-''||''0'' AS e09 ,
   '''' as sorttag1,
   '''' as sorttag2,
     '''' as aa
     FROM kou_coag_procedur_falg
         WHERE ctl = 1 
         AND ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')       
                AND EXISTS(SELECT 1 FROM do_ord_main WHERE  (ind_cond_info->''25''->>''value'' is NOT NULL) AND (ind_cond_info->''25''->>''medicine_type'' = ''2'') )
        ) T
        
        UNION 
    SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
        CASE (select ctl FROM kou_coag_procedur_falg) WHEN 1  THEN COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''') WHEN 2 THEN COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''') ELSE ''''  end AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE 
      WHEN mmd.unit IS NULL OR 
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''
  
    END AS e05, 
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
   COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
   COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') || ''-00-'' ||json_idx AS e09,
    '''' as sorttag1,
    '''' as sorttag2,
        '''' as aa
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) with ordinality as tmp(mmxd, json_idx)
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NULL OR mmd.in_hospital_cd_2 ='''')
            UNION
SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, '''') AS e02, 
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE 
      WHEN mmd.unit IS NULL OR 
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''
  
    END AS e05, 
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
   COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
   COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') || ''-00-'' ||json_idx AS e09,
    '''' as sorttag1,
    '''' as sorttag2,
        '''' as aa
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) with ordinality as tmp(mmxd, json_idx)
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NOT NULL OR mmd.in_hospital_cd_2 <>'''')
        AND ((select ctl FROM kou_coag_procedur_falg) = 1   OR (select ctl FROM kou_coag_procedur_falg) = 2) 
 ),
 combination as(
 --各部分の組み合わせ
    select *,ROW_NUMBER() OVER() as ordnow from  data_commmon
    union all
    select * from equip_order
    union all 
    select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,sortTag1::text,sortTag2::text, aa,ROW_NUMBER() OVER() as ordnow from equip_all_copy
    union all
    select *,ROW_NUMBER() OVER() as ordnow from kou_coag_procedu
        )
        
  SELECT * FROM combination WHERE e01 <>'''' OR e01 is NOT NULL ORDER BY e09,ordnow', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通：透析予約繰り返し部', '2022-11-19 05:34:21.059',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -151, "field_name": "check_user1_name", "replace_var": "@checkUser1Name"}, {"sql_cd": -151, "field_name": "check_user2_name", "replace_var": "@checkUser2Name"}, {"sql_cd": -152, "field_name": "disp_user_1_id", "replace_var": "@dispUser1Id"}, {"sql_cd": -152, "field_name": "disp_user_2_id", "replace_var": "@dispUser2Id"}]');
  INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-150, '
	select * from ((SELECT 
  0 as no,
	COALESCE(check_user1_cd::TEXT, '''') AS check_user1_cd,
	COALESCE(check_user2_cd::TEXT, '''') AS check_user2_cd
FROM
	pat_ind_approve 
WHERE
	ord_no = @ordNo)
union 
(select
 1 as no,
null AS check_user1_cd,
null AS check_user2_cd)) as all_list
order by all_list.no limit 1
', 2, '[{}]', '0', '{"applications": [4]}', NULL, NULL, '2022-11-21 08:08:58.908',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-81, 'WITH dialysis_item_send AS (-- 透析項目送信
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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
 ),
 device AS (
		SELECT device_mode
		FROM mst_treatment mst JOIN 
    (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord	 
		ON ord.rst_treatment_cd = mst.treatment_cd 
),
 fji_com_info AS (-- 富士通共通設定
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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''FJI_COM_INFO'' 
 ),
 dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT'' 
 ),
 conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end		
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
 ),
 conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
 ),
 dialysis_send AS ( -- 透析发送
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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''DIALYSIS_SEND'' 
 ),
 int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。

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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
 ),
 DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
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
	 -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
 ),
 RST_MEDI_INFO AS (-- 透析実績投薬
 SELECT
  medi ->> ''cd'' AS medi_cd 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi 
 ),
 bed_conv as(	 	
	SELECT
	0 AS order_no,
		to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
	 FROM
		mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	 WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
		AND info ->> ''key1'' = ''FJI_COM_INFO'' 
		AND info ->> ''key2'' = ''BED_CODE_CONV'' UNION
	SELECT
		1 AS order_no,
		1 AS bed_conv 
	ORDER BY
		order_no ASC 
		LIMIT 1 
 )
 , dialysis_difficulty_info AS (
 
	SELECT ROW_NUMBER
		( ) OVER ( ) AS row_no,
		details 
	FROM
		( SELECT regexp_split_to_table( @dial_diff_cd, '','' ) AS details ) AS T
 )
SELECT
 all_cost.* 
FROM
 (
  (--  ベッドＮＯ
  SELECT
     ''実績詳細'' AS detail_id,
     ''VE1'' AS sbt_key,
	    CASE (SELECT bed_conv FROM bed_conv)
					WHEN 1 THEN
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_1),1,7)) :: TEXT, 7, ''0'' ) )
					WHEN 2 then 
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_2),1,7)) :: TEXT, 7, ''0'' ) )
					ELSE
						''V9999999'' 
				END AS e01,--項目コード
      COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_ATTR'' ), '''' ) AS e02,-- 項目属性
      COALESCE ( SUBSTRING ( mbd.bed_name, 1, 50 ), '''' ) AS e03,--項目名称
      ''0000000.000'' AS e04,--数量
      ''0'' AS e05,-- 選択単位フラグ
      '''' AS e06,-- 単位コード
      '''' AS e07,-- 単位名称
      '''' AS e08,
      '''' AS e09,
	    '''' AS e10,
       COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_TAG'' ), '''' ) AS e11,-- タグ名称
      ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BED_NO'' ), '''' ) ) AS sortTag 
  FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
   LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd   
   ) UNION
  (--  浄化方法
		SELECT
    ''実績詳細'' AS detail_id, 
		''VC1'' AS sbt_key,
    --項目コード
		CASE
			--患者の入外区分が外来の場合
			WHEN @inOut = ''0''
				THEN COALESCE(mtt.in_hospital_cd_a1, '''')
			--患者の入外区分が入院の場合
			WHEN @inOut = ''1''
				THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
			ELSE ''''
		END AS e01, 
    --項目属性
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(mtt.treatment_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
		'''' AS e08,
    '''' AS e09,
    '''' AS e10,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e11, 
    --出力順
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_TREAT''), '''') AS sortTag
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_treatment mtt
ON
    mtt.treatment_cd = ord.rst_treatment_cd
      ) UNION
  (-- 希望開始時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA6'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        SUBSTRING ( to_char( rst_start_date, ''HH24:MI'' ), 1, 25 ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''03'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_START_DATE_TIME'' ), '''' ) ) AS sortTag 
       FROM
      (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
       ) UNION
       (-- 希望終了時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA7'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_CODE'' ), '''' ) AS e01,--項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''04'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_END_DATE_TIME'' ), '''' ) ) AS sortTag 
       FROM
     (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 予定所要時間
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA8'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date - rst_start_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,--数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''05'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_TAG'' ), '''' ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SCHE_TIME'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 透析前体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF2'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE (  to_char( ( ord.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,--  選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''06'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BEFORE_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 透析後体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF9'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ( ord.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
        ''1'' AS e05,--   選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''07'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_AFTER_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 目標体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF1'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ord.treat_date :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称     
        COALESCE ( to_char( TO_NUMBER(  ord.rst_cond_info -> ''3'' ->> ''value'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''08'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG'' ), '''' ) AS e11,--  タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_TARGET_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- ドライウェイト
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF3'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ord.rst_start_date, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( ord.rst_dw, ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''09'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DRY_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
(--  透析導入日
							 SELECT
						''実績詳細'' AS detail_id,--項目コード
						''VS3'' AS sbt_key,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_CODE'' ), '''' ) AS e01,-- 項目コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_ATTR'' ), '''' ) AS e02,-- 項目属性 
						COALESCE ( to_char( ( patu.iov ->> ''period_start'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称
						''0000000.000'' AS e04,-- 数量
						''0'' AS e05,-- 選択単位フラグ
						'''' AS e06,-- 単位コード
						'''' AS e07,-- 単位名称
						'''' AS e08,
						'''' AS e09,
						'''' AS e10,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_TAG'' ), '''' ) AS e11,--タグ名称
						NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DATE_INTRODUCED'' ), '''' ) AS sortTag 	
					FROM
                                       (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
						LEFT JOIN (
						SELECT
							* 
						FROM
							(
								(
								SELECT
									1 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId
									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NOT NULL 
								) UNION
								(
								SELECT
									2 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId 
									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NULL 
								) 
							) DATA 
						ORDER BY
							DATA.NO,
							DATA.iov ->> ''period_start'' 
							LIMIT 1 
						) AS patu ON patu.pat_id = ord.pat_id 
					WHERE
						 patu IS NOT NULL
       ) UNION
      (-- 障害者加算タイトル
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_CODE'' ),'''') AS e01,--コード
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_ATTR'' ),'''') AS e02,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_NAME'' ),'''') AS e03,--名
        ''0000000.000'' AS e04,
        ''0''AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag  
       WHERE
         (SELECT VALUE FROM dialysis_send WHERE key2 = ''ADD_TITLE_SEND_FLG'' ) = ''1'' 
       ) UNION
       (--  障害者加算:患者基本情報から取得
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE (nullif(mdd.in_hospital_cd_1,'''') ,( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_CODE'' ), '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09, 
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' )||''-''||row_no AS sortTag 
        FROM
        mst_dialysis_difficulty mdd,
				dialysis_difficulty_info
				WHERE
					dialysis_difficulty_cd :: TEXT IN (dialysis_difficulty_info.details)
       )  UNION
       (-- VA
       SELECT
        ''実績詳細'' AS detail_id,
        ''VN1'' AS sbt_key,
        COALESCE ( mva.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mva.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mva.va_name, 1, 25 ), '''' ) AS e03,--項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,--  単位コード
        '''' AS e07,--  単位名称
        '''' AS e08,
        '''' AS e09,
        ''12'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SHUNT_PART'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- 透析器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH1'' AS sbt_key,
        COALESCE ( mdz.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mdz.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mdz.model_number, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--  数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''14'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DIAL_INST'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_dialyzer AS mdz ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- 吸着器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH2'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR'' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,--  項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,--  選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''15'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FILM'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       
       (-- 1次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''16'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FIRST_FILM'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- 2次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( meq.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''17'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SECOND_FILM'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- A針情報
			 SELECT
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''9''->>''value'' IS NOT NULL

       ) UNION ALL 
			 (
			 SELECT
    --V針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''10''->>''value'' IS NOT NULL	 
			 )
	UNION ALL		 
 (-- SN針情報
     SELECT
    --SN針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
       --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''11''->>''value'' IS NOT NULL	 
       ) UNION ALL
(-- 血液回路
      SELECT
    --血液回路情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
      --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''13''->>''value'' IS NOT NULL
       ) UNION ALL
			 (
 SELECT
    --医療材料情報
     ''実績詳細'' AS detail_id, 
		 	''VR1'' AS sbt_key,
     --項目コード
     COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
     --項目属性
     COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
     --項目名称
     COALESCE(meq.equipment_name, '''') AS e03, 
     --数量
     COALESCE(TO_CHAR(TO_NUMBER(equip->>''amount'',''9999999.999'') ,''FM0999999.990''), '''') AS e04, 
     --選択単位フラグ
     CASE WHEN meq.unit IS NULL OR meq.unit = ''''
     THEN ''0'' ELSE ''1'' END AS e05, 
     --単位コード
     COALESCE(meq.unit, '''') AS e06, 
     --単位名称
     COALESCE(meq.unit, '''') AS e07, 
      '''' AS e08,
      '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
     cross join lateral json_array_elements (ord.rst_equip_info :: json) equip

 LEFT OUTER JOIN
     mst_equipment meq
 ON
     meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')  
 LEFT OUTER JOIN
     mst_equipment_class meqc
 ON
     meq.class_cd = meqc.class_cd
 WHERE
     equip->>''equip_type'' = ''0''  		 
			 )UNION
       (-- 透析液
        SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_ATTR'' ), '''' ) ) ) AS e02,--項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
      CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
					 ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999''), ''FM0099999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
					 ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999'') + TO_NUMBER(COALESCE(ord.rst_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0099999.990'')
      ELSE ''0000000.000''
			END AS e04,
        ''1''  AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_TAG'' ), '''' ) ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
      ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
       ) UNION
       (-- 置換液（補液）
       SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_ATTR'' ), '''' ) ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
        to_char( TO_NUMBER( ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999.999'' ), ''FM0000099.990'' ) AS e04,-- 数量
				''1'' e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_TAG'' ), '''' ) ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_REPLACE'' ), '''' ) ) AS sortTag 
       FROM
        (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
         (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
				AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0''
			  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
		    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
	
       ) UNION
       (-- 抗凝固剤初回
       SELECT
        ''実績詳細'' AS detail_id,
        ''VGX'' AS sbt_key,
        ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
        COALESCE (
         ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
         ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR'' ) 
        ) AS e02,-- 項目属性
        COALESCE (
        SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),
    '''' 
   ) AS e03,-- 項目名称
   to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,-- 数量
   (
    COALESCE (
    CASE
      
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN
       ''0'' 
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN
    ''0'' ELSE NULL 
   END,
   ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
    ) 
  ) AS e05,-- 選択単位フラグ
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e06,-- 単位コード
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''24'' AS e10,
  ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG'' ), '''' ) ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_ONESHOT'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
 WHERE
   ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION
 (-- 抗凝固剤持続
 
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGY'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ATTR'' ) 
  ) AS e02,-- 項目属性
  COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''') AS e03,-- 項目名称
 to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''27'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,--e4
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0'' 
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
 ) 
 ) AS e05,-- 選択単位フラグ
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN '''' 
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e06,-- 単位コード
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''''
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''25'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION
 (-- 抗凝固剤TOTAL
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGZ'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR'' ) 
  ) AS e2,-- 項目属性,
    COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''')  AS e03,-- 項目名称
 to_char(
  TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ) + TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''28'' ->> ''value'', ''0'' ), ''999999999.999'' ),
  ''FM0999999.990'' 
 ) AS e04,-- 選択単位フラグ
 (
  COALESCE (
  CASE 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0''  
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) ) 
 ) AS e05,-- 選択単位フラグ
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e06,-- 単位コード
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''26'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_TOTAL'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0''

 ) UNION
(--  血液流量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VK3'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_NAME'' ), '''' ) AS e03,-- 項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e07,-- 単位コード
  '''' AS e08,
  '''' AS e09,
  ''27'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BLOOD_AMT'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 WHERE
 TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ) > 1 
  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 

 )UNION(-- 透析液流量
  SELECT
  ''実績詳細'' AS detail_id,
  ''VK4'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR'' ), '''' ) AS e02,--e2
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_NAME'' ), '''' ) AS e03,--e3
  to_char( TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,--e4
  ''1'' AS e05,--e5
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e06,--e6
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_TAG'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION_AMT'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 WHERE
  TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ) >= 1 
 )
 union
 (-- 補液量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VS2'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_CODE'' ), '''' ) AS e01,--項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_ATTR'' ), '''' ) AS e02,--項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_NAME'' ), '''' ) AS e03,--項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ), ''FM0000099.990'' ) AS e04,--数量
  ''1'' AS e05,-- 選択単位フラグ
	COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e06,--単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e07,--単位名称
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_UP_LIQUID'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 WHERE
 TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ) > 1 
  AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
  AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') in (''0'',''1'',''2'') 
  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
  OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
  
 ) UNION
(-- 薬品手技7606
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO1'' AS sbt_key,
  COALESCE ( mp.in_hospital_cd_a1, '''' ) AS e01,-- 項目コード
 COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' ) AS e02,-- 項目属性
  COALESCE ( mp.pricedure_name, '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,-- 数量
  ''0'' AS e05,-- 選択単位フラグ
  '''' AS e06,-- 単位コード
  '''' AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' ) AS e11,-- タグ名称
--   NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'' ), '''' ) AS sortTag 
COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''1'' AS sortTag
 FROM
  (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo ORDER BY del_date desc limit 1) ord	
	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
 WHERE
 medi ->> ''procedure_cd'' IS NOT NULL
 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != ''''

 ) UNION
 (--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''2'' AS sortTag
  FROM
  (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo ORDER BY del_date desc limit 1) ord	
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
     medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''3'' AS sortTag
  FROM
  (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo ORDER BY del_date desc limit 1) ord	
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )  

 UNION
 (--  実施コメンSOAP ト A
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC7'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_A'' ), '''' ) AS e02,
  ''A'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_A'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト O
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC6'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_O'' ), '''' ) AS e02,
  ''O'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_O'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト P
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC8'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_P'' ), '''' ) AS e02,
  ''P'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_P'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト S
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC5'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_S'' ), '''' ) AS e02,
  ''S'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_S'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
(-- 酸素吸入手技
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_NAME'' ), '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,-- 数量
  ''0'' AS e05,-- 選択単位フラグ
  '''' AS e06,-- 単位コード
  '''' AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_ATTR'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 
  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_FLAG'' ) = ''1'' 
	AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 

 ) 
UNION

 (-- 酸素吸入
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_NAME'' ), '''' ) AS e03,-- 項目名称
  COALESCE ( to_char( TO_NUMBER( oxy ->> ''amount'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 

  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 

 ) UNION
 (-- レセプトメモ
 SELECT
  ''実績詳細'' AS detail_id,
  '''' AS sbt_key,
  COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
  COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_ATTR'' ), '''' ) AS e02,
  COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  ''33'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_RECORD'' ), '''' ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
  LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' )
  CROSS JOIN LATERAL json_array_elements ( mad.addition_tar_cd :: json ) addtr
  LEFT OUTER JOIN mst_dialysis_difficulty AS mdd ON mdd.dialysis_difficulty_cd = to_number( addtr ->> ''cd'', ''9999999999'' ) 
 WHERE
  mad.addition_cond = ''2'' 
  AND addi ->> ''is_enable'' = ''1'' 
  AND mad.addition_class = ''2'' 
 
  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) IS NOT NULL 
  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) <> ''0'' 

 )  UNION
 (-- 加算・管理料
 SELECT
  ''実績詳細'' AS detail_id,
  ''VAB'' AS sbt_key,
  COALESCE ( adt.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
	COALESCE ( adt.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_ATTR'' ) ) AS e02,-- 項目属性
  COALESCE ( SUBSTRING ( adt.addition_name, 1, 25 ), '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  '''' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
	CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
	LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
 WHERE
  addition ->> ''is_enable'' = ''1''

 ) 
 ) all_cost 
WHERE
  all_cost.sortTag IS NOT NULL and
  all_cost.e01 IS NOT NULL AND all_cost.e01 <> ''''
order by all_cost.sortTag,all_cost.sbt_key
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）項目情報部', '2022-08-31 05:57:49.586',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -79, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-800010, 'WITH bed_code_info AS (SELECT 0                                                            AS order_no
                            , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS bed_code_kbn
                       FROM mst_coop_ini AS ini
                                CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
                       WHERE facility_cd = @facilityCd
                         AND is_del = ''0''
                         -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
                         AND COALESCE(info->>''key0'','''') = @key0
                         -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
                         AND info ->> ''key1'' = ''FJI_COM_INFO''
                         AND info ->> ''key2'' = ''BED_CODE_CONV''
                       UNION
                       SELECT 1  AS order_no
                            , '''' AS bed_code_kbn
                       ORDER BY order_no ASC
                       LIMIT 1)
											 
							( SELECT CASE
           WHEN ((ord.ind_kur_cd IS NOT NULL AND ord.ind_kur_cd != 0) AND
                 (ord.ind_bed_cd IS NULL OR ord.ind_bed_cd = 0)) THEN ''V9999999''
           ELSE
               CASE
                   WHEN (SELECT bed_code_kbn FROM bed_code_info) = ''1''
                       THEN mb.in_hospital_cd_1
                   WHEN (SELECT bed_code_kbn from bed_code_info) = ''2''
                       THEN mb.in_hospital_cd_2
                   ELSE ''V9999999''
                   END
           END AS in_hospital_cd
FROM ord_main ord
         LEFT OUTER JOIN
     mst_bed mb
     ON ord.ind_bed_cd = mb.bed_cd
WHERE ord.ord_no = @ordNo
  AND ord.facility_cd = @facilityCd
  AND ord.is_del = ''0'')
 union 
 
(SELECT CASE
           WHEN ((ord.ind_kur_cd IS NOT NULL AND ord.ind_kur_cd != 0) AND
                 (ord.ind_bed_cd IS NULL OR ord.ind_bed_cd = 0)) THEN ''V9999999''
           ELSE
               CASE
                   WHEN (SELECT bed_code_kbn FROM bed_code_info) = ''1''
                       THEN mb.in_hospital_cd_1
                   WHEN (SELECT bed_code_kbn from bed_code_info) = ''2''
                       THEN mb.in_hospital_cd_2
                   ELSE ''V9999999''
                   END
           END AS in_hospital_cd
FROM ord_main_restore ord
         LEFT OUTER JOIN
     mst_bed mb
     ON ord.ind_bed_cd = mb.bed_cd
WHERE ord.ord_no = @ordNo
  AND ord.facility_cd = @facilityCd
  AND ord.is_del = ''0''
	AND (select count(1) from ord_main where ord_no = @ordNo)=''0''
order by del_date desc
limit 1)', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：予約枠コード取得', '2022-10-25 05:43:36.161', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-53, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
, start_time_info AS (
SELECT
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS treat_time
FROM 
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
	union 
(SELECT
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS treat_time
FROM 
  ord_main_restore ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
and (select count(1) from ord_main where ord_no = @ordNo)=''0''
order by ord.del_date desc limit 1)
)
SELECT
  ord.treat_date AS start_date,
  (SELECT start_time FROM start_time_info) AS start_time,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''YYYYMMDD'') AS end_date,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''HH24MISS'') AS end_time
FROM 
  ord_main ord
WHERE
  ord.ord_no = @ordNo
union
(SELECT
  ord.treat_date AS start_date,
  (SELECT start_time FROM start_time_info) AS start_time,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''YYYYMMDD'') AS end_date,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''HH24MISS'') AS end_time
FROM 
  ord_main_restore ord
WHERE
  ord.ord_no = @ordNo
	and (select count(1) from ord_main where ord_no = @ordNo)=''0''
order by del_date desc limit 1)
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：予約時間取得', '2022-02-23 16:10:41.424',CURRENT_TIMESTAMP, NULL);


