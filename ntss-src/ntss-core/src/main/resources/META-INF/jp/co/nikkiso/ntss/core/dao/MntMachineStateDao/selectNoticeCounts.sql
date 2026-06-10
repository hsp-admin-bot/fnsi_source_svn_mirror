select
  sum(case when m_notice_cnt >= 1 then 1 else 0 end) as total_m_notice_cnt,
  sum(case when preventive_mainte_cnt >= 1 then 1 else 0 end) as total_preventive_cnt,
  sum(case when is_preventive_mainte >= 1 then 1 else 0 end) as total_com_problem_cnt,
  sum(case when service_support_cnt >= 1 then 1 else 0 end) as total_service_support_cnt
from
  mnt_machine_state

where
  facility_cd = /*facilityCd*/'1'

group by
  facility_cd

order by
  facility_cd
;
