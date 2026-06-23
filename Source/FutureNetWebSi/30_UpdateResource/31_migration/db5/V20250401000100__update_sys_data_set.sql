DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 133;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (133, 'WITH b AS (
select ord_main.* from ord_main
     where facility_cd = @facilityCd
 and rst_dialysis_state between ''1'' and ''5''
     and
       pat_id is not null
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate
 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate
 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
     and
       is_del = ''0''
             and pat_id = @patId
), d AS (
    select
      DISTINCT ON (ord_no, data_type)
      b.ord_no
    , data_type
    , bio_moni_ctl_no
    , occur_date
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
        where mni_monitor.facility_cd = @facilityCd
    order by ord_no, data_type, occur_date desc
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    , to_number(mni_monitor.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
), h as (select machine_no,b.ord_no,mst_bed.bed_cd from mst_bed INNER JOIN b on b.rst_bed_cd = mst_bed.bed_cd 
), BpBefore AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 5
), BpCurrent AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 2
), BpAfter AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 6
), Vital AS (
    select DISTINCT ON (mni_monitor.ord_no) 
      mni_monitor.ord_no, 
      mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type in (2, 4, 5, 6)
    order by mni_monitor.ord_no,mni_monitor.occur_date desc
),j as(
    select pat_event.pat_id, count(*) as observation_records_num 
        from  pat_event INNER JOIN b on (pat_event.pat_id = b.pat_id) AND (pat_event.ord_no = b.ord_no)
        WHERE pat_event.ord_no > 0 AND pat_event.facility_cd <> ''null'' AND pat_event.use_type = 2 AND  pat_event.event_status = ''1'' AND pat_event.is_newest = ''1'' AND pat_event.is_del = ''0''
        GROUP BY pat_event.pat_id
)
,k as (select h.ord_no, machine_status as machine_status , machine_serial from mnt_machine_state INNER JOIN h on mnt_machine_state.bed_cd = h.bed_cd)
,q as (
   select
     e.ord_no,
     to_number(mnt_machine_state.monitor_data::json->>''1'', ''9999'') AS 経過時間,
     to_number(mnt_machine_state.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了,
     to_number(mnt_machine_state.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了,
     to_number(mnt_machine_state.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
     from e
     inner join mnt_machine_state on
     e.facility_cd = mnt_machine_state.facility_cd and
     e.machine_type_cd = mnt_machine_state.machine_type_cd and
     e.machine_serial = mnt_machine_state.machine_serial and
     e.ord_no = mnt_machine_state.ord_no and
     e.pat_id = mnt_machine_state.pat_id
), f AS (
    select q.*
        , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_除水完了,0) AS 予測時間_除水
        , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_透析完了,0) AS 予測時間_透析
        , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_補液完了,0) AS 予測時間_補液 
    from q
)
,p as (select com_format_cd,com_type,h.ord_no from mst_machine INNER JOIN h on h.machine_no = mst_machine.machine_no)
,l as (select pat_ind_approve.ord_no, pat_ind_approve.is_content_changed_for_map as is_content_changed_for_map from pat_ind_approve INNER JOIN b on pat_ind_approve.ord_no = b.ord_no)
,m as (select a2.ord_no,concat(effect,''/'',effect_count) as dosing_status
from
(
select b.ord_no,
count(1) as effect
from b,jsonb_array_elements(b.rst_medi_info) as a1
where a1->''effect_flg''=''"1"''
GROUP BY b.ord_no
) as b2,
(
select b.ord_no,
count(1) as effect_count
from b,jsonb_array_elements(b.rst_medi_info) as a1
  GROUP BY b.ord_no
) as a2 where a2.ord_no=b2.ord_no
)
,n as  (
 select b.ord_no,
case when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''1'' then
((rst_weight_info->''recrcl_rt'') -> ''1'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''2'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''3'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''4'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''5'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
else ''0'' end  as rate
 from b
 )
 ,o as (
 select b.ord_no,
max(info ->> ''treat_cd'')|| ''　'' || max(info ->> ''treat_name'')  AS treatment
 from b
   CROSS JOIN LATERAL json_array_elements(b.rst_treatment_info ::json) info
 GROUP BY b.ord_no
 )
 ,bed_group as (
 SELECT
        index_no AS bed_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_group_code,
        order_cd ->> ''name'' AS bed_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''mst_room_bed_group''
 )
  ,bed as (
 SELECT
        index_no AS bed_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
        order_cd ->> ''name'' AS bed_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''mst_bed''
 )
,kur as (
 SELECT
        index_no AS kur_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS kur_code,
        order_cd ->> ''name'' AS kur_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''mst_kur''
 )
 ,patgrou as (
 SELECT
        index_no AS pat_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS pat_group_code,
        order_cd ->> ''name'' AS pat_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''pat_group''
 )
 ,mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 )
select 
  DISTINCT ON (b.ord_no)
  b.ord_no
, b.treat_date
, b.pat_id AS pat_id
, b.pat_id AS pat_id1
, b.pat_id AS pat_id2
, b.pat_id AS pat_id3
, b.pat_id AS pat_id4
, b.pat_id AS pat_id5
, MIN(patgrou.pat_group_order) AS pat_group_order
, pt.is_infect
, b.pat_id AS pat_name
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw as DW
, CASE mnt_machine_state.process_state WHEN ''01'' THEN ''プリセット''
                                       WHEN ''02'' THEN ''洗浄''
                                       WHEN ''03'' THEN ''酸洗''
                                       WHEN ''04'' THEN ''消毒''
                                       WHEN ''05'' THEN ''滞留''
                                       WHEN ''06'' THEN ''液置換''
                                       WHEN ''07'' THEN ''準備回収''
                                       WHEN ''08'' THEN ''ガスパージ''
                                       WHEN ''09'' THEN ''排液''
                                       WHEN ''10'' THEN ''停止''
                                       WHEN ''11'' THEN ''運転''
                                       WHEN ''99'' THEN ''通信異常、電源OFF、異常''
                                       ELSE mnt_machine_state.process_state
  END
, b.rst_cond_info::json#>>''{3, value}'' AS target_weight
, CASE WHEN b.rst_cond_info::json#>>''{3, value}'' is not null AND b.rst_cond_info::json#>>''{3, value}'' <> ''null'' THEN CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) 
  ELSE CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - b.rst_dw 
  END AS target_weight_2
, b.rst_start_date
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
  END AS forecast_end_water_removal_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS forecast_end_dialysis_end
, b.rst_end_date
, b.rst_cond_info#>>''{1, value}'' AS treatment_minute
, b.rst_cond_info#>>''{1, value}'' AS treatment_time
, CASE WHEN b.rst_dialysis_state <> ''3'' THEN 0
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN f.予測時間_除水 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN f.予測時間_透析 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
       ELSE COALESCE(f.予測時間_補液,0) - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
  END AS delay_time
