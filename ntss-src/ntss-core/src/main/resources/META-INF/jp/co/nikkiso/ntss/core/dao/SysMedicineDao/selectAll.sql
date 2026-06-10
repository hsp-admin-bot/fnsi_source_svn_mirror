select
    /*%expand "A" */*
from
    sys_medicine A
order by
    A.standard_no
    limit 100 offset 0
;
