select
    distinct ind_kur_cd
from ord_main A
where
--       mod FNSI redmine 劉祥霖 5923 start
--   ind_treatment_cd = /*treatmentCd*/0
  ind_bed_cd = /*indBedCd*/0
--       mod FNSI redmine 劉祥霖 5923 end
and
  treat_date = /*treatDate*/null
and
   ind_kur_cd <> '0'
and
  is_del = '0'
;
