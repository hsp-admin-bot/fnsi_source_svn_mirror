SELECT cl_certificate_id,
       facility_cd,
       many_facility_cd,
       is_merge_issued,
       file_rand_suffix
FROM client_cer_detail
WHERE cl_certificate_id = /*clCertificateId*/0
