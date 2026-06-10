select
  ord_no
from
  ord_main A
where
--       add FNSI redmine 劉祥霖 5923 start
  pat_id=/*patId*/0
and
--       add FNSI redmine 劉祥霖 5923 end
  ind_treatment_cd = /*treatmentCd*/0
and
  treat_date = /*treatDate*/null
and
  ind_kur_cd = /*kurCd*/null
and
  is_del = '0'
;
