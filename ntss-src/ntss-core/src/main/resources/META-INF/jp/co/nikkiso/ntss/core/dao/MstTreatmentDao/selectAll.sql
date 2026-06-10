--治療方法
  select
      --/*%expand "A" */*
      A.treatment_cd
,A.facility_cd
,A.fn_treatment_cd
,A.treatment_name
,A.device_mode
,A.report_id
,A.report_id_hw
,A.report_id_bw
,A.report_id_aw
,A.report_id_dev
,A.graph_time_scale
,A.treatment_condition_setting
,A.monitor_data_item_print
,A.monitor_data_item_screen
,A.is_disp
,A.is_del
,A.reg_date
,A.up_date
,A.in_hosp_a_startdate
,A.in_hospital_cd_a1
,A.in_hospital_cd_a2
,A.in_hospital_cd_a3
,A.in_hospital_cd_a4
,A.in_hosp_b_startdate
,A.in_hospital_cd_b1
,A.in_hospital_cd_b2
,A.in_hospital_cd_b3
,A.in_hospital_cd_b4
,A.report_graph_setting
,A.report_id_act
  from
    mst_treatment A   --テーブル名
         ,(
                 select
                         mss.facility_cd, ms.*, row_number() over() as index
                 from
                         mst_selector mss
                 cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
                 (
                         code bigint,
                         name text
                 )
                 where
    /*%if params.facilityCd != null */
                         facility_cd = /* params.facilityCd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_treatment' --テーブル名
         ) ms
      where
             A.facility_cd = ms.facility_cd
       and
             A.treatment_cd = ms.code --コードのカラム
       and
             A.is_del = '0'
       and
             A.is_disp = '1'
       order by
             ms.index
;
