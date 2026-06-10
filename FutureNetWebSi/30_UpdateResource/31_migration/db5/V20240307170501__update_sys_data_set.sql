delete from ntss.sys_data_set where sql_cd = '-195';
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
