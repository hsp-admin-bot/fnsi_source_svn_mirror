select
  pat_id,
  facility_cd,
  is_same,
  is_implant,
  is_infect,
  is_diabetes,
  is_blood_suger_exam,
  is_wheel_chair,
  in_out_current_state,
  in_out_plan_state,
  in_out_plan_date,
  pat_memo_info,
  addition_info,
  charge_staff_info,
-- No.7167 upd Paging Optimization runtime by ztc start
  (
    SELECT
      array_to_json ( ARRAY_AGG ( pg.pat_group_name ) )
    FROM
      pat_group_detail pgd
        LEFT JOIN pat_group pg ON pgd.pat_group_cd = pg.pat_group_cd
    WHERE
        pgd.pat_id = pat_main.pat_id AND pgd.facility_cd = /*facilityCd*/'000001'
  ) AS pat_group_info,
-- No.7167 upd Paging Optimization runtime by ztc end
  taboo_allergy_info,
  infect_info,
  implant_info,
  tare_info,
  off_water_info,
  device_set_info,
  acceptance_status_info,
  is_del,
  up_date,
  reg_date,
  medical_care_info,
  sch_ext_end_date,
  sch_ext_status,
  host_notification_info,
--   count_ord.old_up_date
  up_date as old_up_date,
  wheel_chair_cd
from
  pat_main
--       left join
--     No.7167 upd Paging Optimization runtime by ztc start
-- 	(select count(1) as old_up_date ,ord.pat_id as ord_pat_id	from ord_main ord where ord.rst_dialysis_state = '0' AND facility_cd = /*facilityCd*/'000001' group by ord.pat_id) count_ord
--     No.7167 upd Paging Optimization runtime by ztc end
-- on pat_main.pat_id  = count_ord.ord_pat_id
where
    is_del = '0'
  and facility_cd = /*facilityCd*/'000001'
  and pat_id in /* patIdList */(null)
order by
  pat_id
;
