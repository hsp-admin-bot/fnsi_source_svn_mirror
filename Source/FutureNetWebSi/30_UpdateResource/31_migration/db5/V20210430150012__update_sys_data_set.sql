UPDATE "ntss"."sys_data_set" SET "sql" = 'with ord_key_tbl as (
  select
    ord_no,
    treat_date
  from
    ord_main
  where
    ord_no = 6621
    and is_del = ''0''
	and rst_dialysis_state = ''0''
), ord_hist_tbl as (
  select
    ord_no,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    rst_dw,
    rst_cond_info->''3''->>''value'' as target_weight
  from
    ord_main
  where
    ord_no <> (select ord_no from ord_key_tbl)
  and
    treat_date <= (select treat_date from ord_key_tbl)
  and
     rst_dialysis_state = ''0''
  and is_del = ''0''
  order by
    treat_date desc
  limit 2

), ord_array_tbl as (
  select
    array_agg(ord_no) as array_ord_no,
    array_agg(treat_date) as array_treat_date,
    array_agg(rst_dw) as array_dw,
    array_agg(target_weight) as array_target_weight
  from
    ord_hist_tbl
)

select
  array_ord_no[1] as ord_no1,
  array_ord_no[2] as ord_no2,
  array_treat_date[1] as treat_date1,
  array_treat_date[2] as treat_date2,
  array_dw[1] as dw1,
  array_dw[2] as dw2,
  array_target_weight[1] as target_weight1,
  array_target_weight[2] as target_weight2
  
from
  ord_array_tbl
', "detail" = '[{"preview": "55.00", "can_calc": "0", "data_code": "dw1", "data_name": "DW（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight1", "data_name": "目標体重（前回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight1", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date1", "data_name": "透析予定日(前回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date1", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw2", "data_name": "DW（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "dw2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight2", "data_name": "目標体重（前々回）", "data_type": "decimal", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "target_weight2", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date2", "data_name": "透析予定日(前々回)", "data_type": "DateTime", "conv_table": [], "data_class": "体重情報(過去指示)", "field_name": "treat_date2", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 82;