, CASE WHEN b.rst_dialysis_state < ''4'' THEN 
          GREATEST(CASE WHEN COALESCE(f.残り時間_除水完了,0) > COALESCE(f.残り時間_透析完了,0) AND COALESCE(f.残り時間_除水完了,0) > COALESCE(f.残り時間_補液完了,0) THEN f.残り時間_除水完了
                        WHEN COALESCE(f.残り時間_透析完了,0) > COALESCE(f.残り時間_補液完了,0) THEN f.残り時間_透析完了
                        ELSE f.残り時間_補液完了
                        END,0)
     ELSE GREATEST(CASE WHEN COALESCE(e.残り時間_除水完了,0) > COALESCE(e.残り時間_透析完了,0) AND COALESCE(e.残り時間_除水完了,0) > COALESCE(e.残り時間_補液完了,0) THEN e.残り時間_除水完了
                        WHEN COALESCE(e.残り時間_透析完了,0) > COALESCE(e.残り時間_補液完了,0) THEN e.残り時間_透析完了
                        ELSE e.残り時間_補液完了
                        END,0)
     END as remaining_time
 ,CASE WHEN b.rst_dialysis_state < ''3'' THEN 0
       WHEN b.rst_cond_info::json#>>''{1, value}'' is null or b.rst_cond_info::json#>>''{1, value}'' = ''0'' THEN null
       WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is null THEN FLOOR(cast((round(extract(epoch from now() - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is not null THEN FLOOR(cast((round(extract(epoch from CAST(b.rst_end_date AS TIMESTAMP) - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN d.data_type = 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(q.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)
             WHEN d.data_type <> 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(e.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)  
             END AS progress_rate 
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->>''90'' AS bpbefore_max
, BpBefore.monitor_data->>''91'' AS bpbefore_min
, BpBefore.monitor_data->>''92'' AS bpbefore_avg
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS bpbefore
, BpBefore.monitor_data->>''93'' AS pulse_before
, (BpCurrent.monitor_data->>''90'') || ''/ '' || (BpCurrent.monitor_data->>''91'') || ''/ '' || (BpCurrent.monitor_data->>''92'') || '' ('' || (BpCurrent.monitor_data->>''93'') || '')'' AS bpcurrent
, b.rst_charge_user_info->>''user_id_1'' AS charge_user_id_1
, b.rst_charge_user_info->>''date_1'' AS charge_date_1
, b.rst_charge_user_info->>''user_id_2'' AS charge_user_id_2
, b.rst_charge_user_info->>''date_2'' AS charge_date_2
, b.rst_puncture_user_info->>''date'' AS puncture_date
, b.rst_puncture_user_info->>''user_id_1'' AS puncture_user_id_1
, b.rst_puncture_user_info->>''date_1'' AS puncture_date_1
, b.rst_puncture_user_info->>''user_id_2'' AS puncture_user_id_2
, b.rst_puncture_user_info->>''date_2'' AS puncture_date_2
, b.rst_return_user_info->>''date'' AS return_date
, b.rst_return_user_info->>''user_id_1'' AS return_user_id_1
, b.rst_return_user_info->>''date_1'' AS return_date_1
, b.rst_return_user_info->>''user_id_2'' AS return_user_id_2
, b.rst_return_user_info->>''date_2'' AS return_date_2
, b.rst_weight_info->>''weight_after'' AS weight_after
, to_number(b.rst_weight_info::json->>''weight_before'', ''999.99'') - to_number(b.rst_weight_info::json->>''weight_after'', ''999.99'') AS weight_diff
, BpAfter.monitor_data->>''90'' AS bpafter_max
, BpAfter.monitor_data->>''91'' AS bpafter_min
, BpAfter.monitor_data->>''92'' AS bpafter_avg
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS bpafter
, BpAfter.monitor_data->>''93'' AS pulse_after
, Vital.monitor_data->>''-2'' AS SpO2
, Vital.monitor_data->>''-1'' AS blood_glucose_level
, Vital.monitor_data->>''90'' AS bp_high
, Vital.monitor_data->>''91'' AS bp_low
, Vital.monitor_data->>''92'' AS bp_ave
, Vital.monitor_data->>''93'' AS pulse
, Vital.monitor_data->>''94'' AS body_temperature
, b.rst_weight_info->>''water_removal_target'' AS water_removal_target
, CASE WHEN b.rst_dialysis_state < ''2'' THEN null
       ELSE ''済''
  END AS pat_confirm
, b.rst_weight_info->>''weight_before_date'' AS weight_before_date
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS plan_end
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未''
       ELSE ''済''
  END AS rounds_status
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未回診''
       ELSE b.rst_rounds_info->>''round_type_name''
  END AS rounds_data
, b.rst_weight_info->>''ctr'' AS ctr
, b.rst_cond_info#>>''{2, value_name_1}'' AS va
, b.rst_cond_info#>>''{4, value}'' AS water_removal_limit
, (b.rst_cond_info#>>''{5, value_name_2}'') || ''['' || (b.rst_cond_info#>>''{5, value_name_1}'') || '']'' AS dialyzer
, b.rst_cond_info#>>''{6, value_name_1}'' AS adsorption_column
, b.rst_cond_info#>>''{7, value_name_1}'' AS primary_membrane
, b.rst_cond_info#>>''{8, value_name_1}'' AS Second_membrane
, b.rst_cond_info#>>''{9, value_name_1}'' AS needles_a
, b.rst_cond_info#>>''{10, value_name_1}'' AS needles_v
, b.rst_cond_info#>>''{11, value_name_1}'' AS needles_sn
, CASE WHEN b.rst_cond_info#>>''{12, value}'' IS NULL THEN NULL
       WHEN b.rst_cond_info#>>''{12, value}'' = ''0'' THEN ''使用しない''
       ELSE ''使用する''
  END AS single_needle_use
, b.rst_cond_info#>>''{13, value_name_1}'' AS blood_circuit
, b.rst_cond_info#>>''{14, value}'' AS blood_flow
, b.rst_cond_info#>>''{15, value_name_1}'' AS dialysate
, b.rst_cond_info#>>''{16, value}'' AS dialysate_flow
, b.rst_cond_info#>>''{17, value}'' AS dialysate_volume
, to_char(CAST(b.rst_cond_info#>>''{18, value}'' AS DECIMAL), ''FM999.0'') AS dialysate_temperature
, b.rst_cond_info#>>''{19, value_name_1}'' AS fluid_replenishment
, b.rst_cond_info#>>''{20, value}'' AS fr_volume
, CASE b.rst_cond_info#>>''{21, value}'' WHEN ''0'' THEN ''後補液''
                                       WHEN ''1'' THEN ''前補液''
                                       ELSE NULL
  END AS fr_selection
, b.rst_cond_info#>>''{22, value}'' AS fr_use_num
, to_char(CAST(b.rst_cond_info#>>''{23, value}'' AS DECIMAL), ''FM990.0'') AS fr_temperature
, b.rst_cond_info#>>''{24, value}'' AS fr_velocity
, b.rst_cond_info#>>''{25, value_name_1}'' AS anticoagulants
, b.rst_cond_info#>>''{26, value}'' AS anticoagulants_oneshot_quantity
, b.rst_cond_info#>>''{27, value}'' AS anticoagulants_duration_rate
, b.rst_cond_info#>>''{28, value}'' AS anticoagulants_total_volume
-- , CASE WHEN b.rst_cond_info#>>''{29, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{29, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS ip_usage_selection
, b.rst_cond_info#>>''{29, value}'' AS ip_usage_selection
-- , null AS ip_start
-- , CASE b.rst_cond_info#>>''{30, value}'' WHEN ''0'' THEN ''手動''
--                                        WHEN ''1'' THEN ''自動''
--                                        ELSE NULL
--   END AS ip_start
, b.rst_cond_info#>>''{30, value}'' AS ip_start
-- , to_char(to_number(b.rst_cond_info#>>''{31, value}'', ''999.99''), ''FM990.0'') AS ip_oneshot_quantity
-- , to_char(to_number(b.rst_cond_info#>>''{32, value}'', ''999.99''), ''FM990.0'') AS ip_velocity
-- , to_char(to_number(b.rst_cond_info#>>''{33, value}'', ''999.99''), ''FM990.0'') AS ip_velocity_max
, CAST(b.rst_cond_info#>>''{31, value}'' AS DECIMAL) AS ip_oneshot_quantity
, CAST(b.rst_cond_info#>>''{32, value}'' AS DECIMAL) AS ip_velocity
, CAST(b.rst_cond_info#>>''{33, value}'' AS DECIMAL) AS ip_velocity_max
-- , CASE WHEN b.rst_cond_info#>>''{34, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{34, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS auto_oneshot
, b.rst_cond_info#>>''{34, value}'' AS auto_oneshot
-- , CASE b.rst_cond_info#>>''{35, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_auto_off
, b.rst_cond_info#>>''{35, value}'' AS ip_auto_off
, b.rst_cond_info#>>''{36, value}'' AS ip_auto_cycle_time
-- , CASE b.rst_cond_info#>>''{37, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{37, value}'' AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{38, value}'' AS ip_power_ok_monitor_off_time
, e.monitor_data->>''0'' AS m000
, e.monitor_data->>''1'' AS m001
, e.monitor_data->>''2'' AS m002
, e.monitor_data->>''3'' AS m003
, e.monitor_data->>''4'' AS m004
, e.monitor_data->>''5'' AS m005
, e.monitor_data->>''6'' AS m006
, e.monitor_data->>''7'' AS m007
, e.monitor_data->>''8'' AS m008
, e.monitor_data->>''9'' AS m009
, e.monitor_data->>''10'' AS m010
, e.monitor_data->>''11'' AS m011
, e.monitor_data->>''12'' AS m012
, e.monitor_data->>''13'' AS m013
, e.monitor_data->>''14'' AS m014
, e.monitor_data->>''15'' AS m015
, e.monitor_data->>''16'' AS m016
, e.monitor_data->>''17'' AS m017
, e.monitor_data->>''18'' AS m018
, e.monitor_data->>''19'' AS m019
, e.monitor_data->>''20'' AS m020
, e.monitor_data->>''21'' AS m021
, e.monitor_data->>''22'' AS m022
, e.monitor_data->>''23'' AS m023
, e.monitor_data->>''24'' AS m024
, e.monitor_data->>''25'' AS m025
, e.monitor_data->>''26'' AS m026
, e.monitor_data->>''27'' AS m027
, e.monitor_data->>''28'' AS m028
, e.monitor_data->>''29'' AS m029
, e.monitor_data->>''30'' AS m030
, e.monitor_data->>''31'' AS m031
, e.monitor_data->>''32'' AS m032
, e.monitor_data->>''33'' AS m033
, e.monitor_data->>''34'' AS m034
, e.monitor_data->>''35'' AS m035
, e.monitor_data->>''36'' AS m036
, e.monitor_data->>''37'' AS m037
, e.monitor_data->>''38'' AS m038
, e.monitor_data->>''39'' AS m039
, e.monitor_data->>''40'' AS m040
, e.monitor_data->>''41'' AS m041
, e.monitor_data->>''42'' AS m042
, e.monitor_data->>''43'' AS m043
, e.monitor_data->>''44'' AS m044
, e.monitor_data->>''45'' AS m045
, e.monitor_data->>''46'' AS m046
, e.monitor_data->>''47'' AS m047
, e.monitor_data->>''48'' AS m048
, e.monitor_data->>''49'' AS m049
, e.monitor_data->>''50'' AS m050
, e.monitor_data->>''51'' AS m051
, e.monitor_data->>''52'' AS m052
, e.monitor_data->>''53'' AS m053
, e.monitor_data->>''54'' AS m054
, e.monitor_data->>''55'' AS m055
, e.monitor_data->>''56'' AS m056
, e.monitor_data->>''57'' AS m057
, e.monitor_data->>''58'' AS m058
, e.monitor_data->>''59'' AS m059
, e.monitor_data->>''60'' AS m060
, e.monitor_data->>''61'' AS m061
, e.monitor_data->>''62'' AS m062
, e.monitor_data->>''63'' AS m063
, e.monitor_data->>''64'' AS m064
, e.monitor_data->>''65'' AS m065
, e.monitor_data->>''66'' AS m066
, e.monitor_data->>''67'' AS m067
, e.monitor_data->>''68'' AS m068
, e.monitor_data->>''69'' AS m069
, e.monitor_data->>''70'' AS m070
, e.monitor_data->>''71'' AS m071
, e.monitor_data->>''72'' AS m072
, e.monitor_data->>''73'' AS m073
, e.monitor_data->>''74'' AS m074
, e.monitor_data->>''75'' AS m075
, e.monitor_data->>''76'' AS m076
, e.monitor_data->>''77'' AS m077
, e.monitor_data->>''78'' AS m078
, e.monitor_data->>''79'' AS m079
, e.monitor_data->>''80'' AS m080
, e.monitor_data->>''81'' AS m081
, e.monitor_data->>''82'' AS m082
, e.monitor_data->>''83'' AS m083
, e.monitor_data->>''84'' AS m084
, e.monitor_data->>''85'' AS m085
, e.monitor_data->>''86'' AS m086
, e.monitor_data->>''87'' AS m087
, e.monitor_data->>''88'' AS m088
, e.monitor_data->>''89'' AS m089
, e.monitor_data->>''95'' AS m095
, e.monitor_data->>''96'' AS m096
, e.monitor_data->>''97'' AS m097
, e.monitor_data->>''98'' AS m098
, e.monitor_data->>''100'' AS m100
, e.monitor_data->>''101'' AS m101
, e.monitor_data->>''102'' AS m102
, e.monitor_data->>''103'' AS m103
, e.monitor_data->>''Z11'' AS mz11
, e.monitor_data->>''Z21'' AS mz21
, e.monitor_data->>''Z31'' AS mz31
, e.monitor_data->>''Z41'' AS mz41
, e.monitor_data->>''Z51'' AS mz51
, e.monitor_data->>''Z61'' AS mz61
, e.monitor_data->>''Z71'' AS mz71
, e.monitor_data->>''Z81'' AS mz81
, e.monitor_data->>''Z91'' AS mz91
, e.monitor_data->>''Z101'' AS mz101
, e.monitor_data->>''Z111'' AS mz111
, e.monitor_data->>''Z121'' AS mz121
, e.monitor_data->>''Z131'' AS mz131
, e.monitor_data->>''Z141'' AS mz141
, e.monitor_data->>''Z151'' AS mz151
, e.monitor_data->>''Z161'' AS mz161
, e.monitor_data->>''Z171'' AS mz171
, e.monitor_data->>''Z181'' AS mz181
, e.monitor_data->>''Z191'' AS mz191
, e.monitor_data->>''Z201'' AS mz201
, e.monitor_data->>''Z211'' AS mz211
, e.monitor_data->>''Z221'' AS mz221
, e.monitor_data->>''Z231'' AS mz231
, e.monitor_data->>''Z241'' AS mz241
, e.monitor_data->>''Z251'' AS mz251
, e.monitor_data->>''Z261'' AS mz261
, e.monitor_data->>''Z271'' AS mz271
, e.monitor_data->>''Z281'' AS mz281
, e.monitor_data->>''Z291'' AS mz291
, e.monitor_data->>''Z301'' AS mz301
, e.monitor_data->>''Z311'' AS mz311
, e.monitor_data->>''Z321'' AS mz321
, e.monitor_data->>''Z331'' AS mz331
, e.monitor_data->>''Z341'' AS mz341
, e.monitor_data->>''Z351'' AS mz351
, e.monitor_data->>''Z361'' AS mz361
, e.monitor_data->>''Z371'' AS mz371
, e.monitor_data->>''Z381'' AS mz381
, e.monitor_data->>''Z391'' AS mz391
, e.monitor_data->>''Z401'' AS mz401
, e.monitor_data->>''Z411'' AS mz411
, e.monitor_data->>''Z421'' AS mz421
, e.monitor_data->>''Z431'' AS mz431
, e.monitor_data->>''Z441'' AS mz441
, e.monitor_data->>''Z451'' AS mz451
, e.monitor_data->>''Z12'' AS mz12
, e.monitor_data->>''Z22'' AS mz22
, e.monitor_data->>''Z32'' AS mz32
, e.monitor_data->>''Z42'' AS mz42
, e.monitor_data->>''Z52'' AS mz52
, e.monitor_data->>''Z62'' AS mz62
, e.monitor_data->>''Z72'' AS mz72
, e.monitor_data->>''Z82'' AS mz82
, e.monitor_data->>''Z92'' AS mz92
, e.monitor_data->>''Z102'' AS mz102
, e.monitor_data->>''Z112'' AS mz112
, e.monitor_data->>''Z122'' AS mz122
, e.monitor_data->>''Z132'' AS mz132
, e.monitor_data->>''Z142'' AS mz142
, e.monitor_data->>''Z152'' AS mz152
, e.monitor_data->>''Z162'' AS mz162
, e.monitor_data->>''Z172'' AS mz172
, e.monitor_data->>''Z182'' AS mz182
, e.monitor_data->>''Z192'' AS mz192
, e.monitor_data->>''Z202'' AS mz202
, e.monitor_data->>''Z212'' AS mz212
, e.monitor_data->>''Z222'' AS mz222
, e.monitor_data->>''Z232'' AS mz232
, e.monitor_data->>''Z13'' AS mz13
, e.monitor_data->>''Z23'' AS mz23
, e.monitor_data->>''Z33'' AS mz33
, e.monitor_data->>''Z43'' AS mz43
, e.monitor_data->>''Z53'' AS mz53
, e.monitor_data->>''Z63'' AS mz63
, e.monitor_data->>''Z73'' AS mz73
, e.monitor_data->>''Z83'' AS mz83
, e.monitor_data->>''Z93'' AS mz93
, e.monitor_data->>''Z103'' AS mZ103
, e.monitor_data->>''Z113'' AS mZ113
, e.monitor_data->>''Z123'' AS mZ123
, e.monitor_data->>''Z133'' AS mZ133
, e.monitor_data->>''Z143'' AS mZ143
, e.monitor_data->>''Z153'' AS mZ153
, e.monitor_data->>''Z163'' AS mZ163
, e.monitor_data->>''Z173'' AS mZ173
, e.monitor_data->>''Z183'' AS mZ183
, e.monitor_data->>''Z193'' AS mZ193
, e.monitor_data->>''Z203'' AS mZ203
, e.monitor_data->>''Z213'' AS mZ213
, e.monitor_data->>''Z223'' AS mZ223
, e.monitor_data->>''Z233'' AS mZ233
, e.monitor_data->>''Z243'' AS mZ243
, e.monitor_data->>''Z253'' AS mZ253
, e.monitor_data->>''Z263'' AS mZ263
, e.monitor_data->>''Z14'' AS mz14
, e.monitor_data->>''Z24'' AS mz24
, e.monitor_data->>''Z34'' AS mz34
, e.monitor_data->>''Z44'' AS mz44
, e.monitor_data->>''Z54'' AS mz54
, e.monitor_data->>''Z64'' AS mz64
, e.monitor_data->>''Z74'' AS mz74
, e.monitor_data->>''Z84'' AS mz84
, e.monitor_data->>''Z94'' AS mz94
, e.monitor_data->>''Z104'' AS mz104
, e.monitor_data->>''Z114'' AS mz114
, e.monitor_data->>''Z124'' AS mz124
, e.monitor_data->>''Z134'' AS mz134
, e.monitor_data->>''Z144'' AS mz144
, e.monitor_data->>''Z154'' AS mz154
, e.monitor_data->>''Z164'' AS mz164
, e.monitor_data->>''Z174'' AS mz174
, e.monitor_data->>''Z184'' AS mz184
, e.monitor_data->>''Z194'' AS mz194
, e.monitor_data->>''Z204'' AS mz204
, e.monitor_data->>''Z214'' AS mz214
, e.monitor_data->>''Z224'' AS mz224
, e.monitor_data->>''Z234'' AS mz234
, e.monitor_data->>''Z244'' AS mz244
, e.monitor_data->>''Z254'' AS mz254
, e.monitor_data->>''Z264'' AS mz264
, e.monitor_data->>''Z274'' AS mz274
, e.monitor_data->>''Z284'' AS mz284
, e.monitor_data->>''Z294'' AS mz294
, e.monitor_data->>''Z304'' AS mz304
, e.monitor_data->>''Z314'' AS mz314
, e.monitor_data->>''Z324'' AS mz324
, e.monitor_data->>''Z334'' AS mz334
, e.monitor_data->>''Z344'' AS mz344
, e.monitor_data->>''Z354'' AS mz354
, e.monitor_data->>''Z364'' AS mz364
, e.monitor_data->>''Z374'' AS mz374
, BpBefore.monitor_data
--, b.ord_no
, CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)  AS leftovers
, b.pat_id AS hosp_pat_id
, b.rst_end_date as treatment_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end_fr_end
, b.rst_weight_info #>> ''{sttc_vns_prssr}'' AS sttc_vns_prssr
, b.rst_dw AS last_weight_after
, b.rst_weight_info #>> ''{ihdf_pll}'' AS ihdf_pll
, round((CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL))/1000,2) AS off_water_total
, b.rst_weight_info #>> ''{iap_rt}'' AS IAPRatio
,e.monitor_data->>''Z212'' AS device_self_diagnosis
,b.rst_bed_name AS bed_name
, round((CAST(b.rst_tare_info -> ''before'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_5'' AS DECIMAL))/1000,2) AS weight_before_tare_total
,  round((CAST(b.rst_tare_info -> ''after'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_5'' AS DECIMAL))/1000,2 )AS weight_after_tare_total
, cast(b.rst_complaint_info->-1 ->> ''occur_date'' as timestamp (3)) || '' '' || COALESCE((b.rst_complaint_info->-1 ->> ''complaint''), '''') AS complaint_latest
, o.treatment AS treatment_latest
, COALESCE(b.rst_cond_info -> ''17'' ->> ''value'', ''0'')  as dialysates_used_num
, (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - b.rst_dw) AS weight_before_dw
,CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) AS weight_before_weight_target
,(CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL)) AS weight_before_weight_after
,CASE WHEN b.rst_dw is NULL OR b.rst_dw = 0 THEN 0 ELSE(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw)/ b.rst_dw*100 END AS per_increase
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw) as amount_increase
,CASE WHEN CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL) > 0 THEN round( CAST(b.rst_weight_info  ->> ''water_removal_rst'' AS DECIMAL)/CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL),2)  ELSE 0 END as achievement_rate
,round( (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL)*1000 - CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL)*1000 -
 CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)*1000 + (CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL)) )/1000,2) as leftovers_expected 
,COALESCE(j.observation_records_num,0) as observation_records_num
,k.machine_status
,l.is_content_changed_for_map
,m.dosing_status
,n.rate as recirculation_rate_eff 
,bed.bed_order
,kur.kur_order
,MIN(rb1.bed_group_order) as bed_group_order
,b.rst_start_date as start_time
,b.rst_end_date as end_time
-- 終了予定
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS  ind_end_date
-- 終了予測
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
END AS ind_end_date_time
from b
LEFT outer JOIN j on (b.pat_id = j.pat_id)
LEFT JOIN d on (b.ord_no = d.ord_no)
LEFT JOIN e on (b.ord_no = e.ord_no)
LEFT JOIN k on (b.ord_no = k.ord_no)
LEFT JOIN q on (b.ord_no = q.ord_no)
LEFT JOIN p on (b.ord_no = p.ord_no)
LEFT JOIN l ON (b.ord_no = l.ord_no)
LEFT JOIN m ON (b.ord_no = m.ord_no)
LEFT JOIN n ON (b.ord_no = n.ord_no)
LEFT JOIN o on (b.ord_no = o.ord_no)
left outer join f on (b.ord_no = f.ord_no)
left outer join mnt_machine_state on (b.facility_cd = mnt_machine_state.facility_cd and b.ind_bed_cd = mnt_machine_state.bed_cd)
left outer join pat_unique on (b.pat_id = pat_unique.pat_id)
left outer join BpBefore on (b.ord_no = BpBefore.ord_no)
left outer join BpCurrent on (b.ord_no = BpCurrent.ord_no)
left outer join BpAfter on (b.ord_no = BpAfter.ord_no)
left outer join Vital on (b.ord_no = Vital.ord_no)
    -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || b.rst_bed_cd) :: jsonb
            LEFT OUTER JOIN bed_group AS rb1 ON rbg1.room_bed_group_cd = rb1.bed_group_code
            LEFT OUTER JOIN bed ON bed.bed_code = b.rst_bed_cd
            LEFT OUTER JOIN kur ON kur.kur_code = b.rst_kur_cd
            LEFT OUTER JOIN pat_main as pt ON b.pat_id = pt.pat_id
            LEFT OUTER JOIN pat_group_detail as pgd ON b.pat_id = pgd.pat_id
            LEFT OUTER JOIN patgrou ON pgd.pat_group_cd = patgrou.pat_group_code
group by 
b.ord_no
, b.treat_date
, b.pat_id
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw
, mnt_machine_state.process_state
, b.rst_cond_info
, b.rst_weight_info
, b.rst_dialysis_state
, f.残り時間_除水完了
, f.残り時間_透析完了
, f.残り時間_補液完了
, f.予測時間_除水
, f.予測時間_透析
, f.予測時間_補液
, e.残り時間_除水完了
, e.残り時間_透析完了
, e.残り時間_補液完了
, p.com_format_cd
, p.com_type
, d.data_type
, q.残り時間_透析完了
, e.残り時間_透析完了
, bpbefore.monitor_data
, bpcurrent.monitor_data
, Vital.monitor_data
, b.rst_charge_user_info
, b.rst_puncture_user_info
, b.rst_return_user_info
, bpafter.monitor_data
, b.rst_rounds_info
, e.monitor_data
, bpbefore.ord_no
, b.rst_off_water_info
, b.rst_tare_info
, b.rst_bed_name
, b.rst_complaint_info
, o.treatment
, j.observation_records_num
, k.machine_status
, l.is_content_changed_for_map
, m.dosing_status
, n.rate
, bed.bed_order
, kur.kur_order
, e.経過時間
, e.bio_moni_ctl_no
, b.rst_start_date
, b.rst_end_date    
, pt.is_infect      
order by b.ord_no, d.data_type desc, b.treat_date,  e.bio_moni_ctl_no', 2, '[{"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_sex", "target_var": "@patId"}, "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_abo", "target_var": "@patId"}, "data_code": "pat_blood_type_abo", "data_name": "血液型(ABO)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id3", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_rh", "target_var": "@patId"}, "data_code": "pat_blood_type_rh", "data_name": "血液型(Rh)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id4", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name_kana", "target_var": "@patId"}, "data_code": "pat_name_kana", "data_name": "フリガナ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id5", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "treat_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午後", "can_calc": "0", "data_code": "ind_kur_name", "data_name": "クール", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ind_kur_name", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "運転", "can_calc": "0", "data_code": "process_state", "data_name": "状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "process_state", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "target_weight_2", "data_name": "目標体重から", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重から", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_start_date", "data_name": "治療開始", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_start_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "ind_end_date_time", "data_name": "終了予測", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_water_removal_end", "data_name": "終了予測(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_除水完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_dialysis_end", "data_name": "終了予測(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_透析完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_end_date", "data_name": "透析終了日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_end_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "treatment_time", "data_name": "治療時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "treatment_minute", "data_name": "治療時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間分", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "delay_time", "data_name": "遅れ時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "遅れ時間", "disp_format": "H:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1:00", "can_calc": "0", "data_code": "remaining_time", "data_name": "残り時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "remaining_time", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "progress_rate", "data_name": "進捗率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "進捗率", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_max", "data_name": "前血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_min", "data_name": "前血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_avg", "data_name": "前血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpbefore", "data_name": "前血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "pulse_before", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpcurrent", "data_name": "現在血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "現在血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_1", "data_name": "担当者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_1", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_2", "data_name": "担当者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_2", "data_name": "担当2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date", "data_name": "穿刺日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_1", "data_name": "穿刺者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_1", "data_name": "穿刺1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_2", "data_name": "穿刺者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_2", "data_name": "穿刺2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date", "data_name": "返血日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_1", "data_name": "返血者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_1", "data_name": "返血1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_2", "data_name": "返血者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_2", "data_name": "返血2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_after", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_max", "data_name": "後血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_min", "data_name": "後血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_avg", "data_name": "後血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpafter", "data_name": "後血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "pulse_after", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_target", "data_name": "除水目標", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "water_removal_target", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "pat_confirm", "data_name": "患者確認", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "患者確認", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-03-25T09:20:30.000+09:00", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-12-10 01:56:01", "can_calc": "0", "data_code": "ind_end_date", "data_name": "終了予定", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予定", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "rounds_status", "data_name": "回診状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診状態", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未回診", "can_calc": "0", "data_code": "rounds_data", "data_name": "回診データ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診データ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ctr", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "右", "can_calc": "0", "data_code": "va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "va", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "除水量制限", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装[FDY-21GW]", "can_calc": "0", "data_code": "dialyzer", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ダイアライザ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト吸着カラム１", "can_calc": "0", "data_code": "adsorption_column", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "吸着カラム", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_membrane", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "一次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "Second_membrane", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "二次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針１", "can_calc": "0", "data_code": "needles_a", "data_name": "穿刺針(A針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_a針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針２", "can_calc": "0", "data_code": "needles_v", "data_name": "穿刺針(V針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_v針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針3", "can_calc": "0", "data_code": "needles_sn", "data_name": "穿刺針(SN)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_sn", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "single_needle_use", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "シングルニードル使用", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト血液回路１", "can_calc": "0", "data_code": "blood_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "血液回路", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "血流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト透析液１", "can_calc": "0", "data_code": "dialysate", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "透析液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "dialysate_flow", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "349", "can_calc": "0", "data_code": "dialysate_volume", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.0", "can_calc": "0", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液１", "can_calc": "0", "data_code": "fluid_replenishment", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "fr_volume", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fr_selection", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "fr_use_num", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液使用数", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.9", "can_calc": "0", "data_code": "fr_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "fr_velocity", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤１", "can_calc": "0", "data_code": "anticoagulants", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "anticoagulants_oneshot_quantity", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤ワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "anticoagulants_duration_rate", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip_usage_selection", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "IP使用選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "治療状況", "field_name": "IPスタート", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "ip_oneshot_quantity", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IPワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip_velocity", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip_velocity_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP速度最大値", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_oneshot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "自動ワンショット", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "IP電源自動切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip_power_ok_monitor_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "IP電源OKモニタ切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "ip_power_ok_monitor_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP電源OKモニタ切り時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "0", "data_code": "spo2", "data_name": "SpO2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "spo2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "blood_glucose_level", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "bp_high", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "bp_low", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "bp_ave", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "pulse", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "body_temperature", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "m001", "data_name": "[モニタ]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m001", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "m002", "data_name": "[モニタ]経過時間(ECUM)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m002", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m003", "data_name": "[モニタ]残り時間(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "m003", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "m004", "data_name": "[モニタ]残り時間(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "m004", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m005", "data_name": "[モニタ]除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m005", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.55", "can_calc": "0", "data_code": "m006", "data_name": "[モニタ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m006", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3.0", "can_calc": "0", "data_code": "m007", "data_name": "[モニタ]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m007", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m008", "data_name": "[モニタ]血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m008", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "0", "data_code": "m009", "data_name": "[モニタ]IP総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m009", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.0", "can_calc": "0", "data_code": "m010", "data_name": "[モニタ]IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m010", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "m011", "data_name": "[モニタ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m011", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "m012", "data_name": "[モニタ]透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m012", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m013", "data_name": "[モニタ]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m013", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m014", "data_name": "[モニタ]ダイアライザー入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m014", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "m015", "data_name": "[モニタ]ダイアライザー差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m015", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "m016", "data_name": "[モニタ]血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m016", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.0", "can_calc": "0", "data_code": "m017", "data_name": "[モニタ]⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m017", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.40", "can_calc": "0", "data_code": "m018", "data_name": "[モニタ]バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m018", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "m019", "data_name": "[モニタ]透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m019", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16", "can_calc": "0", "data_code": "m020", "data_name": "[モニタ]Na濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m020", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.0", "can_calc": "0", "data_code": "m021", "data_name": "[モニタ]透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m021", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "18", "can_calc": "0", "data_code": "m022", "data_name": "[モニタ]透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m022", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.9", "can_calc": "0", "data_code": "m023", "data_name": "[モニタ]漏血量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m023", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m024", "data_name": "[モニタ]給液圧(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m024", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m025", "data_name": "[モニタ]給液圧(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m025", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22.00", "can_calc": "0", "data_code": "m026", "data_name": "[モニタ]UFR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m026", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "m027", "data_name": "[モニタ]UFR低下率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m027", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "24.00", "can_calc": "0", "data_code": "m028", "data_name": "[モニタ]初期UFR測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m028", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25.0", "can_calc": "0", "data_code": "m029", "data_name": "[モニタ]TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m029", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "26", "can_calc": "0", "data_code": "m030", "data_name": "[モニタ]透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m030", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m031", "data_name": "[モニタ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m031", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "28.00", "can_calc": "0", "data_code": "m032", "data_name": "[モニタ]除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m032", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "0", "data_code": "m033", "data_name": "[モニタ]除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m033", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m034", "data_name": "[モニタ]透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m034", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "31", "can_calc": "0", "data_code": "m035", "data_name": "[モニタ]透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m035", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "32", "can_calc": "0", "data_code": "m036", "data_name": "[モニタ]血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m036", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m037", "data_name": "[モニタ]IP速度設定", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m037", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.34", "can_calc": "0", "data_code": "m038", "data_name": "[モニタ]Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m038", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "0", "data_code": "m039", "data_name": "[モニタ]静脈圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m039", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36", "can_calc": "0", "data_code": "m040", "data_name": "[モニタ]静脈圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m040", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37", "can_calc": "0", "data_code": "m041", "data_name": "[モニタ]透析液圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m041", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "m042", "data_name": "[モニタ]透析液圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m042", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m043", "data_name": "[モニタ]TMP警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m043", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m044", "data_name": "[モニタ]TMP警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m044", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m045", "data_name": "[モニタ]ダイアライザー入口圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m045", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "0", "data_code": "m046", "data_name": "[モニタ]ダイアライザー入口圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m046", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "43", "can_calc": "0", "data_code": "m047", "data_name": "[モニタ]ダイアライザー差圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m047", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "44", "can_calc": "0", "data_code": "m048", "data_name": "[モニタ]ダイアライザー差圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m048", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-45.0", "can_calc": "0", "data_code": "m049", "data_name": "[モニタ]⊿BV低下警報点１", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m049", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-46.0", "can_calc": "0", "data_code": "m050", "data_name": "[モニタ]⊿BV低下警報点２", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m050", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-17.0", "can_calc": "0", "data_code": "m051", "data_name": "[モニタ]⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m051", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "48", "can_calc": "0", "data_code": "m052", "data_name": "[モニタ]BPM関連データ9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m052", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-49", "can_calc": "0", "data_code": "m053", "data_name": "[モニタ]BPM関連データ10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m053", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "m054", "data_name": "[モニタ]バイカーボ濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m054", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.10", "can_calc": "0", "data_code": "m055", "data_name": "[モニタ]バイカーボ濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m055", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "m056", "data_name": "[モニタ]透析液濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m056", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "53.0", "can_calc": "0", "data_code": "m057", "data_name": "[モニタ]透析液濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m057", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "54", "can_calc": "0", "data_code": "m058", "data_name": "[モニタ]Na濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m058", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55", "can_calc": "0", "data_code": "m059", "data_name": "[モニタ]Na濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m059", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.0", "can_calc": "0", "data_code": "m060", "data_name": "[モニタ]透析液温度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m060", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.0", "can_calc": "0", "data_code": "m061", "data_name": "[モニタ]透析液温度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m061", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.8", "can_calc": "0", "data_code": "m062", "data_name": "[モニタ]漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m062", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "59", "can_calc": "0", "data_code": "m063", "data_name": "[モニタ]給水圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m063", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "m064", "data_name": "[モニタ]給水圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m064", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.10", "can_calc": "0", "data_code": "m065", "data_name": "[モニタ]初期UFR警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m065", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "62.00", "can_calc": "0", "data_code": "m066", "data_name": "[モニタ]初期UFR警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m066", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "63", "can_calc": "0", "data_code": "m067", "data_name": "[モニタ]UFR低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m067", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.60", "can_calc": "0", "data_code": "m068", "data_name": "[モニタ]Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m068", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.50", "can_calc": "0", "data_code": "m069", "data_name": "[モニタ]運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m069", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.5", "can_calc": "0", "data_code": "m070", "data_name": "[モニタ]補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m070", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.68", "can_calc": "0", "data_code": "m071", "data_name": "[モニタ]補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m071", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "69.00", "can_calc": "0", "data_code": "m072", "data_name": "[モニタ]補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m072", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.70", "can_calc": "0", "data_code": "m073", "data_name": "[モニタ]補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m073", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.7", "can_calc": "0", "data_code": "m074", "data_name": "[モニタ]補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m074", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30.0", "can_calc": "0", "data_code": "m075", "data_name": "[モニタ]補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m075", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.30", "can_calc": "0", "data_code": "m076", "data_name": "[モニタ]濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m076", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "74.00", "can_calc": "0", "data_code": "m077", "data_name": "[モニタ]荷重計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m077", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m078", "data_name": "[モニタ]残り時間(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "m078", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m079", "data_name": "[モニタ]URR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m079", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "77.0", "can_calc": "0", "data_code": "m080", "data_name": "[モニタ]⊿BV変化率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m080", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "78.00", "can_calc": "0", "data_code": "m081", "data_name": "[モニタ]PWI", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m081", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "79", "can_calc": "0", "data_code": "m082", "data_name": "[モニタ]BPM関連データ1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m082", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "0", "data_code": "m083", "data_name": "[モニタ]BPM関連データ2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m083", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m084", "data_name": "[モニタ]BPM関連データ3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m084", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82.0", "can_calc": "0", "data_code": "m085", "data_name": "[モニタ]⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m085", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "83.0", "can_calc": "0", "data_code": "m086", "data_name": "[モニタ]⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m086", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "84", "can_calc": "0", "data_code": "m087", "data_name": "[モニタ]BPM関連データ6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m087", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "0", "data_code": "m088", "data_name": "[モニタ]PRR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m088", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m089", "data_name": "[モニタ]再循環率測定結果(BVMS連携用)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m089", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "m095", "data_name": "[モニタ]⊿BV5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m095", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "0", "data_code": "m096", "data_name": "[モニタ]⊿BV最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m096", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "m097", "data_name": "[モニタ]推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m097", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m098", "data_name": "[モニタ]血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m098", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m100", "data_name": "[モニタ]⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m100", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m101", "data_name": "[モニタ]Ht", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m102", "data_name": "[モニタ]LDQb", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "m103", "data_name": "[モニタ]補液回路内圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz11", "data_name": "[ACHΣ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz11", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz21", "data_name": "[ACHΣ]工程状態", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz21", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz31", "data_name": "[ACHΣ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz31", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz41", "data_name": "[ACHΣ]血液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz41", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz51", "data_name": "[ACHΣ]シリンジ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz51", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz61", "data_name": "[ACHΣ]ろ過流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz61", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz71", "data_name": "[ACHΣ]透析液/ドレン流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz71", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz81", "data_name": "[ACHΣ]補液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz81", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz91", "data_name": "[ACHΣ]透析液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz91", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz101", "data_name": "[ACHΣ]補液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz111", "data_name": "[ACHΣ]現在除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz111", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz121", "data_name": "[ACHΣ]現在血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz121", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz131", "data_name": "[ACHΣ]現在ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz131", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz141", "data_name": "[ACHΣ]現在透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz141", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz151", "data_name": "[ACHΣ]現在補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz151", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz161", "data_name": "[ACHΣ]治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz161", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz171", "data_name": "[ACHΣ]シリンジ積算量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz171", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz181", "data_name": "[ACHΣ]目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz181", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz191", "data_name": "[ACHΣ]目標血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz191", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz201", "data_name": "[ACHΣ]目標ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz201", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz211", "data_name": "[ACHΣ]目標透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz211", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz221", "data_name": "[ACHΣ]目標補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz221", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz231", "data_name": "[ACHΣ]目標治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz231", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz241", "data_name": "[ACHΣ]脱血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz241", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz251", "data_name": "[ACHΣ]入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz251", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz261", "data_name": "[ACHΣ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz261", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz271", "data_name": "[ACHΣ]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz271", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz281", "data_name": "[ACHΣ]排気圧/2次膜圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz281", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz291", "data_name": "[ACHΣ]TMP/TMP1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz291", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz301", "data_name": "[ACHΣ]TMP2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz301", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz311", "data_name": "[ACHΣ]差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz311", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz321", "data_name": "[ACHΣ]気泡検知警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz321", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz331", "data_name": "[ACHΣ]漏血警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz331", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz341", "data_name": "[ACHΣ]加温器警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz341", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz351", "data_name": "[ACHΣ]脱血圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz351", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz361", "data_name": "[ACHΣ]入口圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz361", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz371", "data_name": "[ACHΣ]静脈圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz371", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz381", "data_name": "[ACHΣ]ろ過圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz381", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz391", "data_name": "[ACHΣ]排気圧/2次膜圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz391", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz401", "data_name": "[ACHΣ]TMP警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz401", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz411", "data_name": "[ACHΣ]TMP2警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz411", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz421", "data_name": "[ACHΣ]差圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz421", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz431", "data_name": "[ACHΣ]その他警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz431", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz441", "data_name": "[ACHΣ]クエン酸流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz441", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz451", "data_name": "[ACHΣ]現在クエン酸量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz451", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz12", "data_name": "[KM8900]測定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz12", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz22", "data_name": "[KM8900]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz22", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz32", "data_name": "[KM8900]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz32", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz42", "data_name": "[KM8900]測定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz42", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz52", "data_name": "[KM8900]圧力上限警報設定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz52", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz62", "data_name": "[KM8900]圧力上限警報設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz62", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz72", "data_name": "[KM8900]圧力上限警報設定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz72", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz82", "data_name": "[KM8900]圧力上限警報設定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz82", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz92", "data_name": "[KM8900]流量情報BP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz92", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz102", "data_name": "[KM8900]流量情報PP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz112", "data_name": "[KM8900]流量情報DP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz112", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz122", "data_name": "[KM8900]流量情報BP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz122", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz132", "data_name": "[KM8900]流量情報PP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz132", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz142", "data_name": "[KM8900]流量情報DP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz142", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz152", "data_name": "[KM8900]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz152", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz162", "data_name": "[KM8900]流量情報血漿処理目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz162", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz172", "data_name": "[KM8900]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz172", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz182", "data_name": "[KM8900]その他情報バランス", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz182", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz192", "data_name": "[KM8900]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz192", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz202", "data_name": "[KM8900]その他情報アラーム番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz202", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz212", "data_name": "[KM8900]その他情報自己診断番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz212", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz222", "data_name": "[KM8900]その他情報モード(用途)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz222", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz232", "data_name": "[KM8900]その他情報工程情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz232", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz13", "data_name": "[iQ21]治療経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz13", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz23", "data_name": "[iQ21]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz23", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz33", "data_name": "[iQ21]ろ過ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz33", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz43", "data_name": "[iQ21]補液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz43", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz53", "data_name": "[iQ21]透析液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz53", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz63", "data_name": "[iQ21]血液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz63", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz73", "data_name": "[iQ21]シリンジポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz73", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz83", "data_name": "[iQ21]除水量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz83", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz93", "data_name": "[iQ21]ろ過量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz93", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz103", "data_name": "[iQ21]補液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz113", "data_name": "[iQ21]透析液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz113", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz123", "data_name": "[iQ21]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz123", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz133", "data_name": "[iQ21]シリンジポンプ積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz133", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz143", "data_name": "[iQ21]採血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz143", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz153", "data_name": "[iQ21]動脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz153", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz163", "data_name": "[iQ21]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz163", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz173", "data_name": "[iQ21]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz173", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz183", "data_name": "[iQ21]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz183", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz193", "data_name": "[iQ21]分離ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz193", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz203", "data_name": "[iQ21]返漿ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz203", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz213", "data_name": "[iQ21]ドレンポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz213", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz223", "data_name": "[iQ21]分離量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz223", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz233", "data_name": "[iQ21]返漿量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz233", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz243", "data_name": "[iQ21]ドレン量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz243", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz253", "data_name": "[iQ21]血漿圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz253", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz263", "data_name": "[iQ21]血漿入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz263", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz14", "data_name": "[KM9000]測定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz14", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz24", "data_name": "[KM9000]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz24", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz34", "data_name": "[KM9000]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz34", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz44", "data_name": "[KM9000]測定値ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz44", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz54", "data_name": "[KM9000]測定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz54", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz64", "data_name": "[KM9000]設定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz64", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz74", "data_name": "[KM9000]設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz74", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz84", "data_name": "[KM9000]設定値返血圧・上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz84", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz94", "data_name": "[KM9000]設定値返血圧・下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz94", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz104", "data_name": "[KM9000]設定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz104", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz114", "data_name": "[KM9000]設定値除水設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz114", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz124", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz124", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz134", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz134", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz144", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz144", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz154", "data_name": "[KM9000]流量情報ろ液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz154", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz164", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz164", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz174", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz174", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz184", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz184", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz194", "data_name": "[KM9000]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz194", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz204", "data_name": "[KM9000]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz204", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz214", "data_name": "[KM9000]その他情報除水差分/重量値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz214", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz224", "data_name": "[KM9000]その他情報初期診断情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz224", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz234", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz234", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz244", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz244", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz254", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz254", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz264", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報4", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz264", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz274", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報5", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz274", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz284", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz284", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz294", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報7", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz294", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz304", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報8", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz304", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz314", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz314", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz324", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz324", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz334", "data_name": "[KM9000]その他情報注意情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz334", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz344", "data_name": "[KM9000]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz344", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz354", "data_name": "[KM9000]その他情報用途", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz354", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz364", "data_name": "[KM9000]その他情報工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz364", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz374", "data_name": "[KM9000]その他情報動作日、時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz374", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "dw", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "iapratio", "data_name": "IAP Ratio", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "iapratio", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "ihdf_pll", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ihdf引き残し量", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_auto_cycle_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源自動切り時間", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "leftovers", "data_name": "引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "引き残し", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "observation_records_num", "data_name": "観察記録件数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "観察記録件数", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "machine_status", "data_name": "警報・報知", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "警報・報知", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_after_tare_total", "data_name": "後体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "0", "data_code": "anticoagulants_total_volume", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続総量", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "0", "data_code": "recirculation_rate_eff", "data_name": "再循環率有効値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "再循環率有効値", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint_latest", "data_name": "最新愁訴", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新愁訴", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treatment_latest", "data_name": "最新処置", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新処置", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "はい", "can_calc": "0", "data_code": "is_content_changed_for_map", "data_name": "指示変更", "data_type": "string", "conv_table": [{"code": 0, "disp": "変更なし", "item": "変更なし"}, {"code": 1, "disp": "変更あり", "item": "変更あり"}], "data_class": "治療状況", "field_name": "指示変更", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "treatment_end", "data_name": "治療終了", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療終了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_fr_end", "data_name": "終了予測(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測補液完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_total", "data_name": "除水補正合計", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "除水補正合計", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "sttc_vns_prssr", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "静的静脈圧", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "last_weight_after", "data_name": "前回後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前回後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "weight_before_dw", "data_name": "前体重 - DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重dw", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "weight_before_weight_target", "data_name": "前体重 - 目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重目標体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_before_weight_after", "data_name": "前体重-後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_before_tare_total", "data_name": "前体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "device_self_diagnosis", "data_name": "装置自己診断", "data_type": "string", "conv_table": [{"code": 0, "disp": "未実施", "item": "未実施"}, {"code": 1, "disp": "実施済み", "item": "実施済み"}], "data_class": "治療状況", "field_name": "装置自己診断", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "per_increase", "data_name": "増加率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "amount_increase", "data_name": "増加量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "achievement_rate", "data_name": "達成率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "達成率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0/0", "can_calc": "0", "data_code": "dosing_status", "data_name": "投与状況", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "投与状況", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dialysates_used_num", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液使用数", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "leftovers_expected", "data_name": "予想引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "予想引き残し", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ベッド名", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "start_time", "disp_format": "hh:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "end_time", "disp_format": "hh:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト', '2020-04-25 00:00:00', CURRENT_TIMESTAMP, NULL);
