Update
      client_cer_facility
Set
      facility_password= /*facilityPassword*/null,
      facility_name = /*facilityName*/null,
      up_date = TO_TIMESTAMP(/*upDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
      is_provisional = /*isProvisional*/1
Where
      facility_cd = /*facilityCd*/1
and is_delete ='0'
