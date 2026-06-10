UPDATE "ntss"."sys_data_set" 
SET "sql" = 'with tmp as
(
  select
  to_number(rst_weight_info->>''water_removal_target'', ''99999.999'') as water_removal_target
  ,to_number(rst_weight_info->>''water_removal_rst'', ''99999.999'') as water_removal_rst
  ,to_number(rst_weight_info->>''add_water_total'', ''99999.999'') as add_water_total
  
  ,rst_tare_info->''before''->>''name_1'' as before_tare_name_1
  ,rst_tare_info->''before''->>''name_2'' as before_tare_name_2
  ,rst_tare_info->''before''->>''name_3'' as before_tare_name_3
  ,rst_tare_info->''before''->>''name_4'' as before_tare_name_4
  ,rst_tare_info->''before''->>''name_5'' as before_tare_name_5
  ,to_number(rst_tare_info->''before''->>''weight_1'', ''999999'') as before_tare_weight_1
  ,to_number(rst_tare_info->''before''->>''weight_2'', ''999999'') as before_tare_weight_2
  ,to_number(rst_tare_info->''before''->>''weight_3'', ''999999'') as before_tare_weight_3
  ,to_number(rst_tare_info->''before''->>''weight_4'', ''999999'') as before_tare_weight_4
  ,to_number(rst_tare_info->''before''->>''weight_5'', ''999999'') as before_tare_weight_5
  ,rst_tare_info->''before''->>''wheel_chair_name'' as before_wheel_chair_name
  ,to_number(rst_tare_info->''before''->>''wheel_chair_weight'', ''999999'') as before_wheel_chair_weight
  
  ,rst_tare_info->''after''->>''name_1'' as after_tare_name_1
  ,rst_tare_info->''after''->>''name_2'' as after_tare_name_2
  ,rst_tare_info->''after''->>''name_3'' as after_tare_name_3
  ,rst_tare_info->''after''->>''name_4'' as after_tare_name_4
  ,rst_tare_info->''after''->>''name_5'' as after_tare_name_5
  ,to_number(rst_tare_info->''after''->>''weight_1'', ''999999'') as after_tare_weight_1
  ,to_number(rst_tare_info->''after''->>''weight_2'', ''999999'') as after_tare_weight_2
  ,to_number(rst_tare_info->''after''->>''weight_3'', ''999999'') as after_tare_weight_3
  ,to_number(rst_tare_info->''after''->>''weight_4'', ''999999'') as after_tare_weight_4
  ,to_number(rst_tare_info->''after''->>''weight_5'', ''999999'') as after_tare_weight_5
  ,rst_tare_info->''after''->>''wheel_chair_name'' as after_wheel_chair_name
  ,to_number(rst_tare_info->''after''->>''wheel_chair_weight'', ''999999'') as after_wheel_chair_weight

  ,rst_off_water_info->>''name_1'' as off_water_name_1
  ,rst_off_water_info->>''name_2'' as off_water_name_2
  ,rst_off_water_info->>''name_3'' as off_water_name_3
  ,rst_off_water_info->>''name_4'' as off_water_name_4
  ,rst_off_water_info->>''name_5'' as off_water_name_5
  ,to_number(rst_off_water_info->>''weight_1'', ''999999'') as off_water_weight_1
  ,to_number(rst_off_water_info->>''weight_2'', ''999999'') as off_water_weight_2
  ,to_number(rst_off_water_info->>''weight_3'', ''999999'') as off_water_weight_3
  ,to_number(rst_off_water_info->>''weight_4'', ''999999'') as off_water_weight_4
  ,to_number(rst_off_water_info->>''weight_5'', ''999999'') as off_water_weight_5
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and rst_dialysis_state <> ''0''
)

select
  *
  ,coalesce(before_tare_weight_1, 0) + coalesce(before_tare_weight_2, 0)
    + coalesce(before_tare_weight_3, 0) + coalesce(before_tare_weight_4, 0)
    + coalesce(before_tare_weight_5, 0) + coalesce(before_wheel_chair_weight, 0) as before_tare_total
  ,coalesce(after_tare_weight_1, 0) + coalesce(after_tare_weight_2, 0)
    + coalesce(after_tare_weight_3, 0) + coalesce(after_tare_weight_4, 0)
    + coalesce(after_tare_weight_5, 0) + coalesce(after_wheel_chair_weight, 0) as after_tare_total
  ,coalesce(off_water_weight_1, 0) + coalesce(off_water_weight_2, 0)
    + coalesce(off_water_weight_3, 0) + coalesce(off_water_weight_4, 0) + coalesce(off_water_weight_5, 0) as off_water_total
from
  tmp
;'
WHERE
	sql_cd = '105';