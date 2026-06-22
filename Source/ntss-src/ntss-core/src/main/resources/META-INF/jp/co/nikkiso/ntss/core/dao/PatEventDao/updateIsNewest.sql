update pat_event
set
  is_newest = /*patEvent.isNewest*/null,
  up_date = /*patEvent.upDate*/null
where
  pat_id = /*patEvent.patId*/null
and
  facility_cd = /*patEvent.facilityCd*/null
and
  category_cd = /*patEvent.categoryCd*/null
;
