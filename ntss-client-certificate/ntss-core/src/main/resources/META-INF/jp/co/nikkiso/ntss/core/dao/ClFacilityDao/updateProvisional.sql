Update
    client_cer_facility
Set
    is_provisional = /*Provisional*/1,
    facility_password = /*hashFacilityPassword*/'',
    up_date =  TO_TIMESTAMP(/*upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
Where
    facility_cd = /*facilityCd*/1
and is_delete ='0'
