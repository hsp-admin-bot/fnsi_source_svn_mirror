select
    sub.facility_cd,
    sub.vital_monitor_class,
    sub.vital_monitor_item_cd,
    sub.vital_monitor_item_name,
    sub.is_disp,
    sub.is_del,
    sub.reg_date,
    sub.up_date
from (
    select
        /*%expand "A" */*,
        ROW_NUMBER() OVER (ORDER BY A.facility_cd) AS rn
    from mst_add_monitor A
    where
        A.facility_cd = /*facilityCd*/'0'
        /*%if vitalMonitorClass != "" && vitalMonitorClass != null */
        and A.vital_monitor_class = /*vitalMonitorClass*/'0'
        /*%end*/
        and A.is_disp = '1'
        and A.is_del = '0'
) sub
order by sub.rn;

