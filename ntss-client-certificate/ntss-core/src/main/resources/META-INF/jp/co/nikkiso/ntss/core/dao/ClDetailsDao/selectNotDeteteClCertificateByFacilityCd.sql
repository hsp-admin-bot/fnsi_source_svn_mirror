SELECT password_decrypt(password_cl) AS password_cl,
       max_download,
       cur_download,
       facility_cd,
       expired_date,
       cl_certificate_id,
       many_facility_cd,
       many_facility_name,
       reg_date
FROM client_cer_detail
WHERE facility_cd = /*facilityCd*/''
and  many_facility_cd = /*facilityCd*/''
and  is_delete ='0'
