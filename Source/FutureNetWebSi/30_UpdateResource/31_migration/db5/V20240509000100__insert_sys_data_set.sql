DELETE FROM "ntss"."sys_data_set" where sql_cd in (225);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (225, 'WITH b AS (
select ord_main.* from ord_main
     where facility_cd = @facilityCd
 and rst_dialysis_state between ''1'' and ''5''
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate
 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate
 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
     and
       is_del = ''0''
             and pat_id IS NULL
), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
        where mni_monitor.facility_cd = @facilityCd
    group by b.ord_no
    , mni_monitor.data_type
        LIMIT 1
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    , to_number(mni_monitor.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 予測時間_除水
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 予測時間_透析
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
    where d.data_type = 1
), h as (select machine_no,b.ord_no,mst_bed.bed_cd from mst_bed INNER JOIN b on b.rst_bed_cd = mst_bed.bed_cd
), f AS (
    select e.*
--     to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
--     , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
--     , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_除水完了,0) AS 予測時間_除水
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_透析完了,0) AS 予測時間_透析
        , COALESCE(e.経過時間,0) + COALESCE(e.残り時間_補液完了,0) AS 予測時間_補液 
    from e
--     inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
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
     to_number(mnt_machine_state.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
     from e
     inner join mnt_machine_state on
     e.facility_cd = mnt_machine_state.facility_cd and
     e.machine_type_cd = mnt_machine_state.machine_type_cd and
     e.machine_serial = mnt_machine_state.machine_type_cd and
     e.ord_no = mnt_machine_state.ord_no and
     e.pat_id = mnt_machine_state.pat_id
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
((rst_weight_info->''recrcl_rt'') -> ''1'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''2'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''3'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''4'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''5'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
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
        facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
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
        facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
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
        facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
        AND master_physical_name = ''mst_kur''
 )
 ,mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 )
