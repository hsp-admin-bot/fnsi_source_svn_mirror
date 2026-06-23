UPDATE "ntss"."sys_data_set" 
SET "sql" = 'with tmp as
(
select 
  to_number(rst_weight_info->>''weight_before'', ''999.99'') as weight_before
  ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date

  ,to_number(rst_weight_info->>''weight_after'', ''999.99'') as weight_after
  ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date

  ,to_number(rst_weight_info->>''ctr'', ''999.99'') as ctr
  ,(rst_weight_info->>''ctr_measure_date'')::timestamp as ctr_measure_date
  ,to_number(rst_weight_info->>''ctr_weight'', ''999.99'') as ctr_weight

  ,to_number(rst_weight_info->>''kt_v_measure'', ''999.99'') as kt_v_measure
  ,to_number(rst_weight_info->>''urr'', ''999.9'') as urr
  ,to_number((select monitor_data from mni_monitor where bio_moni_ctl_no::text = rst_weight_info->>''re_loop_rate_main'' and is_del = ''0'')->>''38'', ''999.99'') as re_loop_rate
  
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''90'', ''999'') as before_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''91'', ''999'') as before_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''92'', ''999'') as before_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''93'', ''999'') as before_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'') as before_vital_measure_date
  
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''90'', ''999'') as after_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''91'', ''999'') as after_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''92'', ''999'') as after_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''93'', ''999'') as after_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'') as after_vital_measure_date
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
 and rst_dialysis_state <>''0''
)

select
  *
  ,before_bp_high::text || ''/'' || before_bp_low::text || ''/'' || before_bp_ave || ''('' || before_pulse::text || '')'' as before_bp_summary
  ,after_bp_high::text || ''/'' || after_bp_low::text || ''/'' || after_bp_ave || ''('' || after_pulse::text || '')'' as after_bp_summary
from
  tmp
;'
WHERE
	sql_cd = '3';