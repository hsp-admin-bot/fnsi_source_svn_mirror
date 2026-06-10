Update
    client_cer_facility
Set
    attempt_fail = /*attemptFail*/0,
    /*%if facilityName != null */
        facility_name = /* facilityName */null,
    /*%end*/
    up_date = current_timestamp
Where
    facility_cd = /*facilityCd*/1
and is_delete ='0'
