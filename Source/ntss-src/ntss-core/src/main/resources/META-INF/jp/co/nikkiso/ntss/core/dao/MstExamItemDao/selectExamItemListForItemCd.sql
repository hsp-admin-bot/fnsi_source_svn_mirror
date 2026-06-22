SELECT 
item.exam_item_cd as item_cd,
item.facility_cd,
item.fn_exam_item_cd,
item.exam_item_name as item_name,
item.data_type as type,
item.unit,
item.normal_value_class,
item.normal_value_upper as upper,
item.normal_value_lower as lower,
item.normal_value_upper_m,
item.normal_value_lower_m,
item.normal_value_upper_w,
item.normal_value_lower_w,
item.input_integer_figure,
item.input_decimal_figure,
item.input_upper,
item.input_lower,
item.graph_upper,
item.graph_lower,
item.console_class,
item.exam_class,
item.in_hospital_cd1,
item.sbt_cd1,
item.in_hospital_cd2,
item.sbt_cd2,
item.in_hospital_cd3,
item.sbt_cd3,
item.spitz_cd,
item.jlac10_cd,
item.infection_cd,
item.free_calc,
item.is_disp,
item.is_del,
item.reg_date,
item.up_date
FROM ntss.mst_exam_item item
WHERE 
item.facility_cd = /* facilityCd */null
AND item.exam_item_cd in /* examItemCd */(null)
AND item.exam_class in /* examClass */(null)
/*%if null != dispFlg  */
AND item.is_disp = /* dispFlg */null
/*%end */
