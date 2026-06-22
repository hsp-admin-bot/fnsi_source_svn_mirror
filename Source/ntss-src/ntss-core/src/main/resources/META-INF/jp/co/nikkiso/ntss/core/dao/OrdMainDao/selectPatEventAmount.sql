select
	count(*)
from 
	ord_main om
	inner join pat_event pe 
		on om.pat_id = pe.pat_id
where 
	om.pat_id = /*patId*/0
	and om.ord_no = /*ordNo*/0
	and om.treat_date = pe.event_start_date
	and om.is_del = '0'
	and pe.is_del = '0'
	and pe.sub_category_cd = /*categoryCd*/null
;
