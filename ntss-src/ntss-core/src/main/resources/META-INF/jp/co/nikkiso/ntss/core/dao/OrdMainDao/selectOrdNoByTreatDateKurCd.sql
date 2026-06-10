select
    ord_no
from ord_main A
where
--       add FNSI redmine 劉祥霖 5923 start
  ind_bed_cd=/*indBedCd*/0
and
--       add FNSI redmine 劉祥霖 5923 end
  treat_date = /*treatDate*/null
and
  ind_kur_cd = /*kurCd*/null
and
  is_del = '0'
;
