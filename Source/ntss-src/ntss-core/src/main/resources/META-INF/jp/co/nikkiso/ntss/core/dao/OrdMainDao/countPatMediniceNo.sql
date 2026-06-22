select
  count(p.pat_id) as cnt
from
  pat_treatment_pattern p
where
    p.facility_cd = /*facilityCd*/'000000'
  and
    p.pat_id = /*patId*/1
  and
    p.ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
  and
    p.treat_week in /*youbi*/(0)
;
