UPDATE client_cer_detail
SET is_delete = '1',
    up_date = TO_TIMESTAMP(/*upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE facility_cd = /*facilityCd*/''
and is_delete = '0'
and cl_certificate_id = /*clCertificateId*/0
