SELECT A.cl_certificate_id,
       A.cur_download,
       A.facility_cd,
       A.download_date as up_date,
       A.is_delete,
       A.many_facility_name,
       A.many_facility_cd
FROM client_cer_detail A
WHERE A.facility_cd =  /*facilityCd*/''
ORDER BY A.reg_date
