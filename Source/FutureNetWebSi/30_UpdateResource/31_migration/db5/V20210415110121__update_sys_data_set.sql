
		UPDATE sys_data_set 
SET SQL = 'select
  p.reg_rad_date,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
	and jsonb_array_length(m.order_rad_set_info) > 0
  	and m.pat_id = @patId
	and m.reg_rad_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_rad_date
	) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''')  and mst.is_del =''0'' and mst.is_disp = ''1''
  limit 100
;' , "detail" = '[{"preview": "2011/03/12", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "yyyy/mm/dd", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:00", "can_calc": "0", "data_code": "reg_rad_date", "data_name": "検査時刻", "data_type": "DateTime", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "reg_rad_date", "disp_format": "hh:mm", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線検査テスト", "can_calc": "0", "data_code": "rad_set_name", "data_name": "放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "放射線テスト", "can_calc": "0", "data_code": "rad_set_abb_name", "data_name": "省略 放射線検査名", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "rad_set_abb_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方法テスト", "can_calc": "0", "data_code": "ctl_name1", "data_name": "方法", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name1", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "item_cd1", "data_name": "方法コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd1", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "区分テスト", "can_calc": "0", "data_code": "ctl_name2", "data_name": "区分", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name2", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2222", "can_calc": "0", "data_code": "item_cd2", "data_name": "区分コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd2", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "部位テスト", "can_calc": "0", "data_code": "ctl_name3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name3", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "333", "can_calc": "0", "data_code": "item_cd3", "data_name": "部位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd3", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左右テスト", "can_calc": "0", "data_code": "ctl_name4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name4", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "item_cd4", "data_name": "左右コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd4", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "体位テスト", "can_calc": "0", "data_code": "ctl_name5", "data_name": "体位", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name5", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "item_cd5", "data_name": "体位コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd5", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "方向テスト", "can_calc": "0", "data_code": "ctl_name6", "data_name": "方向", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "ctl_name6", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "item_cd6", "data_name": "方向コード", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "item_cd6", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd1", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd2", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "in_hospital_cd3", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd1", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd2", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "放射線検査予定(指定日以降)", "field_name": "sbt_cd3", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]'
WHERE
	sql_cd = '58'
	