UPDATE client_cer_facility
SET is_delete = '1',
    up_date = TO_TIMESTAMP(/*upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE facility_cd = /*facilityCd*/1
and is_delete = '0'
