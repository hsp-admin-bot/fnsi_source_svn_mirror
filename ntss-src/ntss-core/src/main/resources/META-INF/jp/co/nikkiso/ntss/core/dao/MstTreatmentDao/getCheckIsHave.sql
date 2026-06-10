select
count(A.ord_no)
from
ord_main A
INNER JOIN mnt_machine_state B
ON A.ord_no = B.ord_no
AND A.facility_cd = B.facility_cd
AND A.facility_cd = /*facilityCd*/000000
AND A.ord_no = /*ordNo*/1
AND A.is_del = '0'
