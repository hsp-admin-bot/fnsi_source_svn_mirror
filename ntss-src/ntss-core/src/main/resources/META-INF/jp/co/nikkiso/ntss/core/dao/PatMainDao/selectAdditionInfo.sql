SELECT
 j1.cd As cd,
 j1.reg_date As reg_date,
 j1.is_enable As is_enable,
 j1.start_date As start_date
from pat_main p1,
  jsonb_to_recordset(addition_info) 
    as j1(
        cd text,
        reg_date text,
        is_enable text,
        start_date text
    )
WHERE
    p1.is_del = '0'
	AND p1.facility_cd = /*facilityCd*/'000000'
	AND p1.pat_id = /*patId*/0
;