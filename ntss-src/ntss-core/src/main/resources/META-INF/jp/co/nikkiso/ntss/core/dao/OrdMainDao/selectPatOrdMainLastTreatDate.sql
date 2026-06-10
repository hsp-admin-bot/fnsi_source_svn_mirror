-- add 9480 前回からの体重増加量（Kg） gjn start
select
    /*%expand "A" */*
from ord_main A
where
  facility_cd = /*facilityCd*/'000000'
and
  treat_date < /*treatDate*/'20190101'
and
  pat_id = /*patId*/0
and
  is_del = '0'
and
  rst_end_date is not null
and
  -- 治疗予定外の全てに実质データの治疗
  A.rst_dialysis_state >= '1'
order by
  treat_date DESC,
  ind_treat_start_time DESC
;
-- add 9480 前回からの体重増加量（Kg） gjn end
