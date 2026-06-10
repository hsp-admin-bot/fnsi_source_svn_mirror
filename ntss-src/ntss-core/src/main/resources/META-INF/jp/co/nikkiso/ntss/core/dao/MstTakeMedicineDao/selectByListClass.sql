--搬送区分
select
    /*%expand "A" */*
from
    mst_take_medicine A
where 
    A.facility_cd = /*facilityCd*/'000000'
/*%if listClass != null */
and A.list_class = /*listClass*/'00'
/*%end*/
