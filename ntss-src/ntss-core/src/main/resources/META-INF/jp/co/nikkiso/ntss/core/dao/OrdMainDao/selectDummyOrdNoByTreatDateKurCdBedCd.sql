-- add FNSI redmine 6588 劉祥霖 start
select
    ord_no
from
    ord_schedule
where
        bed_cd=/*indBedCd*/0
  and
        treat_date = /*treatDate*/null
  and
        kur_cd = /*kurCd*/null
  and
        is_dummy = '1'
;
-- add FNSI redmine 6588 劉祥霖 end
