SELECT row_to_json(r)
FROM (select * from
(select
    '01010' as weight_checksum,
    '0' as weight_before,
    '0' as weight_mea,
    '1' as weight_body_flag,
    '01010' as setting_checksum,
    '1' as data_ver,
    ind_treatment_cd as treat_mode,
    ind_treat_start_time as dialysis_time,
    ind_cond_info#>>'{"3","value"}' as target_weight,
    encode(convert_to(ind_off_water_info->>'name_1'::text, 'UTF-8'), 'base64') as water_info_name_1,
    encode(convert_to(ind_off_water_info->>'name_2'::text, 'UTF-8'), 'base64') as water_info_name_2,
    encode(convert_to(ind_off_water_info->>'name_3'::text, 'UTF-8'), 'base64') as water_info_name_3,
    encode(convert_to(ind_off_water_info->>'name_4'::text, 'UTF-8'), 'base64') as water_info_name_4,
    encode(convert_to(ind_off_water_info->>'name_5'::text, 'UTF-8'), 'base64') as water_info_name_5,
    ind_off_water_info->>'weight_1' as water_info_weight_1,
    ind_off_water_info->>'weight_2' as water_info_weight_2,
    ind_off_water_info->>'weight_3' as water_info_weight_3,
    ind_off_water_info->>'weight_4' as water_info_weight_4,
    ind_off_water_info->>'weight_5' as water_info_weight_5,
    encode(convert_to(ind_tare_info->>'name_1'::text, 'UTF-8'), 'base64') as ind_tare_info_name_1,
    encode(convert_to(ind_tare_info->>'name_2'::text, 'UTF-8'), 'base64') as ind_tare_info_name_2,
    encode(convert_to(ind_tare_info->>'name_3'::text, 'UTF-8'), 'base64') as ind_tare_info_name_3,
    encode(convert_to(ind_tare_info->>'name_4'::text, 'UTF-8'), 'base64') as ind_tare_info_name_4,
    encode(convert_to(ind_tare_info->>'name_5'::text, 'UTF-8'), 'base64') as ind_tare_info_name_5,
    ind_tare_info->>'weight_1' as ind_tare_info_weight_1,
    ind_tare_info->>'weight_2' as ind_tare_info_weight_2,
    ind_tare_info->>'weight_3' as ind_tare_info_weight_3,
    ind_tare_info->>'weight_4' as ind_tare_info_weight_4,
    ind_tare_info->>'weight_5' as ind_tare_info_weight_5,
    ind_cond_info#>>'{"20","value"}' as ind_cond_info_20,
    ind_cond_info#>>'{"24","value"}' as ind_cond_info_24,
    ind_cond_info#>>'{"21","value"}' as ind_cond_info_21,
    ind_cond_info#>>'{"23","value"}' as ind_cond_info_23,
    ind_cond_info#>>'{"14","value"}' as ind_cond_info_14,
    ind_cond_info#>>'{"31","value"}' as ind_cond_info_31,
    ind_cond_info#>>'{"32","value"}' as ind_cond_info_32,
    ind_cond_info#>>'{"36","value"}' as ind_cond_info_36,
    ind_cond_info#>>'{"18","value"}' as ind_cond_info_18,
    ind_cond_info#>>'{"16","value"}' as ind_cond_info_16,
    ind_device_set_info#>>'{"ihdf","dev","A","203"}' as ind_device_set_info_203,
    ind_device_set_info#>>'{"ihdf","dev","A","200"}' as ind_device_set_info_200,
    ind_device_set_info#>>'{"ihdf","dev","A","202"}' as ind_device_set_info_202,
    ind_device_set_info#>>'{"ihdf","dev","A","201"}' as ind_device_set_info_201,
    ind_cond_info#>>'{"3","value"}' as ind_cond_info_3,
    ind_cond_info#>>'{"4","value"}' as ind_cond_info_4,
    ind_kur_cd,
    ind_treat_start_time,
    ind_bed_cd,
    ind_cond_info#>>'{"2","value"}' as ind_cond_info_2,
    ind_cond_info#>>'{"5","value"}' as ind_cond_info_5,
    ind_cond_info#>>'{"6","value"}' as ind_cond_info_6,
    ind_cond_info#>>'{"7","value"}' as ind_cond_info_7,
    ind_cond_info#>>'{"8","value"}' as ind_cond_info_8,
    ind_cond_info#>>'{"9","value"}' as ind_cond_info_9,
    ind_cond_info#>>'{"10","value"}' as ind_cond_info_10,
    ind_cond_info#>>'{"11","value"}' as ind_cond_info_11,
    ind_cond_info#>>'{"12","value"}' as ind_cond_info_12,
    ind_cond_info#>>'{"13","value"}' as ind_cond_info_13,
    ind_cond_info#>>'{"15","value"}' as ind_cond_info_15,
    ind_cond_info#>>'{"17","value"}' as ind_cond_info_17,
    ind_cond_info#>>'{"19","value"}' as ind_cond_info_19,
    ind_cond_info#>>'{"22","value"}' as ind_cond_info_22,
    ind_cond_info#>>'{"25","value"}' as ind_cond_info_25,
    ind_cond_info#>>'{"26","value"}' as ind_cond_info_26,
    ind_cond_info#>>'{"27","value"}' as ind_cond_info_27,
    ind_cond_info#>>'{"28","value"}' as ind_cond_info_28,
    ind_cond_info#>>'{"29","value"}' as ind_cond_info_29,
    ind_cond_info#>>'{"30","value"}' as ind_cond_info_30,
    ind_cond_info#>>'{"33","value"}' as ind_cond_info_33,
    ind_cond_info#>>'{"34","value"}' as ind_cond_info_34,
    ind_cond_info#>>'{"37","value"}' as ind_cond_info_37,
    ind_cond_info#>>'{"38","value"}' as ind_cond_info_38,
    ind_cond_info#>>'{"35","value"}' as ind_cond_info_35
from
    ntss.ord_main as om
where
    om.pat_id = /* patId */0
order by om.up_date desc
limit 1 ) A ,
(
  select
      treat_condition->>'181' as treat_condition_181,
      treat_condition->>'179' as treat_condition_179,
      treat_condition->>'211' as treat_condition_211,
      treat_condition->>'212' as treat_condition_212,
      treat_condition->>'213' as treat_condition_213,
      treat_condition->>'214' as treat_condition_214,
      treat_condition->>'217' as treat_condition_217,
      treat_condition->>'218' as treat_condition_218,
      treat_condition->>'190' as treat_condition_190
  from
      ntss.ord_treat_condition as otc
  where
      EXISTS (select
                om.ord_no
              from
                ntss.ord_main as om
              where
                om.ord_no = otc.ord_no
               and om.pat_id = /* patId */0
             )
  order by up_date desc
  limit 1
) B
) as r
