select
   detail.date as date,
   detail.name as name,
   h.class as holiday_class,
   case
		when h.facility_cd='nkknkk' then true
        else false
   end as is_nkk
from
   mst_holiday h
   cross join lateral jsonb_to_recordset(h.holiday_json) as detail
	 (
		 date text,
		 name text,
		 class text
	 )
where
	h.is_disp = '1'
   	and
   		h.facility_cd = 'nkknkk'
	and
		h.holiday_y = /*holidayY*/2020
;