select b.ord_no, b.treat_date
, b.pat_id AS pat_id
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
 ,CASE WHEN b.rst_dialysis_state < ''3'' THEN 0
       WHEN b.rst_cond_info::json#>>''{1, value}'' is null or b.rst_cond_info::json#>>''{1, value}'' = ''0'' THEN null
       WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is null THEN FLOOR(cast((round(extract(epoch from now() - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is not null THEN FLOOR(cast((round(extract(epoch from CAST(b.rst_end_date AS TIMESTAMP) - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN d.data_type = 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(q.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)
             WHEN d.data_type <> 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(e.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)  
             END AS progress_rate 
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->''90'' AS bpbefore_max
, BpBefore.monitor_data->''91'' AS bpbefore_min
, BpBefore.monitor_data->''92'' AS bpbefore_avg
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS bpbefore
, BpBefore.monitor_data->''93'' AS pulse_before
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
, BpAfter.monitor_data->''90'' AS bpafter_max
, BpAfter.monitor_data->''91'' AS bpafter_min
, BpAfter.monitor_data->''92'' AS bpafter_avg
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS bpafter
, BpAfter.monitor_data->''93'' AS pulse_after
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
, f.monitor_data->''0'' AS m000
, f.monitor_data->''1'' AS m001
, f.monitor_data->''2'' AS m002
, f.monitor_data->''3'' AS m003
, f.monitor_data->''4'' AS m004
, f.monitor_data->''5'' AS m005
, f.monitor_data->''6'' AS m006
, f.monitor_data->''7'' AS m007
, f.monitor_data->''8'' AS m008
, f.monitor_data->''9'' AS m009
, f.monitor_data->''10'' AS m010
, f.monitor_data->''11'' AS m011
, f.monitor_data->''12'' AS m012
, f.monitor_data->''13'' AS m013
, f.monitor_data->''14'' AS m014
, f.monitor_data->''15'' AS m015
, f.monitor_data->''16'' AS m016
, f.monitor_data->''17'' AS m017
, f.monitor_data->''18'' AS m018
, f.monitor_data->''19'' AS m019
, f.monitor_data->''20'' AS m020
, f.monitor_data->''21'' AS m021
, f.monitor_data->''22'' AS m022
, f.monitor_data->''23'' AS m023
, f.monitor_data->''24'' AS m024
, f.monitor_data->''25'' AS m025
, f.monitor_data->''26'' AS m026
, f.monitor_data->''27'' AS m027
, f.monitor_data->''28'' AS m028
, f.monitor_data->''29'' AS m029
, f.monitor_data->''30'' AS m030
, f.monitor_data->''31'' AS m031
, f.monitor_data->''32'' AS m032
, f.monitor_data->''33'' AS m033
, f.monitor_data->''34'' AS m034
, f.monitor_data->''35'' AS m035
, f.monitor_data->''36'' AS m036
, f.monitor_data->''37'' AS m037
, f.monitor_data->''38'' AS m038
, f.monitor_data->''39'' AS m039
, f.monitor_data->''40'' AS m040
, f.monitor_data->''41'' AS m041
, f.monitor_data->''42'' AS m042
, f.monitor_data->''43'' AS m043
, f.monitor_data->''44'' AS m044
, f.monitor_data->''45'' AS m045
, f.monitor_data->''46'' AS m046
, f.monitor_data->''47'' AS m047
, f.monitor_data->''48'' AS m048
, f.monitor_data->''49'' AS m049
, f.monitor_data->''50'' AS m050
, f.monitor_data->''51'' AS m051
, f.monitor_data->''52'' AS m052
, f.monitor_data->''53'' AS m053
, f.monitor_data->''54'' AS m054
, f.monitor_data->''55'' AS m055
, f.monitor_data->''56'' AS m056
, f.monitor_data->''57'' AS m057
, f.monitor_data->''58'' AS m058
, f.monitor_data->''59'' AS m059
, f.monitor_data->''60'' AS m060
, f.monitor_data->''61'' AS m061
, f.monitor_data->''62'' AS m062
, f.monitor_data->''63'' AS m063
, f.monitor_data->''64'' AS m064
, f.monitor_data->''65'' AS m065
, f.monitor_data->''66'' AS m066
, f.monitor_data->''67'' AS m067
, f.monitor_data->''68'' AS m068
, f.monitor_data->''69'' AS m069
, f.monitor_data->''70'' AS m070
, f.monitor_data->''71'' AS m071
, f.monitor_data->''72'' AS m072
, f.monitor_data->''73'' AS m073
, f.monitor_data->''74'' AS m074
, f.monitor_data->''75'' AS m075
, f.monitor_data->''76'' AS m076
, f.monitor_data->''77'' AS m077
, f.monitor_data->''78'' AS m078
, f.monitor_data->''79'' AS m079
, f.monitor_data->''80'' AS m080
, f.monitor_data->''81'' AS m081
, f.monitor_data->''82'' AS m082
, f.monitor_data->''83'' AS m083
, f.monitor_data->''84'' AS m084
, f.monitor_data->''85'' AS m085
, f.monitor_data->''86'' AS m086
, f.monitor_data->''87'' AS m087
, f.monitor_data->''88'' AS m088
, f.monitor_data->''89'' AS m089
, f.monitor_data->''95'' AS m095
, f.monitor_data->''96'' AS m096
, f.monitor_data->''97'' AS m097
, f.monitor_data->''98'' AS m098
, f.monitor_data->''100'' AS m100
, f.monitor_data->''101'' AS m101
, f.monitor_data->''102'' AS m102
, f.monitor_data->''Z11'' AS mz11
, f.monitor_data->''Z21'' AS mz21
, f.monitor_data->''Z31'' AS mz31
, f.monitor_data->''Z41'' AS mz41
, f.monitor_data->''Z51'' AS mz51
, f.monitor_data->''Z61'' AS mz61
, f.monitor_data->''Z71'' AS mz71
, f.monitor_data->''Z81'' AS mz81
, f.monitor_data->''Z91'' AS mz91
, f.monitor_data->''Z101'' AS mz101
, f.monitor_data->''Z111'' AS mz111
, f.monitor_data->''Z121'' AS mz121
, f.monitor_data->''Z131'' AS mz131
, f.monitor_data->''Z141'' AS mz141
, f.monitor_data->''Z151'' AS mz151
, f.monitor_data->''Z161'' AS mz161
, f.monitor_data->''Z171'' AS mz171
, f.monitor_data->''Z181'' AS mz181
, f.monitor_data->''Z191'' AS mz191
, f.monitor_data->''Z201'' AS mz201
, f.monitor_data->''Z211'' AS mz211
, f.monitor_data->''Z221'' AS mz221
, f.monitor_data->''Z231'' AS mz231
, f.monitor_data->''Z241'' AS mz241
, f.monitor_data->''Z251'' AS mz251
, f.monitor_data->''Z261'' AS mz261
, f.monitor_data->''Z271'' AS mz271
, f.monitor_data->''Z281'' AS mz281
, f.monitor_data->''Z291'' AS mz291
, f.monitor_data->''Z301'' AS mz301
, f.monitor_data->''Z311'' AS mz311
, f.monitor_data->''Z321'' AS mz321
, f.monitor_data->''Z331'' AS mz331
, f.monitor_data->''Z341'' AS mz341
, f.monitor_data->''Z351'' AS mz351
, f.monitor_data->''Z361'' AS mz361
, f.monitor_data->''Z371'' AS mz371
, f.monitor_data->''Z381'' AS mz381
, f.monitor_data->''Z391'' AS mz391
, f.monitor_data->''Z401'' AS mz401
, f.monitor_data->''Z411'' AS mz411
, f.monitor_data->''Z421'' AS mz421
, f.monitor_data->''Z431'' AS mz431
, f.monitor_data->''Z441'' AS mz441
, f.monitor_data->''Z451'' AS mz451
, f.monitor_data->''Z12'' AS mz12
, f.monitor_data->''Z22'' AS mz22
, f.monitor_data->''Z32'' AS mz32
, f.monitor_data->''Z42'' AS mz42
, f.monitor_data->''Z52'' AS mz52
, f.monitor_data->''Z62'' AS mz62
, f.monitor_data->''Z72'' AS mz72
, f.monitor_data->''Z82'' AS mz82
, f.monitor_data->''Z92'' AS mz92
, f.monitor_data->''Z102'' AS mz102
, f.monitor_data->''Z112'' AS mz112
, f.monitor_data->''Z122'' AS mz122
, f.monitor_data->''Z132'' AS mz132
, f.monitor_data->''Z142'' AS mz142
, f.monitor_data->''Z152'' AS mz152
, f.monitor_data->''Z162'' AS mz162
, f.monitor_data->''Z172'' AS mz172
, f.monitor_data->''Z182'' AS mz182
, f.monitor_data->''Z192'' AS mz192
, f.monitor_data->''Z202'' AS mz202
, f.monitor_data->''Z212'' AS mz212
, f.monitor_data->''Z222'' AS mz222
, f.monitor_data->''Z232'' AS mz232
, f.monitor_data->''Z13'' AS mz13
, f.monitor_data->''Z23'' AS mz23
, f.monitor_data->''Z33'' AS mz33
, f.monitor_data->''Z43'' AS mz43
, f.monitor_data->''Z53'' AS mz53
, f.monitor_data->''Z63'' AS mz63
, f.monitor_data->''Z73'' AS mz73
, f.monitor_data->''Z83'' AS mz83
, f.monitor_data->''Z93'' AS mz93
, f.monitor_data->''Z103'' AS mZ103
, f.monitor_data->''Z113'' AS mZ113
, f.monitor_data->''Z123'' AS mZ123
, f.monitor_data->''Z133'' AS mZ133
, f.monitor_data->''Z143'' AS mZ143
, f.monitor_data->''Z153'' AS mZ153
, f.monitor_data->''Z163'' AS mZ163
, f.monitor_data->''Z173'' AS mZ173
, f.monitor_data->''Z183'' AS mZ183
, f.monitor_data->''Z193'' AS mZ193
, f.monitor_data->''Z203'' AS mZ203
, f.monitor_data->''Z213'' AS mZ213
, f.monitor_data->''Z223'' AS mZ223
, f.monitor_data->''Z233'' AS mZ233
, f.monitor_data->''Z243'' AS mZ243
, f.monitor_data->''Z253'' AS mZ253
, f.monitor_data->''Z263'' AS mZ263
, f.monitor_data->''Z14'' AS mz14
, f.monitor_data->''Z24'' AS mz24
, f.monitor_data->''Z34'' AS mz34
, f.monitor_data->''Z44'' AS mz44
, f.monitor_data->''Z54'' AS mz54
, f.monitor_data->''Z64'' AS mz64
, f.monitor_data->''Z74'' AS mz74
, f.monitor_data->''Z84'' AS mz84
, f.monitor_data->''Z94'' AS mz94
, f.monitor_data->''Z104'' AS mz104
, f.monitor_data->''Z114'' AS mz114
, f.monitor_data->''Z124'' AS mz124
, f.monitor_data->''Z134'' AS mz134
, f.monitor_data->''Z144'' AS mz144
, f.monitor_data->''Z154'' AS mz154
, f.monitor_data->''Z164'' AS mz164
, f.monitor_data->''Z174'' AS mz174
, f.monitor_data->''Z184'' AS mz184
, f.monitor_data->''Z194'' AS mz194
, f.monitor_data->''Z204'' AS mz204
, f.monitor_data->''Z214'' AS mz214
, f.monitor_data->''Z224'' AS mz224
, f.monitor_data->''Z234'' AS mz234
, f.monitor_data->''Z244'' AS mz244
, f.monitor_data->''Z254'' AS mz254
, f.monitor_data->''Z264'' AS mz264
, f.monitor_data->''Z274'' AS mz274
, f.monitor_data->''Z284'' AS mz284
, f.monitor_data->''Z294'' AS mz294
, f.monitor_data->''Z304'' AS mz304
, f.monitor_data->''Z314'' AS mz314
, f.monitor_data->''Z324'' AS mz324
, f.monitor_data->''Z334'' AS mz334
, f.monitor_data->''Z344'' AS mz344
, f.monitor_data->''Z354'' AS mz354
, f.monitor_data->''Z364'' AS mz364
, f.monitor_data->''Z374'' AS mz374
, BpBefore.*
, b.ord_no
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
,f.monitor_data->''Z212'' AS device_self_diagnosis
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
,kur.kur_name as ind_kur_name
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
    -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || b.rst_bed_cd) :: jsonb
            LEFT OUTER JOIN bed_group AS rb1 ON rbg1.room_bed_group_cd = rb1.bed_group_code
            LEFT OUTER JOIN bed ON bed.bed_code = b.rst_bed_cd
            LEFT OUTER JOIN kur ON kur.kur_code = b.rst_kur_cd
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
, p.com_format_cd
, p.com_type
, d.data_type
, q.残り時間_透析完了
, e.残り時間_透析完了
, bpbefore.monitor_data
, bpcurrent.monitor_data
, b.rst_charge_user_info
, b.rst_puncture_user_info
, b.rst_return_user_info
, bpafter.monitor_data
, b.rst_rounds_info
, f.monitor_data
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
, f.bio_moni_ctl_no
, kur.kur_name
, b.rst_start_date
, b.rst_end_date            
order by b.treat_date, b.ord_no, f.bio_moni_ctl_no', 2, '[]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト(「？？？？」患者)', '2024-04-26 14:31:38', CURRENT_TIMESTAMP, NULL);
