select
	/*%expand "A" */*
from
	mst_addition A
where
	A.addition_cd = /* additionCd */'0'
;