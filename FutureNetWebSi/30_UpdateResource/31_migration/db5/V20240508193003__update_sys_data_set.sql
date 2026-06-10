DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-109);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-109, 'with ord_maincopy_do as (SELECT ord_no,
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
                                rst_weight_info,
                                rst_complaint_info,
                                rst_treatment_info,
                                rst_treat_staff_info,
                                rst_rounds_info,
                                is_del,
                                up_date,
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
                         from ord_main ord
                         where ord.ord_no = @ordNo
                           and ord.rst_treatment_cd is not null
                         union
                         SELECT 
                                --mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240226 start
                                ord_no,
                                del_date,
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
                                rst_weight_info,
                                rst_complaint_info,
                                rst_treatment_info,
                                rst_treat_staff_info,
                                rst_rounds_info,
                                is_del,
                                up_date,
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
                                --mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240226 end
                         FROM ord_main_restore AS ord
                         WHERE ord.ord_no = @ordNo
                           and (select count(1)
                                from ord_main ord
                                where ord.ord_no = @ordNo and ord.rst_treatment_cd is not null) = ''0''
                         order by del_date desc
                         limit 1),

     ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id'' AS staff_cd FROM ord_maincopy_do ord),
     mst_user_authenticator
         as (select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json) ->> (select (
                                                                                                         case
                                                                                                             when 1 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Mon''
                                                                                                             when 2 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Tues''
                                                                                                             when 3 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Wednes''
                                                                                                             when 4 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Thurs''
                                                                                                             when 5 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Fri''
                                                                                                             when 6 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Satur''
                                                                                                             when 7 = (select treat_week from ord_maincopy_do)
                                                                                                                 then ''Sun''
                                                                                                             END) as aaa))::json ->>
                    ''disp_user_id'' as staff_cd
             from ord_maincopy_do ord,
                  mst_kur mst
             where ord.rst_kur_cd = mst.kur_cd),
     ini_key as (SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
                 FROM mst_coop_ini AS ini
                          CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                 WHERE facility_cd = @facilityCd

                   AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
                   AND COALESCE(info ->> ''key0'', '''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
                   AND info ->> ''key1'' = ''DIALYSISSEND''
                   AND info ->> ''key2'' = ''DOCTOR_TYPE'')
select staff_cd, code
from ((SELECT charge_staff ->> ''staff_cd'' AS staff_cd,
              0                           as code
       FROM pat_main AS pm,
            jsonb_array_elements(pm.charge_staff_info) as charge_staff
       WHERE pm.pat_id = @patId

         AND charge_staff ->> ''is_main'' = ''1''
         and ''1'' = (select * from ini_key)
       order by charge_staff ->> ''is_main'' asc
       LIMIT 1)
      UNION
      SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd,
             1                                                            as code
      FROM mst_coop_ini AS ini
               CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
      WHERE facility_cd = @facilityCd

        AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''DOCTOR_DEF''
        and ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')
                   FROM pat_main AS pm,
                        jsonb_array_elements(pm.charge_staff_info) as charge_staff
                   WHERE pm.pat_id = @patId

                     AND charge_staff ->> ''is_main'' = ''1'')
        AND ''1'' = (select * from ini_key)
      UNION
      select staff_cd, 0 as code
      from ind_user_id
      where ''0'' = (select * from ini_key)
      union

      select (case
                  when (((select staff_cd from mst_user_authenticator) is NULL OR
                         (select staff_cd from mst_user_authenticator) = ''''
                      OR (select staff_cd from mst_user_authenticator) = ''0'') and
                        ''2'' = (select * from ini_key))
                      THEN (SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
                            FROM mst_coop_ini AS ini
                                     CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
                            WHERE facility_cd = @facilityCd
                              AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
                              AND COALESCE(info ->> ''key0'', '''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
                              AND info ->> ''key1'' = ''DIALYSISSEND''
                              AND info ->> ''key2'' = ''DOCTOR_DEF'')
                  when ((select staff_cd from mst_user_authenticator) is not NULL and
                        (select staff_cd from mst_user_authenticator) != ''''
                      and (select staff_cd from mst_user_authenticator) != ''0'' and
                        ''2'' = (select * from ini_key)) then
                          (select staff_cd from mst_user_authenticator)
          end) as staff_cd,
             1 as code) Alldoctor
where Alldoctor.staff_cd is not null
        
 		
	', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '(受信用)日機装)連携設定:医師コード', '2022-06-09 17:05:03.000', CURRENT_TIMESTAMP, NULL);
