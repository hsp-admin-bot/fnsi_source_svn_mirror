select
	medicine_type,
	generic_cd,
	generic_name,
	search_code_list,
	unit_first,
	unit_second,
	is_generic_taboo_type(medicine_type, generic_cd,/*patId*/0) as generic_taboo_type
from sys_generic_medicine
where is_disp = '1' and is_del ='0'
	and search_code_list IS NOT null
;
