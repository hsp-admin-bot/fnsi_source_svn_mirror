delete from
    ord_schedule
where facility_cd = /*facilityCd*/''
  and ord_no in /* deleteDummyScheduleList */()
  and is_dummy = '1'
;
