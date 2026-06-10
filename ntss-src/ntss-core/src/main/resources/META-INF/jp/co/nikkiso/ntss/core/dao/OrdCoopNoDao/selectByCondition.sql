select
	/*%expand "A" */*
from
	ord_coop_no A
where
	A.is_del = '0'
	and A.facility_cd = /* facilityCd */'000000'
/*%if ordNo == null || ordNo == 0L */
-- mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
--	and A.ord_no is null
	and (A.ord_no is null OR A.ord_no = 0)
-- mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/*%else*/
	and A.ord_no = /* ordNo */null
/*%end*/
	and A.coop_cd = /* coopCd */''
;
