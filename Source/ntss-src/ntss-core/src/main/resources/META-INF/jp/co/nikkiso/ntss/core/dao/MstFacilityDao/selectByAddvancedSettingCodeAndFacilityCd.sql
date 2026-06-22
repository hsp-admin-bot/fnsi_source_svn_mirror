select
	/*%expand "F" */*
from
	mst_facility F,
	jsonb_array_elements(F.advanced_settings->'func_advcds') func 
where 
	F.facility_cd = /*facilityCd*/null 
	and func->>'func_advcd'= /*advancedSettingCode*/null