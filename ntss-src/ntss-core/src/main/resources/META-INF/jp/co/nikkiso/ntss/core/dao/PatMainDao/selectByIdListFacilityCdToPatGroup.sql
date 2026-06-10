-- 保持 add 10389 患者リストのソートが遅い gjn start
select
  pat_id,
  facility_cd,
  medical_care_info,
  in_out_current_state,
  taboo_allergy_info,
  is_infect,
  is_implant,
  is_diabetes,
  is_blood_suger_exam,
  is_wheel_chair,
  wheel_chair_cd
from
  pat_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/''
  and pat_id in /* patIdList */(null)
order by
  pat_id
;
-- 保持 add 10389 患者リストのソートが遅い gjn end
